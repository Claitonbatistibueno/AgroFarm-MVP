<?php
/* =========================================================
   lib/helpers.php — pure helper functions (no database, no output)
   Loaded by config.php. Kept separate so they can be unit-tested
   without a web server or a database (see tests/Unit).
   ========================================================= */

if (!defined('FARM_ROOT')) { define('FARM_ROOT', dirname(__DIR__)); }

/* ---------- Environment ---------- */
function farm_load_env(string $file): void {
    if (!is_readable($file)) { return; }
    foreach (file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#' || strpos($line, '=') === false) { continue; }
        [$k, $v] = array_map('trim', explode('=', $line, 2));
        $v = trim($v, "\"'");
        if (getenv($k) === false) { putenv("$k=$v"); $_ENV[$k] = $v; }
    }
}
function env(string $key, $default = null) {
    $v = getenv($key);
    return ($v === false || $v === '') ? $default : $v;
}

/* ---------- Database connection (PostgreSQL / Supabase) ---------- */
/**
 * Opens the PDO connection from .env:
 *   DB_HOST, DB_PORT (5432), DB_NAME, DB_USER, DB_PASS, DB_SSLMODE (require on Supabase)
 * On Supabase use the "Session pooler" host (IPv4), e.g. aws-0-eu-west-1.pooler.supabase.com
 */
function farm_pdo(): PDO {
    $dsn = sprintf('pgsql:host=%s;port=%d;dbname=%s;sslmode=%s',
        env('DB_HOST', '127.0.0.1'), (int) env('DB_PORT', 5432),
        env('DB_NAME', 'agrofarm'), env('DB_SSLMODE', 'prefer'));
    $pdo = new PDO($dsn, env('DB_USER', 'postgres'), env('DB_PASS', ''), [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::ATTR_TIMEOUT            => 10,
    ]);
    $pdo->exec("SET TIME ZONE '" . str_replace("'", '', env('APP_TIMEZONE', 'Europe/Dublin')) . "'");
    return $pdo;
}

/* ---------- Structured logging (one JSON object per line, read by the container logs) ---------- */
function farm_log(string $level, string $message, array $context = []): void {
    $line = json_encode(['timestamp' => gmdate('c'), 'level' => $level, 'message' => $message] + $context,
                        JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    error_log($line);
}

/* ---------- Output / input ---------- */
/** Escape for HTML output. */
function e($value): string {
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/** Return $value if it is a valid Y-m-d date, otherwise $default. */
function valid_date($value, string $default): string {
    if (!is_string($value)) { return $default; }
    $d = DateTime::createFromFormat('Y-m-d', $value);
    return ($d && $d->format('Y-m-d') === $value) ? $value : $default;
}

/**
 * Safely store an uploaded file.
 * Only whitelisted extensions, size limit, random file name, MIME check for images.
 * Returns the relative path (e.g. "uploads/logo/ab12.png") or null on failure.
 */
function safe_upload(array $file, string $subdir, array $allowedExt, int $maxBytes = 5242880): ?string {
    if (($file['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) { return null; }
    if (($file['size'] ?? 0) <= 0 || $file['size'] > $maxBytes)   { return null; }
    if (!is_uploaded_file($file['tmp_name']))                    { return null; }

    $ext = strtolower(pathinfo($file['name'] ?? '', PATHINFO_EXTENSION));
    if ($ext === 'jpeg') { $ext = 'jpg'; }
    if (!in_array($ext, $allowedExt, true)) { return null; }

    $imageExt = ['jpg', 'png', 'webp', 'gif'];
    if (in_array($ext, $imageExt, true)) {
        $mime = (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']);
        if (!in_array($mime, ['image/jpeg', 'image/png', 'image/webp', 'image/gif'], true)) { return null; }
    }

    $dir = 'uploads/' . trim($subdir, '/');
    $abs = FARM_ROOT . '/' . $dir;
    if (!is_dir($abs)) { mkdir($abs, 0755, true); }

    $name = date('Ymd_His') . '_' . bin2hex(random_bytes(6)) . '.' . $ext;
    return move_uploaded_file($file['tmp_name'], "$abs/$name") ? "$dir/$name" : null;
}

/** Redirect to login if there is no authenticated user. */
function require_login(bool $json = false): void {
    if (empty($_SESSION['user_id'])) {
        if ($json) {
            http_response_code(401);
            header('Content-Type: application/json');
            echo json_encode(['success' => false, 'message' => 'Not authenticated']);
        } else {
            header('Location: login.php');
        }
        exit;
    }
}

/* ---------- CSRF ---------- */
function csrf_token(): string {
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf_token'];
}

function csrf_field(): string {
    return '<input type="hidden" name="csrf_token" value="' . e(csrf_token()) . '">';
}

/**
 * Every state-changing request must carry the token:
 *  - POST forms   -> hidden field (injected automatically below)
 *  - fetch()      -> X-CSRF-Token header (injected automatically below)
 *  - ?delete=ID   -> &csrf_token=... (injected automatically below)
 */
function csrf_check(): void {
    if (PHP_SAPI === 'cli') { return; }
    $method   = $_SERVER['REQUEST_METHOD'] ?? 'GET';
    $mutating = ($method === 'POST') || isset($_GET['delete']);
    if (!$mutating) { return; }

    $sent = $_POST['csrf_token'] ?? $_GET['csrf_token'] ?? ($_SERVER['HTTP_X_CSRF_TOKEN'] ?? '');
    if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) {
        http_response_code(419);
        die('Your session expired or the request was invalid. Please go back, refresh the page and try again.');
    }
}

/** Output filter: adds the CSRF token to forms, delete links and fetch() calls. */
function farm_inject_csrf(string $html): string {
    if (stripos($html, '<html') === false && stripos($html, '<form') === false) { return $html; }
    $token = e(csrf_token());

    // hidden field after every <form ... method="post">
    $html = preg_replace(
        '/(<form\b[^>]*method\s*=\s*["\']?post["\']?[^>]*>)/i',
        '$1<input type="hidden" name="csrf_token" value="' . $token . '">',
        $html
    );
    // ?delete=ID links
    $html = preg_replace('/(href="\?delete=[^"&]*)"/i', '$1&csrf_token=' . $token . '"', $html);

    // header for fetch()
    $js = '<meta name="csrf-token" content="' . $token . '"><script>(function(){var t="' . $token . '",f=window.fetch;'
        . 'window.fetch=function(u,o){o=o||{};var m=(o.method||"GET").toUpperCase();'
        . 'if(m!=="GET"&&m!=="HEAD"){o.headers=new Headers(o.headers||{});o.headers.set("X-CSRF-Token",t);}'
        . 'return f.call(this,u,o);};})();</script>';
    $html = preg_replace('/<head\b[^>]*>/i', '$0' . $js, $html, 1);
    return $html;
}

