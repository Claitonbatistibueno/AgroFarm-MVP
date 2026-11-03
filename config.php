<?php
/* =========================================================
   config.php — AgroFarm bootstrap (include on EVERY page)
   - Loads settings from .env (never commit .env)
   - Opens ONE database connection, available as $pdo (PDO) and $conn (mysqli-style API, lib/db.php)
   - Hardened session + CSRF protection injected automatically into every form
   ========================================================= */

if (defined('FARM_BOOTSTRAPPED')) { return; }
define('FARM_BOOTSTRAPPED', true);
define('FARM_ROOT', __DIR__);
require_once FARM_ROOT . '/lib/helpers.php';

/* ---------- 1. Environment (.env) ---------- */
farm_load_env(FARM_ROOT . '/.env');

define('APP_ENV', env('APP_ENV', 'local'));          // local | production
define('APP_DEBUG', APP_ENV !== 'production');

ini_set('display_errors', APP_DEBUG ? '1' : '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);
// Uncaught errors: full details only in local dev; a friendly message in production
set_exception_handler(function (Throwable $e) {
    farm_log('error', $e->getMessage(), ['exception' => get_class($e), 'file' => basename($e->getFile()), 'line' => $e->getLine()]);
    if (!headers_sent()) { http_response_code(500); }
    $isJson = stripos(implode(',', headers_list()), 'application/json') !== false;
    $text = APP_DEBUG ? $e->getMessage() : 'Something went wrong. Please try again.';
    echo $isJson ? json_encode(['success' => false, 'message' => $text])
                 : '<p style="font-family:sans-serif;padding:20px">' . htmlspecialchars($text) . '</p>';
});
date_default_timezone_set(env('APP_TIMEZONE', 'Europe/Dublin'));

/* ---------- 2. Session (hardened cookies) ---------- */
if (session_status() === PHP_SESSION_NONE && PHP_SAPI !== 'cli') {
    $https = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
          || (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https');
    session_set_cookie_params([
        'lifetime' => 0,
        'path'     => '/',
        'secure'   => $https,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_name('agrofarm_sid');
    session_start();
}

/* ---------- 3. Database (one connection: $pdo, plus $conn with the mysqli-style API) ---------- */
// PostgreSQL (Supabase in production, a local Postgres in development / CI)
require_once FARM_ROOT . '/lib/db.php';
try {
    $pdo  = farm_pdo();
    $conn = new FarmDb($pdo);   // mysqli-style API used by the pages, running on PDO
} catch (Throwable $e) {
    farm_log('error', 'DB connection failed', ['detail' => $e->getMessage()]);
    http_response_code(500);
    die(APP_DEBUG ? 'Database connection failed: ' . htmlspecialchars($e->getMessage())
                  : 'Service temporarily unavailable. Please try again later.');
}

/* ---------- 4. Helpers: see lib/helpers.php ---------- */

/* ---------- 5. CSRF protection (functions in lib/helpers.php) ---------- */
if (PHP_SAPI !== 'cli') {
    csrf_check();
    ob_start('farm_inject_csrf');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-Content-Type-Options: nosniff');
    header('Referrer-Policy: same-origin');
}
