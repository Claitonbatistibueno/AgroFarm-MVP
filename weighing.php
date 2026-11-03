<?php
/* =========================================================
   weighing.php — Weighing Station
   Style: Premium Glass (Full Width Button & Download)
   Features: Save CSV on Server, Download Link, Operation History
   ========================================================= */
require_once 'config.php';

// Security Check
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

/* -------- Helpers -------- */
function h($v) { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }

/* -------- Fetch Active Animals -------- */
$animalsList = [];
try {
    $stmtAnimals = $conn->query("SELECT animal_id, tag_number FROM animal WHERE status = 'active' ORDER BY tag_number ASC");
    $animalsList = $stmtAnimals->fetch_all();
} catch (Exception $e) { }

/* -------- Logic: Calculate Daily Gain (ADG) -------- */
function calculateGain($conn, $animalId, $currentDate, $currentWeight) {
    $stmt = $conn->prepare("
        SELECT weighing_date, weight_kg 
        FROM weighing 
        WHERE animal_id = ? AND weighing_date < ? 
        ORDER BY weighing_date DESC LIMIT 1
    ");
    $stmt->bind_param("is", $animalId, $currentDate);
    $stmt->execute();
    $result = $stmt->get_result();
    $last = $result->fetch_assoc();

    if ($last) {
        $lastDate = new DateTime($last['weighing_date']);
        $currDate = new DateTime($currentDate);
        $interval = $lastDate->diff($currDate);
        $days = $interval->days;

        if ($days > 0) {
            $gain = ($currentWeight - $last['weight_kg']) / $days;
            return round($gain, 3);
        }
    }
    return null;
}

/* -------- Variables & Logic -------- */
$msg = "";
$msgType = ""; 
$previewData = [];
$importSummary = []; 
$viewState = 'dashboard';

/* -------- Handle Deletion -------- */
if (isset($_POST['delete_id'])) {
    $delId = (int)$_POST['delete_id'];
    $stmt = $conn->prepare("DELETE FROM weighing WHERE weighing_id = ?");
    $stmt->bind_param("i", $delId);
    if($stmt->execute()){
        $msg = "Record deleted successfully.";
        $msgType = "success";
    } else {
        $msg = "Error deleting record.";
        $msgType = "error";
    }
}

/* -------- Handle Form Actions -------- */
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    // --- 1. MANUAL ENTRY ---
    if ($action === 'manual_entry') {
        $animal_id = $_POST['animal_id'] ?? '';
        $date      = $_POST['weighing_date'];
        $weight    = floatval($_POST['weight_kg']);

        if ($animal_id) {
            $stmtOp = $conn->prepare("INSERT INTO weighing_operations (operation_type, records_count, user_id) VALUES ('manual', 1, ?)");
            $stmtOp->bind_param("i", $_SESSION['user_id']);
            $stmtOp->execute();
            $op_id = $conn->insert_id;

            $adg = calculateGain($conn, $animal_id, $date, $weight);
            $stmtInsert = $conn->prepare("INSERT INTO weighing (animal_id, weighing_date, weight_kg, daily_gain, source, operation_id) VALUES (?, ?, ?, ?, 'manual', ?)");
            $stmtInsert->bind_param("isddi", $animal_id, $date, $weight, $adg, $op_id);
            
            if($stmtInsert->execute()){
                $msg = "Weighing saved successfully!";
                $msgType = "success";
            }
        } else {
            $msg = "Error: Please select an animal.";
            $msgType = "error";
        }
    }

    // --- 2. UPLOAD CSV (Saves File to Server) ---
    elseif ($action === 'upload_csv') {
        if (isset($_FILES['csv_file']) && $_FILES['csv_file']['error'] == 0) {
            
            // 1-3. Validate + store (only .csv/.txt, random name)
            $targetPath  = safe_upload($_FILES['csv_file'], 'imports', ['csv', 'txt']);
            $newFileName = $targetPath ? basename($targetPath) : null;

            if ($targetPath) {
                
                // 4. Read from the SAVED file
                $handle = fopen($targetPath, "r");
                while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
                    if(count($data) < 3) continue;
                    $tag = trim($data[0]);
                    $date = trim($data[1]); 
                    $weight = floatval($data[2]);

                    $stmt = $conn->prepare("SELECT animal_id FROM animal WHERE tag_number = ?");
                    $stmt->bind_param("s", $tag);
                    $stmt->execute();
                    $res = $stmt->get_result();
                    $animal = $res->fetch_assoc();

                    $previewData[] = [
                        'animal_id' => $animal ? $animal['animal_id'] : null,
                        'tag' => $tag,
                        'date' => $date,
                        'weight' => $weight,
                        'adg' => $animal ? calculateGain($conn, $animal['animal_id'], $date, $weight) : null,
                        'exists' => $animal ? true : false
                    ];
                }
                fclose($handle);
                
                // Store Data AND Filename in Session
                $_SESSION['import_preview'] = $previewData;
                $_SESSION['import_saved_filename'] = $newFileName; 
                $_SESSION['import_display_name'] = $_FILES['csv_file']['name']; 
                
                $viewState = 'preview';
            } else {
                $msg = "Error uploading file to server.";
                $msgType = "error";
            }
        }
    }

    // --- 3. CONFIRM IMPORT ---
    elseif ($action === 'confirm_import') {
        $dataToSave = $_SESSION['import_preview'] ?? [];
        $savedFilename = $_SESSION['import_saved_filename'] ?? null;
        
        $count = 0;
        $successLog = [];

        if (!empty($dataToSave)) {
            $countValid = 0;
            foreach ($dataToSave as $r) { if($r['animal_id']) $countValid++; }

            // Save Operation
            $stmtOp = $conn->prepare("INSERT INTO weighing_operations (operation_type, records_count, source_file, user_id) VALUES ('import', ?, ?, ?)");
            $stmtOp->bind_param("isi", $countValid, $savedFilename, $_SESSION['user_id']);
            $stmtOp->execute();
            $op_id = $conn->insert_id;

            foreach ($dataToSave as $row) {
                if ($row['animal_id']) {
                    $stmt = $conn->prepare("INSERT INTO weighing (animal_id, weighing_date, weight_kg, daily_gain, source, source_file, operation_id) VALUES (?, ?, ?, ?, 'import', ?, ?)");
                    $stmt->bind_param("isddsi", $row['animal_id'], $row['date'], $row['weight'], $row['adg'], $savedFilename, $op_id);
                    $stmt->execute();
                    $count++;
                    $successLog[] = $row;
                }
            }
        }
        
        // Mantemos o nome do arquivo numa variável antes de limpar a sessão, para exibir no resumo
        $displayFilename = $savedFilename;
        
        unset($_SESSION['import_preview'], $_SESSION['import_saved_filename'], $_SESSION['import_display_name']);
        $importSummary = $successLog;
        $viewState = 'summary';
        $msg = "Success! $count records imported.";
        $msgType = "success";
    }
    
    // --- 4. CANCEL ---
    elseif ($action === 'cancel_import') {
        unset($_SESSION['import_preview'], $_SESSION['import_saved_filename'], $_SESSION['import_display_name']);
        $viewState = 'dashboard';
    }
}

/* -------- Fetch List -------- */
$op_filter = "";
$limit_sql = "LIMIT 50";
$list_title = "Recent Activity (All)";

$lastOp = $conn->query("SELECT MAX(operation_id) as last_id FROM weighing_operations")->fetch_assoc();
if ($lastOp['last_id']) {
    $op_filter = "AND w.operation_id = " . $lastOp['last_id'];
    $list_title = "Latest Operation Details";
    $limit_sql = ""; 
}

if (isset($_GET['show_all'])) {
    $op_filter = "";
    $list_title = "All Recent Activity";
    $limit_sql = "LIMIT 100";
}

$sql_weighings = "
    SELECT w.*, a.tag_number, l.name as lot_name
    FROM weighing w
    JOIN animal a ON a.animal_id = w.animal_id
    LEFT JOIN lot_animals la ON a.animal_id = la.animal_id AND la.exit_date IS NULL
    LEFT JOIN lot l ON la.lot_id = l.lot_id
    WHERE 1=1 $op_filter
    ORDER BY w.weighing_date DESC, w.created_at DESC, w.weighing_id DESC
    $limit_sql
";
$weighings = $conn->query($sql_weighings);

// KPIs
$todayWeight = $conn->query("SELECT COUNT(*) as c FROM weighing WHERE weighing_date = CURRENT_DATE")->fetch_assoc()['c'];
$avgGainAllQuery = $conn->query("SELECT AVG(daily_gain) as avg_g FROM weighing WHERE daily_gain IS NOT NULL")->fetch_assoc();
$avgGainAll = (float)$avgGainAllQuery['avg_g'];

// Logs
$historyLogs = $conn->query("SELECT * FROM weighing_operations ORDER BY operation_date DESC LIMIT 20");
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Weighing | Farm Project</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<style>
    /* --- PREMIUM GLASS THEME --- */
    :root {
        --brand: #4ade80;
        --text: #eaf1ff;
        --muted: #9fb0d0;
        --bg-dark: #05070a;
        --input-bg: rgba(0,0,0,0.3);
        --border: rgba(255, 255, 255, 0.15);
    }
    body {
        margin: 0; font-family: "Segoe UI", sans-serif;
        background: url('assets/img/dowloag.png') no-repeat center center fixed;
        background-size: cover; color: #fff;
        overflow-y: scroll;
    }
    body::before {
        content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(10, 15, 25, 0.7); z-index: -1;
    }

    /* Topbar */
    .topbar { background: rgba(15, 23, 42, 0.9); padding: 0 40px; height: 64px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); backdrop-filter: blur(15px); position: sticky; top: 0; z-index: 100; }
    .brand { font-size: 22px; font-weight: 700; color: var(--brand); text-decoration: none; display: flex; align-items: center; gap: 10px; }
    .nav { display: flex; gap: 20px; align-items: center; }
    .nav a { color: var(--muted); text-decoration: none; font-size: 14px; font-weight: 500; transition: .3s; display: flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: 8px; }
    .nav a:hover, .nav a.active { background: rgba(74, 222, 128, 0.15); color: var(--brand); }

    .main { max-width: 1200px; margin: 40px auto; padding: 0 20px 100px 20px; animation: fadeIn 0.6s ease; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

    /* Cards */
    .glass-card {
        background: linear-gradient(145deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.03) 100%);
        backdrop-filter: blur(20px); border: 1px solid var(--border);
        border-radius: 24px; padding: 30px; margin-bottom: 24px;
        box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
    }
    .glass-card h3 { margin: 0 0 20px 0; font-size: 18px; color: var(--brand); text-transform: uppercase; letter-spacing: 1px; display: flex; align-items: center; gap: 10px; }

    /* KPI Boxes */
    .kpi-row { display: flex; gap: 20px; align-items: stretch; }
    .kpi-box {
        background: linear-gradient(145deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
        backdrop-filter: blur(10px);
        border: 1px solid rgba(255,255,255,0.2);
        border-radius: 16px;
        padding: 12px 20px;
        display: flex; align-items: center; gap: 15px;
        min-width: 160px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        transition: transform 0.2s;
    }
    .kpi-box:hover { transform: translateY(-2px); border-color: var(--brand); }
    .kpi-icon {
        font-size: 20px; color: var(--brand);
        background: rgba(74, 222, 128, 0.15);
        width: 40px; height: 40px;
        display: flex; align-items: center; justify-content: center;
        border-radius: 50%;
    }
    .kpi-content { display: flex; flex-direction: column; }
    .kpi-label { font-size: 11px; text-transform: uppercase; color: var(--muted); letter-spacing: 0.5px; font-weight: 600; }
    .kpi-value { font-size: 18px; font-weight: 700; color: #fff; line-height: 1.2; }

    /* Inputs */
    input, select { 
        width: 100%; padding: 12px; background: var(--input-bg) !important; 
        border: 1px solid var(--border) !important; border-radius: 10px; 
        color: white !important; outline: none; transition: .2s; 
    }
    input:focus, select:focus { border-color: var(--brand) !important; background: rgba(0,0,0,0.5) !important; }
    select option { background-color: #0f131a; color: white; padding: 10px; }
    label { display: block; font-size: 12px; color: var(--muted); margin-bottom: 6px; font-weight: 600; }

    /* Buttons */
    .btn-primary { background: var(--brand); color: #0f172a; border: none; padding: 10px 24px; border-radius: 50px; font-weight: 700; transition: .2s; }
    .btn-primary:hover { background: #22c55e; transform: translateY(-2px); box-shadow: 0 0 15px rgba(74,222,128,0.4); }
    
    .btn-sec { background: rgba(255,255,255,0.1); color: white; border: 1px solid rgba(255,255,255,0.2); border-radius: 50px; padding: 10px 20px; text-decoration: none; font-size: 13px; display:inline-flex; align-items:center; gap:8px;}
    .btn-sec:hover { background: rgba(255,255,255,0.2); color:white; }

    /* Table */
    .table { --bs-table-bg: transparent; --bs-table-color: var(--text); --bs-table-border-color: var(--border); margin-bottom: 0; }
    .table thead th { border-bottom: 1px solid var(--border); color: var(--muted); font-weight: 600; text-transform: uppercase; font-size: 12px; }
    .table tbody td { border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle; }
    .gain-pos { color: var(--brand); font-weight: 700; }
    .gain-neg { color: #f87171; font-weight: 700; }

    /* Upload Box */
    .upload-box { border: 2px dashed rgba(255,255,255,0.2); border-radius: 12px; padding: 30px; text-align: center; transition: .2s; cursor: pointer; }
    .upload-box:hover { border-color: var(--brand); background: rgba(74, 222, 128, 0.05); }

    /* Modals */
    .modal-content { background-color: #111827; color: var(--text); border: 1px solid var(--border); border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.8); }
    .modal-header, .modal-footer { border-color: var(--border); }
    .btn-close { filter: invert(1); }

    /* Dropdown */
    .dropdown { position: relative; }
    .drop-menu { display: none; position: absolute; top: 100%; right: 0; background: #1e293b; border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; width: 220px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); padding: 8px 0; z-index: 1000; }
    .dropdown:hover .drop-menu { display: block; }
    .drop-menu a { padding: 12px 20px; display: block; color: var(--muted); text-decoration: none; }
    .drop-menu a:hover { background: rgba(74, 222, 128, 0.1); color: var(--brand); }
</style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <div class="nav">
        <a href="dashboard.php">Overview</a>
        <a href="animal.php">Animals</a>
        <a href="feeding.php">Feeding</a>
        <a href="weighing.php" class="active">Weighing</a>
        <a href="reports.php?reset=1">Reports</a>
        
        <div class="dropdown">
            <a href="#"><i class="fa-solid fa-gear"></i> Admin <i class="fa-solid fa-caret-down" style="font-size:10px"></i></a>
            <div class="drop-menu">
                <a href="settings.php">Company Settings</a>
                <a href="suppliers_list.php">Suppliers</a>
                <a href="medical_catalog.php">Medical Catalog</a>
                <a href="breeds.php">Animal Breeds</a>
                <a href="users.php">User Management</a>
            </div>
        </div>
        <a href="dashboard.php?logout=true" style="color:#f87171"><i class="fa-solid fa-right-from-bracket"></i></a>
    </div>
</div>

<main class="main">

    <div class="page-header">
        <div>
            <h1>Weighing Station</h1>
            <p>Monitor herd growth and performance.</p>
        </div>
        <div class="kpi-row">
            <div class="kpi-box">
                <div class="kpi-icon"><i class="fa-solid fa-scale-balanced"></i></div>
                <div class="kpi-content">
                    <span class="kpi-label">Today</span>
                    <span class="kpi-value"><?= e($todayWeight) ?></span>
                </div>
            </div>
            
            <div class="kpi-box">
                <div class="kpi-icon"><i class="fa-solid fa-chart-line"></i></div>
                <div class="kpi-content">
                    <span class="kpi-label">Avg Gain</span>
                    <span class="kpi-value"><?= number_format($avgGainAll, 3) ?> kg/d</span>
                </div>
            </div>

            <button class="btn btn-sec h-100" onclick="showHistoryModal()">
                <i class="fa-solid fa-clock-rotate-left"></i> History
            </button>
        </div>
    </div>

    <?php if($msg): ?>
        <div class="alert alert-<?= $msgType == 'error' ? 'danger' : 'success' ?> d-flex align-items-center">
            <i class="fa-solid <?= $msgType == 'error' ? 'fa-triangle-exclamation' : 'fa-circle-check' ?> me-2"></i>
            <?= h($msg) ?>
        </div>
    <?php endif; ?>

    <?php if($viewState === 'preview'): ?>
        <div class="glass-card" style="border-color: #facc15;">
            <h3 style="color: #facc15;"><i class="fa-solid fa-eye"></i> Import Preview (Step 1/2)</h3>
            <p style="color:var(--muted); margin-bottom:20px;">Review data before saving. Rows in red will be skipped.</p>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr><th>Tag</th><th>Date</th><th>Weight</th><th>Calculated ADG</th><th>Status</th></tr>
                    </thead>
                    <tbody>
                        <?php foreach($previewData as $p): ?>
                        <tr style="<?= !$p['exists'] ? 'color: #f87171;' : '' ?>">
                            <td><?= h($p['tag']) ?></td>
                            <td><?= h($p['date']) ?></td>
                            <td><?= number_format($p['weight'], 2) ?> kg</td>
                            <td><?= $p['adg'] ? h($p['adg'])." kg/d" : "-" ?></td>
                            <td><?= $p['exists'] ? "Ready" : "Tag Not Found" ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            <div style="display:flex; gap:15px; margin-top:20px;">
                <form method="POST" style="flex:1">
                    <input type="hidden" name="action" value="confirm_import">
                    <button type="submit" class="btn btn-primary w-100">Confirm & Save</button>
                </form>
                <form method="POST" style="flex:1">
                    <input type="hidden" name="action" value="cancel_import">
                    <button type="submit" class="btn btn-sec w-100 justify-content-center">Cancel</button>
                </form>
            </div>
        </div>

    <?php elseif($viewState === 'summary'): ?>
        <div class="glass-card" style="border-color: var(--brand);">
            <h3><i class="fa-solid fa-circle-check"></i> Import Successful</h3>
            
            <?php if(isset($displayFilename) && $displayFilename): ?>
            <div style="background: rgba(255,255,255,0.05); padding: 15px; border-radius: 12px; border: 1px solid var(--border); margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <span style="color:var(--muted); font-size:12px; text-transform:uppercase; display:block; margin-bottom:4px;">Archived Source File</span>
                    <span style="color:#fff; font-weight:600;"><i class="fa-solid fa-file-csv me-2" style="color:var(--brand)"></i><?= h($displayFilename) ?></span>
                </div>
                <a href="uploads/imports/<?= h($displayFilename) ?>" class="btn btn-sec btn-sm" download>
                    <i class="fa-solid fa-download"></i> Download
                </a>
            </div>
            <?php endif; ?>

            <p style="color:var(--muted); margin-bottom:20px;">The following records have been processed and saved.</p>
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead><tr><th>Status</th><th>Tag</th><th>Date</th><th>Weight</th><th>ADG</th></tr></thead>
                    <tbody>
                        <?php foreach($importSummary as $s): ?>
                        <tr>
                            <td style="color:var(--brand)"><i class="fa-solid fa-check"></i> Saved</td>
                            <td><strong><?= h($s['tag']) ?></strong></td>
                            <td><?= h($s['date']) ?></td>
                            <td><?= number_format($s['weight'], 2) ?> kg</td>
                            <td><?= $s['adg'] ? h($s['adg'])." kg/d" : "-" ?></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
            
            <div style="margin-top:20px;">
                <a href="weighing.php" class="btn btn-primary w-100 d-flex justify-content-center">Finish & Return</a>
            </div>
        </div>

    <?php else: ?>
        <div class="row">
            <div class="col-md-6 mb-4">
                <div class="glass-card h-100">
                    <h3><i class="fa-solid fa-pen-to-square"></i> Manual Entry</h3>
                    <form method="POST">
                        <input type="hidden" name="action" value="manual_entry">
                        <div class="form-group mb-3">
                            <label>Animal Tag</label>
                            <select name="animal_id" required class="form-select">
                                <option value="" disabled selected>Select an animal...</option>
                                <?php foreach($animalsList as $a): ?>
                                    <option value="<?= e($a['animal_id']) ?>"><?= h($a['tag_number']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="row g-3">
                            <div class="col-6">
                                <label>Date</label>
                                <input type="date" name="weighing_date" value="<?= date('Y-m-d') ?>" required class="form-control">
                            </div>
                            <div class="col-6">
                                <label>Weight (kg)</label>
                                <input type="number" step="0.01" name="weight_kg" placeholder="0.00" required class="form-control">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 mt-4">Save Record</button>
                    </form>
                </div>
            </div>

            <div class="col-md-6 mb-4">
                <div class="glass-card h-100">
                    <h3><i class="fa-solid fa-file-csv"></i> Import File</h3>
                    <form method="POST" enctype="multipart/form-data" class="h-100 d-flex flex-column justify-content-center">
                        <input type="hidden" name="action" value="upload_csv">
                        <label class="upload-box w-100">
                            <i class="fa-solid fa-cloud-arrow-up" style="font-size:32px; color:var(--muted); margin-bottom:10px; display:block;"></i>
                            <span style="font-size:13px; color:var(--muted)">Click to select CSV file</span>
                            <input type="file" name="csv_file" accept=".csv" required style="display:none;" onchange="this.form.submit()">
                        </label>
                        <p style="font-size:12px; color:var(--muted); margin-top:15px; text-align:center;">
                            Format: Tag, Date (YYYY-MM-DD), Weight
                        </p>
                    </form>
                </div>
            </div>
        </div>

        <div class="glass-card">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h3><i class="fa-solid fa-list-check"></i> <?= $list_title ?></h3>
                <?php if($op_filter): ?>
                    <a href="weighing.php?show_all=1" class="btn btn-sm btn-sec">Show All Records</a>
                <?php endif; ?>
            </div>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr><th>Date</th><th>Tag</th><th>Lot</th><th>Weight</th><th>ADG</th><th>Source</th><th>Action</th></tr>
                    </thead>
                    <tbody>
                        <?php while($row = $weighings->fetch_assoc()): ?>
                        <tr>
                            <td><?= date('d/m/Y', strtotime($row['weighing_date'])) ?></td>
                            <td style="font-weight:700; color:white;"><?= h($row['tag_number']) ?></td>
                            <td style="color:var(--muted)"><?= h($row['lot_name'] ?: '-') ?></td>
                            <td><?= number_format($row['weight_kg'], 2) ?> kg</td>
                            <td class="<?= $row['daily_gain'] >= 0 ? 'gain-pos' : 'gain-neg' ?>">
                                <?= $row['daily_gain'] !== null ? ($row['daily_gain'] >= 0 ? '+' : '').$row['daily_gain'] : "-" ?>
                            </td>
                            <td>
                                <span class="badge bg-dark border border-secondary" style="text-transform:uppercase; font-size:10px;">
                                    <?= h($row['source']) ?>
                                </span>
                            </td>
                            <td>
                                <button class="btn btn-sm text-danger border-0 bg-transparent" onclick="confirmDelete(<?= e($row['weighing_id']) ?>)">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </td>
                        </tr>
                        <?php endwhile; ?>
                    </tbody>
                </table>
            </div>
        </div>
    <?php endif; ?>

</main>

<div class="modal fade" id="historyModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header border-bottom-0">
                <h5 class="modal-title text-white"><i class="fa-solid fa-clock-rotate-left me-2"></i> Operation History</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="table-responsive">
                    <table class="table table-hover table-sm">
                        <thead>
                            <tr><th>Date</th><th>Type</th><th>File / Info</th><th>Records</th></tr>
                        </thead>
                        <tbody>
                            <?php while($log = $historyLogs->fetch_assoc()): ?>
                            <tr>
                                <td><?= date('d/m/Y H:i', strtotime($log['operation_date'])) ?></td>
                                <td>
                                    <?php if($log['operation_type']=='import'): ?>
                                        <span class="badge bg-primary bg-opacity-25 text-primary border border-primary">IMPORT</span>
                                    <?php else: ?>
                                        <span class="badge bg-success bg-opacity-25 text-success border border-success">MANUAL</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if($log['operation_type']=='import' && $log['source_file']): ?>
                                        <a href="uploads/imports/<?= h($log['source_file']) ?>" class="file-link" download>
                                            <i class="fa-solid fa-file-csv"></i> <?= h($log['source_file']) ?>
                                        </a>
                                    <?php else: ?>
                                        <span class="text-muted small">Single Entry</span>
                                    <?php endif; ?>
                                </td>
                                <td class="text-white fw-bold"><?= e($log['records_count']) ?></td>
                            </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border: 1px solid #f87171;">
            <div class="modal-body text-center p-4">
                <i class="fa-solid fa-triangle-exclamation text-danger mb-3" style="font-size: 40px;"></i>
                <h5 class="text-white mb-2">Delete Record?</h5>
                <p class="text-muted small">This action cannot be undone.</p>
                <form method="POST" class="mt-4">
                    <input type="hidden" name="delete_id" id="delete_id_input">
                    <button type="button" class="btn btn-sec me-2" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger rounded-pill px-4">Yes, Delete</button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var historyModal = new bootstrap.Modal(document.getElementById('historyModal'));
    var deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));

    function showHistoryModal() { historyModal.show(); }
    function confirmDelete(id) {
        document.getElementById('delete_id_input').value = id;
        deleteModal.show();
    }
</script>
</body>
</html>