<?php
/* =========================================================
   reports_weight.php — Weight & Performance Analytics
   Style: Premium Glass (Cyan/Blue Theme)
   Features: PDF/Excel Export, ADG Projections, Company Header
   ========================================================= */
require_once 'config.php';

// 1. SEGURANÇA
if (!isset($conn)) { die("Database connection error."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

// 2. METADADOS PARA O RELATÓRIO (Usuário e Empresa)
$current_user = "Unknown User";
$stmt_u = $conn->prepare("SELECT username FROM users WHERE user_id = ?");
if ($stmt_u) {
    $stmt_u->bind_param("i", $_SESSION['user_id']);
    $stmt_u->execute();
    $res_u = $stmt_u->get_result();
    if ($u = $res_u->fetch_assoc()) $current_user = $u['username'];
}

$company_name_report = "Global Report (All Companies)";
if (!empty($_GET['company_id'])) {
    $stmt_c = $conn->prepare("SELECT name FROM company WHERE company_id = ?");
    $stmt_c->bind_param("i", $_GET['company_id']);
    $stmt_c->execute();
    $res_c = $stmt_c->get_result();
    if ($c = $res_c->fetch_assoc()) $company_name_report = $c['name'];
}

// 3. CONFIGURAÇÕES ZOOTÉCNICAS
$TARGET_MARKET_WEIGHT = 550; // Meta de Peso (kg)
$MIN_ACCEPTABLE_ADG = 0.800; // GMD Mínimo Aceitável

// 4. FILTROS
$where = ["1=1"];
$params = [];
$types = "";

// Data da Pesagem
if (!empty($_GET['date_range'])) {
    $dates = explode(" to ", $_GET['date_range']);
    if (count($dates) == 2) {
        $where[] = "w.weighing_date BETWEEN ? AND ?";
        $params[] = $dates[0]; $params[] = $dates[1]; $types .= "ss";
    }
}
// Empresa (Filtro via Lote)
if (!empty($_GET['company_id'])) {
    $where[] = "l.company_id = ?";
    $params[] = $_GET['company_id']; $types .= "i";
}
// Lote
if (!empty($_GET['lot_id'])) {
    $where[] = "la.lot_id = ?";
    $params[] = $_GET['lot_id']; $types .= "i";
}
// Raça
if (!empty($_GET['type_id'])) {
    $where[] = "a.type_id = ?";
    $params[] = $_GET['type_id']; $types .= "i";
}

$sql_where = implode(" AND ", $where);

// 5. QUERY PRINCIPAL (Última Pesagem por Animal)
$sql = "SELECT 
            a.animal_id, a.tag_number, a.sex,
            t.breed,
            l.name as lot_name,
            w.weight_kg as current_weight,
            w.daily_gain as adg,
            w.weighing_date
        FROM animal a
        JOIN weighing w ON a.animal_id = w.animal_id
        -- Garante que pegamos apenas a pesagem mais recente dentro do filtro
        JOIN (SELECT animal_id, MAX(weighing_date) as max_date FROM weighing GROUP BY animal_id) max_w 
            ON w.animal_id = max_w.animal_id AND w.weighing_date = max_w.max_date
        LEFT JOIN animal_types t ON a.type_id = t.type_id
        LEFT JOIN lot_animals la ON a.animal_id = la.animal_id AND la.exit_date IS NULL
        LEFT JOIN lot l ON la.lot_id = l.lot_id
        WHERE $sql_where
        ORDER BY w.weight_kg DESC";

$stmt = $conn->prepare($sql);
if (!empty($params)) { $stmt->bind_param($types, ...$params); }
$stmt->execute();
$result = $stmt->get_result();

// 6. PROCESSAMENTO DOS DADOS
$herd = [];
$stats = [
    'total_weight' => 0,
    'count' => 0,
    'avg_adg' => 0,
    'ready_market' => 0
];
$charts = [
    'distribution' => ['< 200kg'=>0, '200-300kg'=>0, '300-400kg'=>0, '400-500kg'=>0, '> 500kg'=>0],
    'performance' => ['Low (<0.8)'=>0, 'Good (0.8-1.2)'=>0, 'High (>1.2)'=>0]
];

while ($row = $result->fetch_assoc()) {
    $w = (float)$row['current_weight'];
    $adg = (float)$row['adg'];
    
    // Projeção de Abate
    $days_to_target = 0;
    $finish_date = "Ready";
    
    if ($w < $TARGET_MARKET_WEIGHT) {
        if ($adg > 0) {
            $remaining = $TARGET_MARKET_WEIGHT - $w;
            $days_to_target = ceil($remaining / $adg);
            $finish_date = date('d/m/Y', strtotime("+$days_to_target days"));
        } else {
            $finish_date = "Stalled"; // Sem ganho
        }
    } else {
        $stats['ready_market']++;
    }

    $row['days_left'] = $days_to_target;
    $row['finish_date'] = $finish_date;
    
    // Performance Class
    if ($adg < 0.8) { $pClass = 'danger'; $charts['performance']['Low (<0.8)']++; }
    elseif ($adg < 1.2) { $pClass = 'warning'; $charts['performance']['Good (0.8-1.2)']++; }
    else { $pClass = 'success'; $charts['performance']['High (>1.2)']++; }
    $row['perf_class'] = $pClass;

    // Distribuição de Peso
    if ($w < 200) $charts['distribution']['< 200kg']++;
    elseif ($w < 300) $charts['distribution']['200-300kg']++;
    elseif ($w < 400) $charts['distribution']['300-400kg']++;
    elseif ($w < 500) $charts['distribution']['400-500kg']++;
    else $charts['distribution']['> 500kg']++;

    $stats['total_weight'] += $w;
    $stats['avg_adg'] += $adg;
    $stats['count']++;
    
    $herd[] = $row;
}

// Médias Finais
$avg_weight = $stats['count'] > 0 ? round($stats['total_weight'] / $stats['count'], 1) : 0;
$avg_adg_total = $stats['count'] > 0 ? round($stats['avg_adg'] / $stats['count'], 3) : 0;

// Dropdowns
$lots = $conn->query("SELECT * FROM lot ORDER BY name");
$breeds = $conn->query("SELECT * FROM animal_types ORDER BY breed");
$companies = $conn->query("SELECT * FROM company ORDER BY name");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Weight Performance | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
    
    <style>
        /* --- PREMIUM GLASS (Cyan/Blue Theme) --- */
        :root {
            --accent: #0ea5e9; /* Sky Blue */
            --accent-dim: rgba(14, 165, 233, 0.15);
        }
        
        body {
            margin: 0; font-family: "Segoe UI", sans-serif;
            background: url('assets/img/dowloag.png') no-repeat center center fixed;
            background-size: cover; color: #fff;
            overflow-y: scroll;
        }
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(10, 15, 25, 0.85); z-index: -1;
        }

        /* Topbar */
        .topbar {
            background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(14, 165, 233, 0.3); padding: 0 40px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .brand { font-size: 22px; font-weight: 700; color: var(--accent); text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav a { color: #cbd5e1; text-decoration: none; font-size: 14px; font-weight: 500; transition: .3s; display: flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: 8px; }
        .nav a:hover { background: var(--accent-dim); color: var(--accent); }

        /* Layout */
        .main { max-width: 1400px; margin: 30px auto; padding: 0 20px; display: grid; grid-template-columns: 280px 1fr; gap: 30px; }
        
        .page-header { grid-column: 1 / -1; display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 10px; }
        .page-header h1 { font-size: 32px; font-weight: 700; margin: 0; text-shadow: 0 4px 20px rgba(0,0,0,0.5); }
        .page-header p { color: #cbd5e1; font-size: 14px; margin: 5px 0 0 0; }

        /* Glass Panel */
        .glass-panel {
            background: linear-gradient(145deg, rgba(255,255,255,0.06) 0%, rgba(255,255,255,0.02) 100%);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 20px; padding: 25px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            color: white; position: relative;
        }

        /* Form Inputs */
        .form-label { font-size: 11px; color: var(--accent); text-transform: uppercase; font-weight: 700; letter-spacing: 0.5px; margin-bottom: 5px; display: block; }
        .form-control, .form-select {
            background: rgba(0, 0, 0, 0.4) !important;
            border: 1px solid rgba(255,255,255,0.1) !important;
            color: #fff !important; border-radius: 8px; font-size: 13px; padding: 10px;
        }
        .form-control:focus { border-color: var(--accent) !important; outline: none; }

        .btn-action {
            background: var(--accent); color: #fff; font-weight: 700; border: none;
            padding: 10px; border-radius: 8px; width: 100%; transition: 0.2s; cursor: pointer;
        }
        .btn-action:hover { background: #0284c7; box-shadow: 0 0 15px rgba(14, 165, 233, 0.4); }
        
        .btn-outline {
            background: transparent; border: 1px solid rgba(255,255,255,0.2); color: #cbd5e1;
            padding: 8px 15px; border-radius: 8px; cursor: pointer; font-size: 13px; transition: 0.2s;
        }
        .btn-outline:hover { border-color: #fff; color: #fff; }

        /* KPIs */
        .kpi-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 25px; }
        .kpi-val { font-size: 28px; font-weight: 700; color: #fff; }
        .kpi-lbl { font-size: 11px; color: #9ca3af; text-transform: uppercase; letter-spacing: 1px; }

        /* Table */
        .glass-table { width: 100%; border-collapse: collapse; }
        .glass-table th { text-align: left; padding: 15px; color: var(--accent); font-size: 11px; text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .glass-table td { padding: 12px 15px; border-bottom: 1px solid rgba(255,255,255,0.03); font-size: 13px; vertical-align: middle; }
        .glass-table tr:hover td { background: rgba(255,255,255,0.02); }

        /* Performance Colors */
        .perf-dot { height: 8px; width: 8px; border-radius: 50%; display: inline-block; margin-right: 6px; }
        .p-high { background-color: #4ade80; box-shadow: 0 0 8px #4ade80; }
        .p-med { background-color: #facc15; }
        .p-low { background-color: #f87171; }

        @media (max-width: 992px) { .main { grid-template-columns: 1fr; } }
        #pdfMeta { display: none; }
    </style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-scale-balanced"></i> Weight Control</a>
    <div class="nav">
        <a href="dashboard.php"><i class="fa-solid fa-arrow-left"></i> Dashboard</a>
        <a href="weighing.php"><i class="fa-solid fa-plus"></i> New Weighing</a>
    </div>
</div>

<div class="main">
    
    <div class="page-header">
        <div>
            <h1>Performance Analytics</h1>
            <p>ADG analysis, herd evolution, and market projections.</p>
        </div>
        <div class="d-flex gap-2">
            <button class="btn-outline" onclick="generatePDF()"><i class="fa-solid fa-file-pdf text-danger"></i> Report PDF</button>
            <button class="btn-outline" onclick="exportExcel()"><i class="fa-solid fa-file-excel text-success"></i> Export Data</button>
        </div>
    </div>

    <aside>
        <div class="glass-panel">
            <h4 style="margin:0 0 20px 0; font-size:14px; color:var(--accent); text-transform:uppercase; letter-spacing:1px;">
                <i class="fa-solid fa-filter me-2"></i> Report Filters
            </h4>
            <form method="GET">
                <div class="mb-3">
                    <label class="form-label">Weighing Date Range</label>
                    <input type="text" name="date_range" id="dateRange" class="form-control" placeholder="Select period..." value="<?= htmlspecialchars($_GET['date_range'] ?? '') ?>">
                </div>

                <div class="mb-3">
                    <label class="form-label">Company</label>
                    <select name="company_id" class="form-select">
                        <option value="">All Companies</option>
                        <?php if($companies): while($c = $companies->fetch_assoc()): ?>
                            <option value="<?= e($c['company_id']) ?>" <?= ($_GET['company_id'] ?? '') == $c['company_id'] ? 'selected' : '' ?>>
                                <?= e($c['name']) ?>
                            </option>
                        <?php endwhile; endif; ?>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">Production Lot</label>
                    <select name="lot_id" class="form-select">
                        <option value="">All Lots</option>
                        <?php if($lots): while($l = $lots->fetch_assoc()): ?>
                            <option value="<?= e($l['lot_id']) ?>" <?= ($_GET['lot_id'] ?? '') == $l['lot_id'] ? 'selected' : '' ?>>
                                <?= e($l['name']) ?>
                            </option>
                        <?php endwhile; endif; ?>
                    </select>
                </div>

                <div class="mb-3">
                    <label class="form-label">Breed</label>
                    <select name="type_id" class="form-select">
                        <option value="">All Breeds</option>
                        <?php if($breeds): while($b = $breeds->fetch_assoc()): ?>
                            <option value="<?= e($b['type_id']) ?>" <?= ($_GET['type_id'] ?? '') == $b['type_id'] ? 'selected' : '' ?>>
                                <?= e($b['breed']) ?>
                            </option>
                        <?php endwhile; endif; ?>
                    </select>
                </div>

                <button type="submit" class="btn-action mt-3">Analyze</button>
                <a href="reports_weight.php" class="btn-outline mt-2 w-100 d-block text-center text-decoration-none">Reset</a>
            </form>
        </div>

        <div class="glass-panel mt-3" style="border-color: var(--accent); background: rgba(14, 165, 233, 0.05);">
            <div style="display:flex; gap:10px; align-items:start;">
                <i class="fa-solid fa-bullseye text-info mt-1"></i>
                <div>
                    <strong style="color:var(--accent); font-size:13px;">MARKET TARGET</strong>
                    <p style="font-size:12px; color:#cbd5e1; margin:5px 0 0 0;">
                        Target Weight: <strong><?= e($TARGET_MARKET_WEIGHT) ?>kg</strong><br>
                        Min. Expected ADG: <strong><?= e($MIN_ACCEPTABLE_ADG) ?>kg/day</strong>
                    </p>
                </div>
            </div>
        </div>
    </aside>

    <section>
        
        <div class="kpi-row">
            <div class="glass-panel">
                <div class="kpi-val"><?= e($avg_weight) ?> <small style="font-size:14px; color:#94a3b8">kg</small></div>
                <div class="kpi-lbl">Avg Herd Weight</div>
            </div>
            <div class="glass-panel" style="border-color: rgba(74,222,128,0.3)">
                <div class="kpi-val text-success">+<?= number_format($avg_adg_total, 3) ?> <small style="font-size:14px;">kg</small></div>
                <div class="kpi-lbl">Avg Daily Gain (ADG)</div>
            </div>
            <div class="glass-panel">
                <div class="kpi-val text-info"><?= e($stats['ready_market']) ?></div>
                <div class="kpi-lbl">Animals Ready (><?= e($TARGET_MARKET_WEIGHT) ?>kg)</div>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 25px;">
            <div class="glass-panel" style="height: 300px;">
                <h5 style="font-size:12px; color:#cbd5e1; margin-bottom:15px; text-transform:uppercase;">Weight Class Distribution</h5>
                <canvas id="distChart"></canvas>
            </div>
            <div class="glass-panel" style="height: 300px;">
                <h5 style="font-size:12px; color:#cbd5e1; margin-bottom:15px; text-transform:uppercase;">Performance</h5>
                <canvas id="perfChart"></canvas>
            </div>
        </div>

        <div class="glass-panel" style="padding:0; overflow:hidden;">
            <div style="padding:15px 20px; border-bottom:1px solid rgba(255,255,255,0.1); background:rgba(0,0,0,0.2);">
                <h3 style="margin:0; font-size:16px; color:#fff;">Individual Performance & Projection</h3>
            </div>
            <div style="overflow-x: auto;">
                <table class="glass-table" id="dataTable">
                    <thead>
                        <tr>
                            <th style="padding-left:20px;">Tag ID</th>
                            <th>Breed / Lot</th>
                            <th>Last Weighing</th>
                            <th>Current Weight</th>
                            <th>ADG (Gain)</th>
                            <th>Est. Finish Date</th>
                            <th>Performance</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (count($herd) > 0): foreach($herd as $row): ?>
                        <tr>
                            <td style="padding-left:20px;">
                                <strong class="text-white"><?= e($row['tag_number']) ?></strong>
                                <div style="font-size:10px; color:#94a3b8;"><?= ucfirst($row['sex']) ?></div>
                            </td>
                            <td>
                                <span style="color:#fff"><?= e($row['breed']) ?></span><br>
                                <small style="color:#94a3b8; font-size:10px;"><?= $row['lot_name'] ?: '-' ?></small>
                            </td>
                            <td style="color:#cbd5e1;"><?= date('d/m/Y', strtotime($row['weighing_date'])) ?></td>
                            <td>
                                <span style="font-size:15px; font-weight:700; color:#fff;"><?= e($row['current_weight']) ?></span> <small>kg</small>
                            </td>
                            <td>
                                <span class="<?= $row['adg'] >= 1.2 ? 'text-success' : ($row['adg'] < 0.8 ? 'text-danger' : 'text-warning') ?> fw-bold">
                                    <?= number_format($row['adg'], 3) ?>
                                </span> kg/d
                            </td>
                            <td>
                                <?php if($row['days_left'] == 0): ?>
                                    <span class="badge bg-success bg-opacity-25 text-success border border-success border-opacity-25" style="font-size:10px;">READY</span>
                                <?php else: ?>
                                    <div class="text-info"><?= e($row['finish_date']) ?></div>
                                    <small style="font-size:10px; color:#94a3b8;"><?= e($row['days_left']) ?> days left</small>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php 
                                    $dot = 'p-med';
                                    if($row['perf_class'] == 'success') $dot = 'p-high';
                                    if($row['perf_class'] == 'danger') $dot = 'p-low';
                                ?>
                                <span class="perf-dot <?= $dot ?>"></span> 
                                <span style="font-size:12px; color:#cbd5e1;"><?= ucfirst($row['perf_class'] == 'success' ? 'High' : ($row['perf_class'] == 'danger' ? 'Low' : 'Avg')) ?></span>
                            </td>
                        </tr>
                        <?php endforeach; else: ?>
                            <tr><td colspan="7" style="text-align:center; padding:30px; color:#94a3b8;">No records found.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </section>
</div>

<div id="pdfMeta" 
     data-user="<?= htmlspecialchars($current_user) ?>" 
     data-company="<?= htmlspecialchars($company_name_report) ?>" 
     data-date="<?= date('Y-m-d H:i') ?>"
     data-avg="<?= e($avg_weight) ?>"
     data-adg="<?= e($avg_adg_total) ?>">
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

<script>
    // 1. DATE PICKER
    flatpickr("#dateRange", { mode: "range", dateFormat: "Y-m-d", theme: "dark" });

    // 2. EXCEL
    function exportExcel() {
        const table = document.getElementById("dataTable");
        const wb = XLSX.utils.table_to_book(table, {sheet: "Weight_Performance"});
        XLSX.writeFile(wb, "Weight_Report.xlsx");
    }

    // 3. PDF REPORT (Standardized Header)
    function generatePDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('l', 'mm', 'a4'); // Landscape
        const meta = document.getElementById('pdfMeta').dataset;

        // --- Standard Dark Header ---
        doc.setFillColor(15, 23, 42); // Dark Navy/Black
        doc.rect(0, 0, 297, 35, 'F');
        
        // Report Title (Cyan for Weight Theme)
        doc.setTextColor(14, 165, 233); 
        doc.setFontSize(18);
        doc.setFont("helvetica", "bold");
        doc.text("WEIGHT PERFORMANCE REPORT", 14, 20);
        
        // Company Name (Right Align)
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(14);
        doc.text(meta.company, 283, 20, { align: 'right' });

        // Metadata (User + Date)
        doc.setFontSize(10);
        doc.setTextColor(150, 160, 170); // Gray
        doc.setFont("helvetica", "normal");
        doc.text(`Generated by: ${meta.user}  |  Date: ${meta.date}`, 14, 28);
        
        // Summary Strip (Blue Accent)
        doc.setFillColor(14, 165, 233);
        doc.rect(14, 40, 269, 1, 'F');
        
        doc.setTextColor(50, 50, 50);
        doc.text(`Avg Weight: ${meta.avg} kg  |  Avg ADG: ${meta.adg} kg/day  |  Target: 550kg`, 14, 48);

        // Table
        doc.autoTable({
            html: '#dataTable',
            startY: 55,
            theme: 'grid',
            headStyles: { 
                fillColor: [15, 23, 42], 
                textColor: [14, 165, 233], // Blue Text Header
                fontStyle: 'bold' 
            },
            styles: { fontSize: 9 },
            didParseCell: function(data) {
                // Strip HTML for clean PDF text
                if (data.cell.raw && data.cell.raw.innerText) {
                    data.cell.text = [data.cell.raw.innerText.replace(/[\r\n]+/g, " ").trim()];
                }
            }
        });

        // Footer
        const pages = doc.internal.getNumberOfPages();
        for(let i=1; i<=pages; i++){
            doc.setPage(i);
            doc.setFontSize(8);
            doc.setTextColor(150);
            doc.text(`Page ${i}/${pages}`, 283, 200, {align:'right'});
        }

        doc.save("Weight_Performance.pdf");
    }

    // 4. CHARTS
    const commonOpts = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { labels: { color: '#cbd5e1' } } },
        scales: {
            y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
            x: { grid: { display:false }, ticks: { color: '#94a3b8' } }
        }
    };

    // Distribution (Bar)
    new Chart(document.getElementById('distChart'), {
        type: 'bar',
        data: {
            labels: <?= json_encode(array_keys($charts['distribution']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
            datasets: [{
                label: 'Head Count',
                data: <?= json_encode(array_values($charts['distribution']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
                backgroundColor: '#0ea5e9',
                borderRadius: 4
            }]
        },
        options: commonOpts
    });

    // Performance (Doughnut)
    new Chart(document.getElementById('perfChart'), {
        type: 'doughnut',
        data: {
            labels: <?= json_encode(array_keys($charts['performance']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
            datasets: [{
                data: <?= json_encode(array_values($charts['performance']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
                backgroundColor: ['#f87171', '#facc15', '#4ade80'],
                borderColor: '#1e293b',
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'right', labels: { color: '#cbd5e1' } } }
        }
    });
</script>

</body>
</html>