<?php
/* =========================================================
   login.php — Username + password (bcrypt via password_hash)
   ========================================================= */
require_once 'config.php';

if (!empty($_SESSION['user_id'])) { header("Location: dashboard.php"); exit; }

$error = "";
$ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
const MAX_ATTEMPTS = 5;          // failed logins allowed...
const LOCK_MINUTES = 15;         // ...per IP in this window

/* =========================================================
   LOGIN LOGIC
   ========================================================= */
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username'] ?? '');
    $password = (string) ($_POST['password'] ?? '');

    // Brute-force protection (table is created automatically if the migration was not run)
    $pdo->exec("CREATE TABLE IF NOT EXISTS login_attempts (
        id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        ip VARCHAR(45) NOT NULL,
        attempted_at DATETIME NOT NULL,
        KEY idx_ip_time (ip, attempted_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM login_attempts WHERE ip = ? AND attempted_at > (NOW() - INTERVAL " . LOCK_MINUTES . " MINUTE)");
    $stmt->execute([$ip]);
    $recentFailures = (int) $stmt->fetchColumn();

    if ($recentFailures >= MAX_ATTEMPTS) {
        $error = "Too many failed attempts. Please wait " . LOCK_MINUTES . " minutes and try again.";
    } elseif ($username === '' || $password === '') {
        $error = "Please fill in all fields.";
    } else {
        $stmt = $pdo->prepare("SELECT user_id, username, password FROM users WHERE username = ? LIMIT 1");
        $stmt->execute([$username]);
        $user = $stmt->fetch();

        $ok = false;
        if ($user) {
            $stored = (string) $user['password'];
            if (password_get_info($stored)['algo'] !== null) {
                $ok = password_verify($password, $stored);
            } else {
                // Legacy plain-text password: accept once, then upgrade to a hash
                $ok = hash_equals($stored, $password);
            }
            if ($ok && (password_get_info($stored)['algo'] === null || password_needs_rehash($stored, PASSWORD_DEFAULT))) {
                $up = $pdo->prepare("UPDATE users SET password = ? WHERE user_id = ?");
                $up->execute([password_hash($password, PASSWORD_DEFAULT), $user['user_id']]);
            }
        }

        if ($ok) {
            session_regenerate_id(true);
            $_SESSION['user_id']  = $user['user_id'];
            $_SESSION['username'] = $user['username'];
            $pdo->prepare("DELETE FROM login_attempts WHERE ip = ?")->execute([$ip]);
            header("Location: dashboard.php");
            exit;
        }

        $pdo->prepare("INSERT INTO login_attempts (ip, attempted_at) VALUES (?, NOW())")->execute([$ip]);
        $error = "Invalid username or password.";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Farm Project | Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">

    <style>
        :root {
            --brand-green: #3cff8f;
            --bg-dark: #05070a;
            --glass: rgba(18, 24, 33, 0.85);
            --border: rgba(255, 255, 255, 0.1);
            --input-bg: rgba(0, 0, 0, 0.4);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-dark);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: #fff;
            overflow: hidden;
            position: relative;
        }

        /* BACKGROUND IMAGE */
        .background-image {
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background-image: url('assets/img/dowloag.png');
            background-size: cover;
            background-position: center;
            z-index: -2;
        }

        .background-overlay {
            position: absolute;
            inset: 0;
            z-index: -1;
            background: linear-gradient(to bottom, rgba(5, 7, 10, 0.6), rgba(5, 7, 10, 0.85));
            backdrop-filter: blur(3px);
        }

        .login-card {
            background: var(--glass);
            backdrop-filter: blur(15px);
            -webkit-backdrop-filter: blur(15px);
            border: 1px solid var(--border);
            padding: 45px 40px;
            border-radius: 24px;
            width: 100%;
            max-width: 400px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.6);
            animation: fadeUp 0.8s ease-out;
            text-align: center;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        h2 {
            margin-bottom: 25px;
            font-weight: 600;
            letter-spacing: -0.5px;
            margin-top: 10px;
        }

        .input-group {
            margin-bottom: 20px;
            text-align: left;
        }

        .input-group label {
            display: block;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: rgba(255, 255, 255, 0.6);
            margin-bottom: 8px;
            font-weight: 600;
        }

        .input-field {
            position: relative;
        }

        .input-field i {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--brand-green);
            font-size: 1rem;
            transition: 0.3s;
            z-index: 10; /* Garante que fique sobre o input */
        }

        /* Classe específica para o ícone clicável */
        .toggle-password {
            cursor: pointer;
        }

        input {
            width: 100%;
            padding: 16px 45px 16px 16px;
            background: var(--input-bg);
            border: 1px solid var(--border);
            border-radius: 12px;
            color: #fff;
            font-size: 0.95rem;
            outline: none;
            transition: 0.3s;
        }

        input:focus {
            border-color: var(--brand-green);
            background: rgba(0,0,0,0.6);
            box-shadow: 0 0 0 4px rgba(60, 255, 143, 0.1);
        }

        /* Animação do ícone quando o input está focado */
        input:focus + i {
            transform: translateY(-50%) scale(1.1);
            filter: drop-shadow(0 0 5px var(--brand-green));
        }

        button {
            width: 100%;
            padding: 16px;
            background: var(--brand-green);
            border: none;
            border-radius: 12px;
            color: #05070a;
            font-weight: 700;
            font-size: 1rem;
            cursor: pointer;
            transition: 0.3s;
            margin-top: 15px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        button:hover {
            background: #6effad;
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(60, 255, 143, 0.25);
        }

        .footer-links {
            margin-top: 30px;
            font-size: 0.8rem;
            color: rgba(255, 255, 255, 0.4);
        }

        .footer-links a {
            color: var(--brand-green);
            text-decoration: none;
            font-weight: 600;
            transition: 0.2s;
        }

        .footer-links a:hover {
            text-decoration: underline;
            color: #fff;
        }

        .alert {
            background: rgba(239, 68, 68, 0.2);
            border: 1px solid rgba(239, 68, 68, 0.5);
            color: #fca5a5;
            padding: 12px;
            border-radius: 8px;
            font-size: 0.85rem;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
    </style>
</head>
<body>

<div class="background-image"></div>
<div class="background-overlay"></div>

<div class="login-card">

    <h2>Welcome</h2>

    <?php if(!empty($error)): ?>
        <div class="alert">
            <i class="fa-solid fa-circle-exclamation"></i>
            <?= htmlspecialchars($error) ?>
        </div>
    <?php endif; ?>

    <form action="login.php" method="POST">
        <div class="input-group">
            <label>Username</label>
            <div class="input-field">
                <input type="text" name="username" placeholder="Enter your username" required autocomplete="off">
                <i class="fa-solid fa-user"></i>
            </div>
        </div>

        <div class="input-group">
            <label>Password</label>
            <div class="input-field">
                <input type="password"
                       id="passwordInput"
                       name="password"
                       placeholder="Enter your password"
                       autocomplete="current-password"
                       required>

                <i class="fa-solid fa-eye toggle-password" id="togglePasswordIcon"></i>
            </div>
        </div>

        <button type="submit">Access System</button>
    </form>

    <div class="footer-links">
        <p>Forgot your password? <a href="index.html">Contact Support</a></p>
        <p style="margin-top: 15px; font-size: 0.75rem; opacity: 0.6;">
            © 2026 Farm Project
        </p>
    </div>

</div>

<script>
    const toggleIcon = document.getElementById('togglePasswordIcon');
    const passwordInput = document.getElementById('passwordInput');

    toggleIcon.addEventListener('click', function () {

        const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
        passwordInput.setAttribute('type', type);

        // Alterna o ícone (Olho aberto vs Olho fechado)
        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
    });
</script>

</body>
</html>