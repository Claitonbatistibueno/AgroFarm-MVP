<?php
/* =========================================================
   config.php — AgroFarm bootstrap (include on EVERY page)
   - Loads settings from .env (never commit .env)
   - Opens ONE database connection, available as $conn (mysqli) and $pdo (PDO)
   - Hardened session + CSRF protection injected automatically into every form
   ========================================================= */

if (defined('FARM_BOOTSTRAPPED')) { return; }
define('FARM_BOOTSTRAPPED', true);
define('FARM_ROOT', __DIR__);

/* ---------- 1. Environment (.env) ---------- */
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
farm_load_env(FARM_ROOT . '/.env');

function env(string $key, $default = null) {
    $v = getenv($key);
    return ($v === false || $v === '') ? $default : $v;
}

define('APP_ENV', env('APP_ENV', 'local'));          // local | production
define('APP_DEBUG', APP_ENV !== 'production');

ini_set('display_errors', APP_DEBUG ? '1' : '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);
// Uncaught errors: full details only in local dev; a friendly message in production
set_exception_handler(function (Throwable $e) {
    error_log('[AgroFarm] ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
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

/* ---------- 3. Database (one connection, two APIs) ---------- */
$DB_HOST = env('DB_HOST', 'localhost');
$DB_PORT = (int) env('DB_PORT', 3306);
$DB_NAME = env('DB_NAME', 'farmproject');
$DB_USER = env('DB_USER', 'root');
$DB_PASS = env('DB_PASS', '');

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
try {
    $conn = new mysqli($DB_HOST, $DB_USER, $DB_PASS, $DB_NAME, $DB_PORT);
    $conn->set_charset('utf8mb4');

    $pdo = new PDO(
        "mysql:host=$DB_HOST;port=$DB_PORT;dbname=$DB_NAME;charset=utf8mb4",
        $DB_USER, $DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );
} catch (Throwable $e) {
    error_log('[AgroFarm] DB connection failed: ' . $e->getMessage());
    http_response_code(500);
    die(APP_DEBUG ? 'Database connection failed: ' . htmlspecialchars($e->getMessage())
                  : 'Service temporarily unavailable. Please try again later.');
}
unset($DB_PASS);

/* ---------- 4. Helpers ---------- */

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

/* ---------- 5. CSRF protection ---------- */
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

if (PHP_SAPI !== 'cli') {
    csrf_check();
    ob_start('farm_inject_csrf');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-Content-Type-Options: nosniff');
    header('Referrer-Policy: same-origin');
}
