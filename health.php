<?php
/* =========================================================
   health.php — health probes for Docker, the load balancer and the pipeline
     /health.php             full status (app + database), 200 or 503
     /health.php?probe=live  the PHP process answers (no database)
     /health.php?probe=ready the database answers and the schema is loaded
   Never needs a login and never shows secrets.
   ========================================================= */
require_once __DIR__ . '/lib/helpers.php';
farm_load_env(FARM_ROOT . '/.env');

header('Content-Type: application/json');
header('Cache-Control: no-store');
$start = microtime(true);
$probe = $_GET['probe'] ?? 'full';

$result = ['status' => 'ok', 'service' => 'agrofarm', 'version' => env('APP_VERSION', 'dev'), 'probe' => $probe];

if ($probe !== 'live') {
    try {
        $db = farm_pdo();
        $animals = (int) $db->query('SELECT COUNT(*) FROM animal')->fetchColumn();
        $db = null;
        $result['database'] = 'ok';
        $result['animals']  = $animals;
    } catch (Throwable $e) {
        $result['status']   = 'error';
        $result['database'] = 'unavailable';
    }
}

$code = $result['status'] === 'ok' ? 200 : 503;
http_response_code($code);
echo json_encode($result);

farm_log($code === 200 ? 'info' : 'error', 'health check', [
    'route' => '/health.php', 'method' => $_SERVER['REQUEST_METHOD'] ?? 'GET', 'probe' => $probe,
    'statusCode' => $code, 'latencyMs' => (int) round((microtime(true) - $start) * 1000),
]);
