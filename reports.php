<?php 
/* =========================================================
   reports.php — Reports Hub
   ========================================================= */
require_once 'reports_init.php'; 

// --- USER DETECTION LOGIC ---
// Checks multiple possible session keys to ensure the name is captured
$user_name = 'User';
if (isset($_SESSION['user_name']) && !empty($_SESSION['user_name'])) {
    $user_name = $_SESSION['user_name'];
} elseif (isset($_SESSION['name']) && !empty($_SESSION['name'])) {
    $user_name = $_SESSION['name'];
} elseif (isset($_SESSION['usuario_nome']) && !empty($_SESSION['usuario_nome'])) {
    $user_name = $_SESSION['usuario_nome'];
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Reports Hub | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        /* --- MATTE GLASS THEME --- */
        body {
            margin: 0; 
            font-family: "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background: url('assets/img/dowloag.png') no-repeat center center fixed;
            background-size: cover; 
            color: #fff;
            min-height: 100vh;
        }
        
        /* Depth Overlay */
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.75); z-index: -1;
        }

        /* Topbar / Navbar */
        .topbar {
            background: rgba(15, 23, 42, 0.85); 
            backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255,255,255,0.1); 
            padding: 0 40px; 
            height: 64px;
            display: flex; 
            align-items: center; 
            justify-content: space-between;
            position: sticky; 
            top: 0; 
            z-index: 100;
        }
        .brand { font-size: 22px; font-weight: 700; color: #4ade80; text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav-links { display: flex; gap: 25px; }
        .nav-links a { color: #94a3b8; text-decoration: none; font-size: 14px; font-weight: 500; transition: 0.3s; }
        .nav-links a:hover, .nav-links a.active { color: #4ade80; }

        .main-container { 
            max-width: 1200px; 
            margin: 60px auto; 
            padding: 0 20px; 
            animation: fadeIn 0.8s ease-out; 
        }

        @keyframes fadeIn { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }

        .welcome-section { margin-bottom: 50px; text-align: center; }
        .welcome-section h1 { font-size: 38px; font-weight: 800; margin-bottom: 12px; letter-spacing: -0.5px; }
        .welcome-section p { color: #94a3b8; font-size: 18px; }
        .user-highlight { color: #4ade80; font-weight: 700; border-bottom: 2px solid rgba(74, 222, 128, 0.3); }

        /* REPORTS GRID */
        .report-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); 
            gap: 25px; 
        }

        .report-card {
            background: rgba(25, 25, 25, 0.6); 
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1); 
            border-radius: 24px; 
            padding: 30px;
            text-decoration: none;
            color: #fff;
            display: flex;
            flex-direction: column;
            gap: 20px;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
        }

        .report-card::after {
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(135deg, rgba(74, 222, 128, 0.1) 0%, transparent 100%);
            opacity: 0; transition: 0.4s;
        }

        .report-card:hover {
            transform: translateY(-10px);
            border-color: rgba(74, 222, 128, 0.5);
            background: rgba(30, 30, 30, 0.85);
            box-shadow: 0 20px 40px rgba(0,0,0,0.4);
        }

        .report-card:hover::after { opacity: 1; }

        .card-icon {
            width: 60px; height: 60px;
            background: rgba(74, 222, 128, 0.1);
            border-radius: 18px;
            display: flex; align-items: center; justify-content: center;
            font-size: 26px;
            color: #4ade80;
            transition: 0.3s;
        }
        .report-card:hover .card-icon { background: #4ade80; color: #000; transform: scale(1.1); }

        .card-body h3 { margin: 0; font-size: 22px; font-weight: 700; margin-bottom: 10px; }
        .card-body p { margin: 0; font-size: 15px; color: #94a3b8; line-height: 1.6; }

        .card-footer {
            display: flex; align-items: center; justify-content: space-between;
            margin-top: auto; padding-top: 25px;
            border-top: 1px solid rgba(255,255,255,0.08);
        }
        .btn-label { font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.2px; color: #4ade80; }
        .card-footer i { font-size: 16px; color: #4ade80; transition: 0.3s; }
        .report-card:hover .card-footer i { transform: translateX(8px); }

        /* Responsive Optimization */
        @media (max-width: 768px) {
            .topbar { padding: 0 20px; }
            .nav-links { display: none; }
            .report-grid { grid-template-columns: 1fr; }
            .welcome-section h1 { font-size: 28px; }
        }
    </style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Analytics</a>
    <div class="nav-links">
        <a href="dashboard.php">Dashboard</a>
        <a href="animal.php">Animals</a>
        <a href="weighing.php">Weighing</a>
        <a href="Feeding.php">Feeding</a> 
        <a href="reports.php" class="active">Reports</a>
        <a href="login.php" style="color:#f87171;">Logout</a>
    </div>
</div>

<div class="main-container">
    <div class="welcome-section">
        <h1>Reports Center</h1>
     </span> Select a module to generate audits and detailed analytics.</p>
    </div>

    <div class="report-grid">
        <a href="reports_animals.php" class="report-card">
            <div class="card-icon"><i class="fa-solid fa-cow"></i></div>
            <div class="card-body">
                <h3>Animal Inventory</h3>
                <p>Complete herd status, origin details, breed statistics, and density reports by production lot.</p>
            </div>
            <div class="card-footer">
                <span class="btn-label">Open Audit</span>
                <i class="fa-solid fa-arrow-right"></i>
            </div>
        </a>

        <a href="reports_weight.php" class="report-card">
            <div class="card-icon"><i class="fa-solid fa-scale-balanced"></i></div>
            <div class="card-body">
                <h3>Weight & Performance</h3>
                <p>ADG (Average Daily Gain) analysis, growth history, and weight projections for optimal harvesting.</p>
            </div>
            <div class="card-footer">
                <span class="btn-label">View Performance</span>
                <i class="fa-solid fa-arrow-right"></i>
            </div>
        </a>

        <a href="reports_health.php" class="report-card">
            <div class="card-icon"><i class="fa-solid fa-heart-pulse"></i></div>
            <div class="card-body">
                <h3>Health & Sanitary</h3>
                <p>Clinical history, treatment logs, mandatory withdrawal periods, and detailed veterinary costs.</p>
            </div>
            <div class="card-footer">
                <span class="btn-label">Run Sanitary Audit</span>
                <i class="fa-solid fa-arrow-right"></i>
            </div>
        </a>

        <a href="reports_financial.php" class="report-card">
            <div class="card-icon"><i class="fa-solid fa-sack-dollar"></i></div>
            <div class="card-body">
                <h3>Financial Dashboard</h3>
                <p>Consolidated financial overview covering operational, feeding, and medical expenses by period.</p>
            </div>
            <div class="card-footer">
                <span class="btn-label">Cost Analysis</span>
                <i class="fa-solid fa-arrow-right"></i>
            </div>
        </a>

        <a href="reports_feeding.php" class="report-card">
            <div class="card-icon"><i class="fa-solid fa-wheat-awn"></i></div>
            <div class="card-body">
                <h3>Nutrition Management</h3>
                <p>Feeding logs, supplement tracking, and detailed feed consumption analysis by production group.</p>
            </div>
            <div class="card-footer">
                <span class="btn-label">Check Consumption</span>
                <i class="fa-solid fa-arrow-right"></i>
            </div>
        </a>
    </div>
</div>

</body>
</html>