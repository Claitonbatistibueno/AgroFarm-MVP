<?php
/* =========================================================
   vet_ai.php — Veterinary AI assistant (Claude API)
   Library file: included by ai_vision.php, never opened directly.

   Flow: animal data from MariaDB + vitals/symptoms from the form
         + (optional) photo + (optional) PubMed titles
         -> Claude Messages API -> structured JSON report.

   Needs in .env:  ANTHROPIC_API_KEY=sk-ant-...
   Optional:       ANTHROPIC_MODEL=claude-sonnet-5-5
   ========================================================= */

if (!defined('FARM_BOOTSTRAPPED')) { http_response_code(403); exit; }

const VET_AI_SCHEMA_KEYS = ['summary', 'hypotheses', 'justification', 'questions',
                            'safe_actions', 'warnings', 'references', 'confidence'];

/** Profile + last weighings + last treatments for one animal. */
function vet_ai_animal_data(mysqli $conn, int $animalId): ?array {
    $stmt = $conn->prepare(
        "SELECT a.animal_id, a.tag_number, a.sex, a.birth_date, a.status,
                t.species, t.breed, DATEDIFF(NOW(), a.birth_date) AS age_days
           FROM animal a
           LEFT JOIN animal_types t ON a.type_id = t.type_id
          WHERE a.animal_id = ?");
    $stmt->bind_param('i', $animalId);
    $stmt->execute();
    $profile = $stmt->get_result()->fetch_assoc();
    if (!$profile) { return null; }

    $stmt = $conn->prepare("SELECT weighing_date, weight_kg, daily_gain FROM weighing
                             WHERE animal_id = ? ORDER BY weighing_date DESC LIMIT 5");
    $stmt->bind_param('i', $animalId);
    $stmt->execute();
    $weights = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

    $stmt = $conn->prepare("SELECT h.treatment_date, h.diagnosis, m.item_name
                              FROM health_records h
                              LEFT JOIN medical_catalog m ON h.item_id = m.item_id
                             WHERE h.animal_id = ? ORDER BY h.treatment_date DESC LIMIT 5");
    $stmt->bind_param('i', $animalId);
    $stmt->execute();
    $health = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);

    return ['profile' => $profile, 'weight_history' => $weights, 'health_history' => $health];
}

/** Small HTTP helper (cURL). Returns [status, body] or [0, error]. */
function vet_ai_http(string $method, string $url, array $headers = [], ?string $body = null, int $timeout = 60): array {
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CUSTOMREQUEST  => $method,
        CURLOPT_HTTPHEADER     => $headers,
        CURLOPT_TIMEOUT        => $timeout,
        CURLOPT_CONNECTTIMEOUT => 10,
    ]);
    if ($body !== null) { curl_setopt($ch, CURLOPT_POSTFIELDS, $body); }
    $resp = curl_exec($ch);
    if ($resp === false) {
        $err = curl_error($ch);
        curl_close($ch);
        return [0, $err];
    }
    $status = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    return [$status, $resp];
}

/** Up to 3 recent PubMed titles for species + symptoms (best effort, never fatal). */
function vet_ai_pubmed(string $species, array $symptoms): array {
    if (!$symptoms || env('PUBMED_ENABLED', '1') !== '1') { return []; }
    $term = $species . ' AND (' . implode(' OR ', $symptoms) . ')';
    $base = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
    [$s, $body] = vet_ai_http('GET', $base . 'esearch.fcgi?' . http_build_query(
        ['db' => 'pubmed', 'term' => $term, 'retmax' => 3, 'retmode' => 'json', 'sort' => 'relevance']), [], null, 8);
    $ids = ($s === 200) ? (json_decode($body, true)['esearchresult']['idlist'] ?? []) : [];
    if (!$ids) { return []; }
    [$s, $body] = vet_ai_http('GET', $base . 'esummary.fcgi?' . http_build_query(
        ['db' => 'pubmed', 'id' => implode(',', $ids), 'retmode' => 'json']), [], null, 8);
    if ($s !== 200) { return []; }
    $res = json_decode($body, true)['result'] ?? [];
    $out = [];
    foreach ($ids as $id) {
        if (!empty($res[$id]['title'])) { $out[] = "PMID $id: " . $res[$id]['title']; }
    }
    return $out;
}

/** Pull the first {...} JSON object out of the model text. */
function vet_ai_parse_json(string $text): ?array {
    $text = trim(preg_replace('/^```(?:json)?|```$/m', '', trim($text)));
    $start = strpos($text, '{');
    $end   = strrpos($text, '}');
    if ($start === false || $end === false) { return null; }
    $data = json_decode(substr($text, $start, $end - $start + 1), true);
    return is_array($data) ? $data : null;
}

/** Normalise the report so the page can render it without surprises. */
function vet_ai_normalise(array $r): array {
    $list = fn($v) => array_values(array_filter(array_map('strval', is_array($v) ? $v : []), 'strlen'));
    $hyps = [];
    foreach (($r['hypotheses'] ?? []) as $h) {
        if (!is_array($h) || empty($h['name'])) { continue; }
        $hyps[] = ['name' => (string) $h['name'], 'prob' => max(0, min(100, (int) ($h['prob'] ?? 0)))];
    }
    $conf = ucfirst(strtolower((string) ($r['confidence'] ?? 'Low')));
    return [
        'summary'       => (string) ($r['summary'] ?? ''),
        'hypotheses'    => $hyps,
        'justification' => (string) ($r['justification'] ?? ''),
        'questions'     => $list($r['questions'] ?? []),
        'safe_actions'  => $list($r['safe_actions'] ?? []),
        'warnings'      => $list($r['warnings'] ?? []),
        'references'    => $list($r['references'] ?? []),
        'confidence'    => in_array($conf, ['High', 'Medium', 'Low'], true) ? $conf : 'Low',
    ];
}

/**
 * Run the analysis.
 * @return array ['report' => array] on success, ['error' => string] on failure.
 */
function vet_ai_analyse(mysqli $conn, int $animalId, ?float $temperature, array $symptoms,
                        string $observations, ?string $imagePath = null): array {
    $apiKey = env('ANTHROPIC_API_KEY');
    if (!$apiKey) {
        return ['error' => 'AI is not configured: add ANTHROPIC_API_KEY to the .env file.'];
    }

    $animal = vet_ai_animal_data($conn, $animalId);
    if (!$animal) { return ['error' => "Animal #$animalId was not found."]; }

    $symptoms = array_values(array_filter(array_map(
        fn($s) => trim(preg_replace('/[^\p{L}\p{N} _\-]/u', '', (string) $s)), $symptoms)));
    $species  = $animal['profile']['species'] ?: 'cattle';
    $evidence = vet_ai_pubmed($species, $symptoms);

    $system = 'You are a veterinary decision-support assistant for livestock farmers in Ireland and Europe. '
        . 'You support, never replace, a licensed veterinarian. Be conservative: when signs could indicate '
        . 'a notifiable disease or an emergency, say so clearly and recommend contacting a vet / the Department '
        . 'of Agriculture immediately. Never recommend prescription-only medicine doses. '
        . 'Reply with ONLY one JSON object (no markdown) with exactly these keys: '
        . '"summary" (string), "hypotheses" (array of {"name": string, "prob": integer 0-100}, most likely first, max 4), '
        . '"justification" (string), "questions" (array of strings the farmer should check), '
        . '"safe_actions" (array of strings a farmer can do safely now), "warnings" (array of strings), '
        . '"references" (array of strings; only cite the PubMed items provided, or general guidance sources), '
        . '"confidence" ("High", "Medium" or "Low").';

    $caseText = "CASE DATA\n"
        . "Animal record (from farm database): " . json_encode($animal, JSON_UNESCAPED_UNICODE) . "\n"
        . "Rectal temperature (°C): " . ($temperature !== null ? $temperature : 'not measured') . "\n"
        . "Observed symptoms: " . ($symptoms ? implode(', ', $symptoms) : 'none selected') . "\n"
        . "Farmer observations: " . ($observations !== '' ? $observations : 'none') . "\n"
        . "PubMed literature found: " . ($evidence ? implode(' | ', $evidence) : 'none') . "\n"
        . ($imagePath ? "A photo of the animal is attached; describe any visible clinical signs." : "No photo provided.");

    $content = [];
    if ($imagePath && is_file(FARM_ROOT . '/' . $imagePath) && filesize(FARM_ROOT . '/' . $imagePath) <= 5 * 1024 * 1024) {
        $abs  = FARM_ROOT . '/' . $imagePath;
        $mime = (new finfo(FILEINFO_MIME_TYPE))->file($abs);
        if (in_array($mime, ['image/jpeg', 'image/png', 'image/webp', 'image/gif'], true)) {
            $content[] = ['type' => 'image', 'source' => [
                'type' => 'base64', 'media_type' => $mime, 'data' => base64_encode(file_get_contents($abs))]];
        }
    }
    $content[] = ['type' => 'text', 'text' => $caseText];

    $payload = json_encode([
        'model'       => env('ANTHROPIC_MODEL', 'claude-sonnet-5-5'),
        'max_tokens'  => 2000,
        'temperature' => 0.2,
        'system'      => $system,
        'messages'    => [['role' => 'user', 'content' => $content]],
    ], JSON_UNESCAPED_UNICODE);

    [$status, $body] = vet_ai_http('POST', rtrim(env('ANTHROPIC_BASE_URL', 'https://api.anthropic.com'), '/') . '/v1/messages', [
        'content-type: application/json',
        'x-api-key: ' . $apiKey,
        'anthropic-version: 2023-06-01',
    ], $payload, 90);

    if ($status === 0) {
        error_log('[AgroFarm AI] network: ' . $body);
        return ['error' => 'Could not reach the AI service (network). Check the server internet connection.'];
    }
    $json = json_decode($body, true);
    if ($status !== 200) {
        $apiMsg = $json['error']['message'] ?? substr((string) $body, 0, 300);
        error_log("[AgroFarm AI] HTTP $status: $apiMsg");
        $hint = match (true) {
            $status === 401 => 'The API key is invalid. Check ANTHROPIC_API_KEY in .env.',
            $status === 429 => 'Rate limit reached. Wait a minute and try again.',
            $status === 404 => 'Model not found. Check ANTHROPIC_MODEL in .env.',
            $status >= 500  => 'The AI service is temporarily unavailable. Try again shortly.',
            default         => 'The AI request was rejected.',
        };
        return ['error' => $hint . (APP_DEBUG ? " ($status: $apiMsg)" : '')];
    }

    $text = '';
    foreach (($json['content'] ?? []) as $block) {
        if (($block['type'] ?? '') === 'text') { $text .= $block['text']; }
    }
    $report = vet_ai_parse_json($text);
    if (!$report) {
        error_log('[AgroFarm AI] unparseable response: ' . substr($text, 0, 500));
        return ['error' => 'The AI answered in an unexpected format. Please try again.'];
    }
    return ['report' => vet_ai_normalise($report)];
}
