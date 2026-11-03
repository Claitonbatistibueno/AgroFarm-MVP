<?php
/* =========================================================
   reports_animals.php — Advanced Livestock Analytics
   Style: Matched to Dashboard (Premium Glass)
   UPDATES: Fixed Lot Filtering, Dynamic Chart Colors
   ========================================================= */
require_once 'config.php';

// 1. Security & SETUP
if (!isset($conn)) { die("Erro crítico: Conexão DB ausente."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

// 2. Heater (Para o PDF)
$current_user = "User";
$stmt_u = $conn->prepare("SELECT username FROM users WHERE user_id = ?");
if ($stmt_u) {
    $stmt_u->bind_param("i", $_SESSION['user_id']);
    $stmt_u->execute();
    $res_u = $stmt_u->get_result();
    if ($u = $res_u->fetch_assoc()) $current_user = $u['username'];
}

// 3. FILTROS (Lógica Backend)
$where = ["1=1"];
$params = [];
$types = "";
$filter_desc = "Geral";

//  ID company o dropdown de lotes
$selected_company = !empty($_GET['company_id']) ? (int)$_GET['company_id'] : 0;

if (!empty($_GET['company_id'])) {
    $where[] = "l.company_id = ?"; $params[] = $_GET['company_id']; $types .= "i";
}
if (!empty($_GET['lot_id'])) {
    $where[] = "la.lot_id = ?"; $params[] = $_GET['lot_id']; $types .= "i";
}
if (!empty($_GET['status'])) {
    $where[] = "a.status = ?"; $params[] = $_GET['status']; $types .= "s";
}
if (!empty($_GET['type_id'])) {
    $where[] = "a.type_id = ?"; $params[] = $_GET['type_id']; $types .= "i";
}
if (!empty($_GET['date_range'])) {
    $dates = explode(" to ", $_GET['date_range']);
    if (count($dates) == 2) {
        $where[] = "a.birth_date BETWEEN ? AND ?";
        $params[] = $dates[0]; $params[] = $dates[1]; $types .= "ss";
    }
}

$sql_where = implode(" AND ", $where);

// 4. MAIN QUERY 
$sql = "SELECT 
            a.*, 
            t.breed, 
            l.name as lot_name, 
            c.country_name,
            (SELECT weight_kg FROM weighing w WHERE w.animal_id = a.animal_id ORDER BY weighing_date DESC LIMIT 1) as current_weight,
            (SELECT COALESCE(SUM(cost), 0) FROM health_records hr WHERE hr.animal_id = a.animal_id) as health_cost,
            (SELECT COALESCE(SUM(cost_value), 0) FROM operational_costs oc WHERE oc.animal_id = a.animal_id) as op_cost
        FROM animal a
        LEFT JOIN animal_types t ON a.type_id = t.type_id
        LEFT JOIN european_countries c ON a.country_id = c.country_id
        LEFT JOIN lot_animals la ON a.animal_id = la.animal_id AND la.exit_date IS NULL
        LEFT JOIN lot l ON la.lot_id = l.lot_id
        WHERE $sql_where
        ORDER BY a.animal_id DESC";

$stmt = $conn->prepare($sql);
if (!empty($params)) { $stmt->bind_param($types, ...$params); }
$stmt->execute();
$result = $stmt->get_result();

// 5. MATHS
$animals = [];
$stats = ['count' => 0, 'active' => 0, 'total_weight' => 0, 'total_cost' => 0, 'est_revenue' => 0];
$charts = ['status' => [], 'breed' => []];
$market_price = 3.20; // Preço base mercado

while ($row = $result->fetch_assoc()) {
    $weight = (float)$row['current_weight'];
    $cost = $row['health_cost'] + $row['op_cost'];
    $est_value = $weight * $market_price;
    $profit = $est_value - $cost;

    $row['total_cost'] = $cost;
    $row['est_value'] = $est_value;
    $row['profit'] = $profit;
    $animals[] = $row;

    $stats['count']++;
    if ($row['status'] == 'active') $stats['active']++;
    $stats['total_weight'] += $weight;
    $stats['total_cost'] += $cost;
    $stats['est_revenue'] += $est_value;

    $charts['status'][$row['status']] = ($charts['status'][$row['status']] ?? 0) + 1;
    $charts['breed'][$row['breed']] = ($charts['breed'][$row['breed']] ?? 0) + 1;
}

$avg_weight = $stats['count'] > 0 ? round($stats['total_weight'] / $stats['count'], 1) : 0;

// --- DROPDOWNS (CORREÇÃO 1 & 2: FILTRO DE LOTES) ---
$companies = $conn->query("SELECT * FROM company ORDER BY name");
$breeds = $conn->query("SELECT * FROM animal_types ORDER BY breed");

// Se uma empresa estiver selecionada, busca apenas os lotes dela
if ($selected_company > 0) {
    $lots = $conn->query("SELECT * FROM lot WHERE company_id = $selected_company ORDER BY name");
} else {
    // Se não, busca todos
    $lots = $conn->query("SELECT * FROM lot ORDER BY name");
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Animal Reports | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">

    <style>
        /* --- COPYING EXACT DASHBOARD STYLES --- */
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

        /* Topbar (Identical to Dashboard) */
        .topbar {
            background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255,255,255,0.1); padding: 0 40px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .brand { font-size: 22px; font-weight: 700; color: #4ade80; text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav { display: flex; gap: 20px; align-items: center; }
        .nav a { color: #cbd5e1; text-decoration: none; font-size: 14px; font-weight: 500; transition: .3s; display: flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: 8px; }
        .nav a:hover, .nav a.active { background: rgba(74, 222, 128, 0.15); color: #4ade80; }

        /* Dropdown (Identical to Dashboard) */
        .dropdown { position: relative; }
        .drop-menu { 
            display: none; position: absolute; top: 100%; right: 0;
            background: #1e293b; border: 1px solid rgba(255,255,255,0.1); 
            border-radius: 12px; width: 220px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); 
            padding: 8px 0; z-index: 1000; 
        }
        .dropdown:hover .drop-menu { display: block; }
        .drop-menu a { padding: 12px 20px; display: block; color: #cbd5e1; border-bottom: 1px solid rgba(255,255,255,0.02); }
        .drop-menu a:hover { background: rgba(74, 222, 128, 0.1); color: #4ade80; }

        /* --- LAYOUT GRID --- */
        .main { max-width: 1400px; margin: 30px auto; padding: 0 20px; min-height: 80vh; display: grid; grid-template-columns: 280px 1fr; gap: 30px; }
        
        .page-header { grid-column: 1 / -1; margin-bottom: 10px; display: flex; justify-content: space-between; align-items: flex-end; }
        .page-header h1 { font-size: 32px; font-weight: 700; margin: 0; text-shadow: 0 4px 20px rgba(0,0,0,0.5); }
        .page-header p { color: #cbd5e1; font-size: 14px; margin: 5px 0 0 0; }

        /* --- GLASS PANEL (Static version of Dashboard Card) --- */
        .glass-panel {
            background: linear-gradient(145deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
            backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.15);
            border-radius: 24px; padding: 25px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            color: white;
        }

        /* --- FORM ELEMENTS (Matte Style) --- */
        .form-label { font-size: 12px; color: #cbd5e1; text-transform: uppercase; font-weight: 700; margin-bottom: 6px; display: block; letter-spacing: 0.5px; }
        .form-control, .form-select {
            background: rgba(0, 0, 0, 0.3) !important;
            border: 1px solid rgba(255,255,255,0.1) !important;
            color: #fff !important;
            border-radius: 8px; padding: 10px; width: 100%;
            font-family: "Segoe UI", sans-serif; font-size: 14px;
            box-sizing: border-box; transition: 0.3s;
        }
        .form-control:focus, .form-select:focus { border-color: #4ade80 !important; outline: none; }
        
        /* Buttons */
        .btn-brand {
            background: #4ade80; color: #0f172a; font-weight: 700; border: none;
            padding: 12px; border-radius: 8px; width: 100%; cursor: pointer; transition: 0.2s;
        }
        .btn-brand:hover { background: #22c55e; transform: translateY(-2px); }
        
        .btn-outline {
            background: transparent; border: 1px solid rgba(255,255,255,0.2); color: #cbd5e1;
            padding: 8px 15px; border-radius: 8px; cursor: pointer; font-size: 13px; transition: 0.2s;
        }
        .btn-outline:hover { border-color: #fff; color: #fff; background: rgba(255,255,255,0.05); }

        /* --- KPI GRID (Mini Cards) --- */
        .kpi-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .kpi-card {
            background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08);
            border-radius: 16px; padding: 20px; display: flex; flex-direction: column;
        }
        .kpi-val { font-size: 28px; font-weight: 700; color: #fff; margin-bottom: 2px; }
        .kpi-lbl { font-size: 12px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; }
        .kpi-icon { color: #4ade80; font-size: 20px; margin-bottom: 10px; }

        /* --- TABLE STYLE --- */
        .table-container { overflow-x: auto; }
        .glass-table { width: 100%; border-collapse: collapse; }
        .glass-table th { 
            text-align: left; padding: 15px; color: #94a3b8; font-size: 12px; 
            text-transform: uppercase; border-bottom: 1px solid rgba(255,255,255,0.1); 
        }
        .glass-table td { 
            padding: 14px 15px; border-bottom: 1px solid rgba(255,255,255,0.03); 
            font-size: 14px; vertical-align: middle; 
        }
        .glass-table tr:last-child td { border-bottom: none; }
        .glass-table tr:hover td { background: rgba(255,255,255,0.02); }

        /* Status Colors */
        .st-active { color: #4ade80; background: rgba(74, 222, 128, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .st-sold { color: #facc15; background: rgba(250, 204, 21, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; }
        .st-dead { color: #f87171; background: rgba(248, 113, 113, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; text-transform: uppercase; }

        @media (max-width: 1024px) { .main { grid-template-columns: 1fr; } .kpi-row { grid-template-columns: 1fr 1fr; } }
        /* Hide Data for PDF Gen */
        #metaData { display: none; }
    </style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <div class="nav">
        <a href="dashboard.php"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php"><i class="fa-solid fa-cow"></i> Animals</a>
        <a href="feeding.php"><i class="fa-solid fa-bucket"></i> Feeding</a>
        
        <div class="dropdown">
            <a href="reports.php" class="active">
                <i class="fa-solid fa-chart-line"></i> Reports <i class="fa-solid fa-caret-down" style="font-size:10px;"></i>
            </a>
            <div class="drop-menu"> 
                <a href="reports_animals.php">Animal Reports</a>
                <a href="reports_weight.php">Weight Control</a>
                <a href="reports_financial.php">Financial Overview</a>
            </div>
        </div>
        
        <a href="dashboard.php?logout=true" style="color:#f87171"><i class="fa-solid fa-right-from-bracket"></i></a>
    </div>
</div>

<div class="main">
    
    <div class="page-header">
        <div>
            <h1>Animal Analytics</h1>
            <p>Detailed breakdown, financial analysis, and herd performance.</p>
        </div>
        <div style="display:flex; gap:10px;">
            <button class="btn-outline" onclick="generatePDF(true)"><i class="fa-solid fa-eye text-info"></i> Preview</button>
            <button class="btn-outline" onclick="generatePDF(false)"><i class="fa-solid fa-file-pdf text-danger"></i> PDF</button>
            <button class="btn-outline" onclick="exportExcel()"><i class="fa-solid fa-file-excel text-success"></i> Excel</button>
        </div>
    </div>

    <aside>
        <div class="glass-panel">
            <h4 style="margin:0 0 20px 0; font-size:16px; color:#4ade80; text-transform:uppercase; letter-spacing:1px;">
                <i class="fa-solid fa-filter me-2"></i> Filter Data
            </h4>
            <form method="GET" id="filterForm">
                <div class="mb-3">
                    <label class="form-label">Date Range</label>
                    <input type="text" name="date_range" id="dateRange" class="form-control" placeholder="Select..." value="<?= htmlspecialchars($_GET['date_range'] ?? '') ?>">
                </div>

                <div class="mb-3" style="margin-top:15px;">
                    <label class="form-label">Company</label>
                    <select name="company_id" class="form-select" onchange="document.getElementById('filterForm').submit()">
                        <option value="">All Companies</option>
                        <?php foreach($companies as $c): ?>
                            <option value="<?= e($c['company_id']) ?>" <?= ($selected_company == $c['company_id']) ? 'selected' : '' ?>><?= e($c['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="mb-3" style="margin-top:15px;">
                    <label class="form-label">Lot</label>
                    <select name="lot_id" class="form-select">
                        <option value="">All Lots</option>
                        <?php 
                        if($lots->num_rows > 0):
                            $lots->data_seek(0); // Reinicia o ponteiro
                            while($l = $lots->fetch_assoc()): ?>
                            <option value="<?= e($l['lot_id']) ?>" <?= ($_GET['lot_id'] ?? '') == $l['lot_id'] ? 'selected' : '' ?>><?= e($l['name']) ?></option>
                        <?php endwhile; endif; ?>
                    </select>
                </div>

                <div class="mb-3" style="margin-top:15px;">
                    <label class="form-label">Status</label>
                    <select name="status" class="form-select">
                        <option value="">Any Status</option>
                        <option value="active" <?= ($_GET['status'] ?? '') == 'active' ? 'selected' : '' ?>>Active</option>
                        <option value="sold" <?= ($_GET['status'] ?? '') == 'sold' ? 'selected' : '' ?>>Sold</option>
                        <option value="dead" <?= ($_GET['status'] ?? '') == 'dead' ? 'selected' : '' ?>>Dead</option>
                    </select>
                </div>

                <button type="submit" class="btn-brand" style="margin-top:25px;">Apply Filters</button>
                <a href="reports_animals.php" class="btn-outline" style="display:block; text-align:center; margin-top:10px; text-decoration:none;">Reset</a>
            </form>
        </div>
    </aside>

    <section>
        
        <div class="kpi-row">
            <div class="glass-panel kpi-card">
                <div class="kpi-icon"><i class="fa-solid fa-cow"></i></div>
                <div class="kpi-val"><?= e($stats['count']) ?></div>
                <div class="kpi-lbl">Animals Filtered</div>
            </div>
            <div class="glass-panel kpi-card">
                <div class="kpi-icon"><i class="fa-solid fa-scale-balanced"></i></div>
                <div class="kpi-val"><?= e($avg_weight) ?> <small style="font-size:14px; color:#94a3b8;">kg</small></div>
                <div class="kpi-lbl">Avg Weight</div>
            </div>
            <div class="glass-panel kpi-card">
                <div class="kpi-icon"><i class="fa-solid fa-sack-dollar"></i></div>
                <div class="kpi-val" style="color:#f87171">€<?= number_format($stats['total_cost'], 0) ?></div>
                <div class="kpi-lbl">Total Investment</div>
            </div>
            <div class="glass-panel kpi-card" style="border-color: rgba(74,222,128,0.3);">
                <div class="kpi-icon"><i class="fa-solid fa-chart-line"></i></div>
                <div class="kpi-val" style="color:#4ade80">€<?= number_format($stats['est_revenue'], 0) ?></div>
                <div class="kpi-lbl">Est. Market Value</div>
            </div>
        </div>

        <?php if($stats['count'] > 0): ?>
        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 30px;">
            <div class="glass-panel" style="height:300px;">
                <h5 style="margin:0 0 15px 0; font-size:14px; color:#cbd5e1;">BREED COMPOSITION</h5>
                <canvas id="breedChart"></canvas>
            </div>
            <div class="glass-panel" style="height:300px;">
                <h5 style="margin:0 0 15px 0; font-size:14px; color:#cbd5e1;">HERD STATUS</h5>
                <canvas id="statusChart"></canvas>
            </div>
        </div>
        <?php endif; ?>

        <div class="glass-panel" style="padding:0; overflow:hidden;">
            <div style="padding:20px; border-bottom:1px solid rgba(255,255,255,0.1);">
                <h3 style="margin:0; font-size:18px;">Detailed List</h3>
            </div>
            <div class="table-container">
                <table class="glass-table" id="reportTable">
                    <thead>
                        <tr>
                            <th style="padding-left:25px;">Tag ID</th>
                            <th>Details</th>
                            <th>Dates</th>
                            <th>Weight</th>
                            <th>Financials</th>
                            <th>Profit/Loss</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (count($animals) > 0): foreach($animals as $row): ?>
                        <tr>
                            <td style="padding-left:25px;">
                                <strong style="color:#fff;"><?= e($row['tag_number']) ?></strong><br>
                                <span style="font-size:11px; color:#94a3b8;"><?= ucfirst($row['sex']) ?></span>
                            </td>
                            <td>
                                <span style="color:#4ade80;"><?= e($row['breed']) ?></span><br>
                                <span style="font-size:11px; color:#94a3b8;"><?= $row['lot_name'] ?: '-' ?></span>
                            </td>
                            <td><?= date('d/m/y', strtotime($row['birth_date'])) ?></td>
                            <td style="font-weight:700;"><?= $row['current_weight'] ?: 0 ?> kg</td>
                            <td>
                                <div style="font-size:12px;">Inv: €<?= number_format($row['total_cost'], 0) ?></div>
                                <div style="font-size:12px; color:#4ade80;">Est: €<?= number_format($row['est_value'], 0) ?></div>
                            </td>
                            <td>
                                <?php $profClass = $row['profit'] >= 0 ? '#4ade80' : '#f87171'; ?>
                                <strong style="color:<?= e($profClass) ?>">
                                    <?= $row['profit'] >= 0 ? '+' : '' ?><?= number_format($row['profit'], 2) ?>
                                </strong>
                            </td>
                            <td>
                                <span class="st-<?= e($row['status']) ?>"><?= e($row['status']) ?></span>
                            </td>
                        </tr>
                        <?php endforeach; else: ?>
                            <tr><td colspan="7" style="text-align:center; padding:30px; color:#94a3b8;">No data found.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </section>
</div>

<div id="metaData" 
     data-user="<?= htmlspecialchars($current_user) ?>" 
     data-date="<?= date('d/m/Y') ?>"
     data-count="<?= e($stats['count']) ?>"
     data-avg="<?= e($avg_weight) ?>"
     data-cost="€<?= number_format($stats['total_cost'], 2) ?>">
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
        const table = document.getElementById("reportTable");
        const wb = XLSX.utils.table_to_book(table, {sheet: "Animals"});
        XLSX.writeFile(wb, "Farm_Report.xlsx");
    }

    // 3. PDF GENERATION
    function generatePDF(preview) {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const meta = document.getElementById('metaData').dataset;

        // Dark Header
        doc.setFillColor(15, 23, 42); 
        doc.rect(0, 0, 210, 40, 'F');

        doc.setTextColor(255, 255, 255);
        doc.setFontSize(18);
        doc.setFont("helvetica", "bold");
        doc.text("FARM ANALYTICS REPORT", 14, 20);

        doc.setFontSize(10);
        doc.setFont("helvetica", "normal");
        doc.setTextColor(148, 163, 184); // Slate-400
        doc.text(`Generated by: ${meta.user}`, 14, 28);
        doc.text(`Date: ${meta.date}`, 14, 33);

        // Stats Bar
        doc.setFillColor(74, 222, 128); // Green Accent
        doc.rect(14, 45, 182, 1, 'F');
        
        doc.setTextColor(50, 50, 50);
        doc.setFontSize(10);
        doc.text(`Total Animals: ${meta.count}   |   Avg Weight: ${meta.avg}kg   |   Investment: ${meta.cost}`, 14, 52);

        // Table
        doc.autoTable({
            html: '#reportTable',
            startY: 60,
            theme: 'grid',
            headStyles: { fillColor: [30, 41, 59], textColor: [74, 222, 128], fontStyle: 'bold' },
            bodyStyles: { textColor: [50, 50, 50] },
            alternateRowStyles: { fillColor: [245, 245, 245] },
            didParseCell: function(data) {
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
            doc.text(`Page ${i}/${pages}`, 196, 290, {align:'right'});
        }

        if(preview) window.open(doc.output('bloburl'), '_blank');
        else doc.save('Farm_Report.pdf');
    }

    // 4. CHARTS (UPDATED LOGIC)
    <?php if($stats['count'] > 0): ?>
    const commonOpts = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { labels: { color: '#cbd5e1' } } },
        scales: {
            y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#94a3b8' } },
            x: { grid: { display:false }, ticks: { color: '#94a3b8' } }
        }
    };

    // --- CORREÇÃO 3: Cores para o gráfico de raças (Color Cycle) ---

    const breedPalette = [
        '#4ade80', // Green
        '#60a5fa', // Blue
        '#c084fc', // Purple
        '#f472b6', // Pink
        '#fb923c', // Orange
        '#2dd4bf', // Teal
        '#94a3b8'  // Gray
    ];

    new Chart(document.getElementById('breedChart'), {
        type: 'bar',
        data: {
            labels: <?= json_encode(array_keys($charts['breed']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
            datasets: [{
                label: 'Animals',
                data: <?= json_encode(array_values($charts['breed']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
                // Aplica a paleta ciclicamente
                backgroundColor: breedPalette,
                borderRadius: 6
            }]
        },
        options: commonOpts
    });

    // --- CORREÇÃO 4: Cores Mapeadas para o Status (Verde, Vermelho, Amarelo) ---
    const statusLabels = <?= json_encode(array_keys($charts['status']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
    const statusData = <?= json_encode(array_values($charts['status']), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;

    // Mapa fixo de cores
    const statusColorMap = {
        'active': '#4ade80', // Green
        'sold': '#facc15',   // Yellow
        'dead': '#f87171'    // Red
    };

    // Gera o array de cores na mesma ordem das labels
    const statusColors = statusLabels.map(label => statusColorMap[label] || '#94a3b8');

    new Chart(document.getElementById('statusChart'), {
        type: 'doughnut',
        data: {
            labels: statusLabels,
            datasets: [{
                data: statusData,
                backgroundColor: statusColors, // Cores mapeadas
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
    <?php endif; ?>
</script>

</body>
</html>