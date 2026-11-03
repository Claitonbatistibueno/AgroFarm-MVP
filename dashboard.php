<?php
/* =========================================================
   dashboard.php — Farm Management Overview
   LAYOUT: Glass Premium | IA: Floating Button
   ========================================================= */

require_once 'config.php';
if (isset($_GET['logout'])) { session_destroy(); header("Location: login.php"); exit; }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }


// KPIs
$activeAnimals = (int)$pdo->query("SELECT COUNT(*) FROM animal WHERE status='active'")->fetchColumn();
$lots = (int)$pdo->query("SELECT COUNT(DISTINCT lot_id) FROM lot_animals WHERE exit_date IS NULL")->fetchColumn();
$operationalCost = (float)$pdo->query("SELECT COALESCE(SUM(cost_value),0) FROM operational_costs")->fetchColumn();
$feedingCost = (float)$pdo->query("SELECT COALESCE(SUM(df.quantity_kg * f.cost_per_kg),0) FROM daily_feeding df JOIN feed f ON f.feed_id = df.feed_id")->fetchColumn();
$medicalCost = (float)$pdo->query("SELECT COALESCE(SUM(cost),0) FROM health_records")->fetchColumn();
$totalCost = $operationalCost + $feedingCost + $medicalCost;
$avgGain = (float)$pdo->query("SELECT COALESCE(AVG(daily_gain),0) FROM weighing WHERE daily_gain IS NOT NULL")->fetchColumn();
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Farm Project | Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<style>
    /* BASE THEME */
    body {
        margin: 0; font-family: "Segoe UI", sans-serif;
        background: url('assets/img/dowloag.png') no-repeat center center fixed;
        background-size: cover; color: #fff; overflow-x: hidden;
    }
    body::before { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(10, 15, 25, 0.75); z-index: -1; }

    /* TOPBAR */
    .topbar {
        background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(15px);
        border-bottom: 1px solid rgba(255,255,255,0.1); padding: 0 40px; height: 64px;
        display: flex; align-items: center; justify-content: space-between; position: sticky; top: 0; z-index: 100;
    }
    .brand { font-size: 22px; font-weight: 700; color: #4ade80; text-decoration: none; display: flex; align-items: center; gap: 10px; }
    .nav { display: flex; gap: 20px; align-items: center; }
    .nav a { color: #cbd5e1; text-decoration: none; font-size: 14px; font-weight: 500; transition: .3s; display: flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: 8px; }
    .nav a:hover, .nav a.active { background: rgba(74, 222, 128, 0.15); color: #4ade80; }

    /* DROPDOWN & ICONS */
    .dropdown { position: relative; }
    .drop-menu {
        display: none; position: absolute; top: 100%; right: 0; background: #1e293b;
        border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; width: 240px; padding: 8px 0; z-index: 1000;
        box-shadow: 0 10px 40px rgba(0,0,0,0.5);
    }
    .dropdown:hover .drop-menu { display: block; animation: fadeIn 0.2s ease; }
    .drop-menu a { padding: 12px 20px; display: flex; align-items: center; gap: 12px; color: #cbd5e1; text-decoration: none; font-size: 14px; }
    .drop-menu a:hover { background: rgba(74, 222, 128, 0.1); color: #4ade80; }
    .drop-menu i { width: 20px; text-align: center; color: #64748b; } /* Icon color */
    .drop-menu a:hover i { color: #4ade80; }

    /* MAIN CONTENT */
    .main { max-width: 1200px; margin: 40px auto; padding: 0 20px; animation: slideUp 0.6s ease; }
    @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 24px; margin-top: 30px; }

    .glass-card {
        background: rgba(255,255,255,0.05); backdrop-filter: blur(20px);
        border: 1px solid rgba(255,255,255,0.15); border-radius: 24px;
        padding: 30px; text-decoration: none; color: white; transition: 0.4s;
        display: flex; flex-direction: column; justify-content: space-between; min-height: 160px;
    }
    .glass-card:hover { transform: translateY(-8px); border-color: #4ade80; box-shadow: 0 15px 30px rgba(0,0,0,0.3); }
    .card-icon { font-size: 32px; color: #4ade80; margin-bottom: 15px; }
    .card-value { font-size: 36px; font-weight: 700; }
    .card-label { font-size: 13px; color: #cbd5e1; text-transform: uppercase; letter-spacing: 1px; }

    /* FLOATING AI BUTTON */
    .ai-fab {
        position: fixed; bottom: 30px; right: 30px;
        width: 60px; height: 60px; border-radius: 50%;
        background: linear-gradient(135deg, #4f46e5, #9333ea);
        display: flex; align-items: center; justify-content: center;
        color: white; font-size: 24px; box-shadow: 0 10px 30px rgba(79, 70, 229, 0.5);
        cursor: pointer; transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        z-index: 999; border: 2px solid rgba(255,255,255,0.2);
        text-decoration: none;
    }
    .ai-fab:hover { transform: scale(1.1) rotate(10deg); box-shadow: 0 0 20px #a855f7; }
    .ai-fab::after {
        content: ""; position: absolute; width: 100%; height: 100%; border-radius: 50%;
        border: 2px solid #a855f7; opacity: 0; animation: pulse 2s infinite;
    }
    @keyframes pulse { 0% { transform: scale(1); opacity: 0.8; } 100% { transform: scale(1.6); opacity: 0; } }

</style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <div class="nav">
        <a href="dashboard.php" class="active"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php"><i class="fa-solid fa-cow"></i> Animals</a>
        <a href="feeding.php"><i class="fa-solid fa-bucket"></i> Feeding</a>
        <a href="weighing.php"><i class="fa-solid fa-scale-balanced"></i> Weighing</a>
        <a href="financial_dashboard.php"><i class="fa-solid fa-coins"></i> Finance</a>

        <div class="dropdown">
            <a href="reports.php"><i class="fa-solid fa-chart-line"></i> Reports <i class="fa-solid fa-caret-down"></i></a>
            <div class="drop-menu">
                <a href="reports_animals.php"><i class="fa-solid fa-list-ol"></i> Animal Census</a>
                <a href="reports_weight.php"><i class="fa-solid fa-weight-hanging"></i> Weight & Growth</a>
                <a href="reports_health.php"><i class="fa-solid fa-user-doctor"></i> Health Records</a>
                <a href="reports_financial.php"><i class="fa-solid fa-file-invoice-dollar"></i> Financial</a>
                <a href="reports_feeding.php"><i class="fa-solid fa-wheat-awn"></i> Consumption</a>
            </div>
        </div>

        <div class="dropdown">
            <a href="#"><i class="fa-solid fa-gear"></i> Admin <i class="fa-solid fa-caret-down"></i></a>
            <div class="drop-menu">
                <a href="settings.php"><i class="fa-solid fa-sliders"></i> System Settings</a>
                <a href="suppliers_list.php"><i class="fa-solid fa-truck-field"></i> Suppliers</a>
                <a href="clients.php"><i class="fa-solid fa-handshake"></i> Clients</a>
                <a href="medical_catalog.php"><i class="fa-solid fa-prescription-bottle-medical"></i> Med. Catalog</a>
                <a href="breeds.php"><i class="fa-solid fa-dna"></i> Breeds</a>
                <a href="users.php"><i class="fa-solid fa-users-gear"></i> User Manager</a>
            </div>
        </div>
        <a href="dashboard.php?logout=true" style="color:#f87171"><i class="fa-solid fa-right-from-bracket"></i></a>
    </div>
</div>

<main class="main">
    <div class="page-header">
        <h1>Dashboard</h1>
        <p style="color: #94a3b8;">Welcome back, Manager.</p>
    </div>

    <div class="grid">
        <a href="animal.php" class="glass-card">
            <div><div class="card-icon"><i class="fa-solid fa-cow"></i></div>
            <div class="card-value"><?= e($activeAnimals) ?></div>
            <div class="card-label">Active Animals</div></div>
        </a>
        <a href="reports_financial.php" class="glass-card">
            <div><div class="card-icon"><i class="fa-solid fa-sack-dollar"></i></div>
            <div class="card-value">€<?= number_format($totalCost, 0, ',', '.') ?></div>
            <div class="card-label">Total Investment</div></div>
        </a>
        <a href="weighing.php" class="glass-card">
            <div><div class="card-icon"><i class="fa-solid fa-scale-balanced"></i></div>
            <div class="card-value"><?= number_format($avgGain, 2) ?> <small>kg/day</small></div>
            <div class="card-label">Avg. Daily Gain</div></div>
        </a>
        <a href="animal.php" class="glass-card">
            <div><div class="card-icon"><i class="fa-solid fa-layer-group"></i></div>
            <div class="card-value"><?= e($lots) ?></div>
            <div class="card-label">Active Lots</div></div>
        </a>
    </div>
</main>

<a href="ai_vision.php" class="ai-fab" title="AI Smart Vision">
    <i class="fa-solid fa-wand-magic-sparkles"></i>
</a>

</body>
</html>