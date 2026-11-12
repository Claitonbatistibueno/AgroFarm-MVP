<?php
/* =========================================================
   reports_health.php — Professional Sanitary Audit
   Style: Dark Matte Glass (Matched with Dashboard)
   Features: Extended Filters (Company, Breed, Lot, Vet Dropdown)
   Export: PDF & Excel Integration
   ========================================================= */
require_once 'config.php';

if (!isset($conn)) { die("Database connection error."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

// --- CORREÇÃO 2: IDENTIFICAR NOME DO USUÁRIO ---
$user_id = $_SESSION['user_id'];
$stmtUser = $conn->prepare("SELECT full_name FROM users WHERE user_id = ?");
$stmtUser->bind_param("i", $user_id);
$stmtUser->execute();
$resUser = $stmtUser->get_result();
$userData = $resUser->fetch_assoc();
// Se não achar nome, usa 'System User'
$user_name = $userData['full_name'] ?? 'System User'; 


// --- 1. FETCH FILTER DATA ---
$companies = $conn->query("SELECT * FROM company ORDER BY name");


if (!empty($_GET['company_id'])) {
    $company_filter_id = (int)$_GET['company_id'];
    $lots = $conn->query("SELECT * FROM lot WHERE company_id = $company_filter_id ORDER BY name");
} else {
    $lots = $conn->query("SELECT * FROM lot ORDER BY name");
}

$breeds = $conn->query("SELECT * FROM animal_types ORDER BY breed");
// Fetch Suppliers for Veterinarian Dropdown
$vets = $conn->query("SELECT * FROM suppliers ORDER BY name"); 
$med_types = $conn->query("SELECT type FROM medical_catalog GROUP BY type ORDER BY CASE type WHEN 'medicine' THEN 1 WHEN 'vaccine' THEN 2 WHEN 'service' THEN 3 WHEN 'equipment' THEN 4 ELSE 5 END");


// --- 2. FILTER LOGIC ---
$where = ["1=1"];
$params = [];
$types = "";

// Date Range
if (!empty($_GET['date_range'])) {
    $dates = explode(" to ", $_GET['date_range']);
    if (count($dates) == 2) {
        $where[] = "hr.treatment_date BETWEEN ? AND ?";
        $params[] = $dates[0]; $params[] = $dates[1]; $types .= "ss";
    }
}
// Medicine Type
if (!empty($_GET['med_type'])) {
    $where[] = "mc.type = ?";
    $params[] = $_GET['med_type']; $types .= "s";
}
// Veterinarian (Dropdown now)
if (!empty($_GET['vet_name'])) {
    $where[] = "hr.vet_name = ?";
    $params[] = $_GET['vet_name']; $types .= "s";
}
// Company Filter (via Lot)
if (!empty($_GET['company_id'])) {
    $where[] = "l.company_id = ?";
    $params[] = $_GET['company_id']; $types .= "i";
}
// Lot Filter
if (!empty($_GET['lot_id'])) {
    $where[] = "la.lot_id = ?";
    $params[] = $_GET['lot_id']; $types .= "i";
}
// Breed Filter
if (!empty($_GET['type_id'])) {
    $where[] = "a.type_id = ?";
    $params[] = $_GET['type_id']; $types .= "i";
}

$sql_where = implode(" AND ", $where);

// --- 3. MAIN QUERY ---
$sql = "SELECT 
            hr.record_id, hr.treatment_date, hr.diagnosis, hr.vet_name, hr.cost,
            a.tag_number, a.status as animal_status,
            mc.item_name, mc.type as med_type, mc.withdrawal_days,
            l.name as lot_name, t.breed,
            c.name as company_name
        FROM health_records hr
        JOIN animal a ON hr.animal_id = a.animal_id
        LEFT JOIN medical_catalog mc ON hr.item_id = mc.item_id
        LEFT JOIN animal_types t ON a.type_id = t.type_id
        LEFT JOIN lot_animals la ON a.animal_id = la.animal_id AND la.exit_date IS NULL
        LEFT JOIN lot l ON la.lot_id = l.lot_id
        LEFT JOIN company c ON l.company_id = c.company_id
        WHERE $sql_where
        ORDER BY hr.treatment_date DESC, hr.record_id DESC";

$stmt = $conn->prepare($sql);
if (!empty($params)) { $stmt->bind_param($types, ...$params); }
$stmt->execute();
$result = $stmt->get_result();

$records = [];
$stats = ['total_cases' => 0, 'blocked_animals' => 0, 'total_cost' => 0];
$today = new DateTime();
// Valor padrão em Inglês
$display_company = "All Companies"; 

while ($row = $result->fetch_assoc()) {
    $withdrawal_days = isset($row['withdrawal_days']) ? (int)$row['withdrawal_days'] : 0; 
    $treat_date = new DateTime($row['treatment_date']);
    $clear_date = clone $treat_date;
    $clear_date->modify("+$withdrawal_days days");
    
    $is_blocked = ($withdrawal_days > 0 && $clear_date > $today);
    $row['is_blocked'] = $is_blocked;
    $row['days_remaining'] = $is_blocked ? $today->diff($clear_date)->days : 0;

    $stats['total_cases']++;
    $stats['total_cost'] += $row['cost'];
    if ($is_blocked) $stats['blocked_animals']++;
    
    // Identificar empresa para o cabeçalho do PDF se houver filtro
    if(!empty($row['company_name'])) { $display_company = $row['company_name']; }

    $records[] = $row;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Sanitary Audit | Farm Project</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">

    <style>
        /* --- MATTE GLASS THEME (INTEGRAL) --- */
        body {
            margin: 0; font-family: "Segoe UI", sans-serif;
            background: url('assets/img/dowloag.png') no-repeat center center fixed;
            background-size: cover; color: #fff;
        }
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0, 0, 0, 0.65); z-index: -1;
        }

        .topbar {
            background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255,255,255,0.1); padding: 0 40px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .brand { font-size: 22px; font-weight: 700; color: #4ade80; text-decoration: none; }

        .main { max-width: 1400px; margin: 40px auto; padding: 0 20px; display: grid; grid-template-columns: 320px 1fr; gap: 30px; }
        
        /* Sidebar & Filters */
        .filter-panel {
            background: rgba(25, 25, 25, 0.7); backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1); border-radius: 24px; padding: 30px;
        }
        .filter-title { color: #4ade80; font-size: 0.85rem; text-transform: uppercase; font-weight: 800; letter-spacing: 1.5px; margin-bottom: 25px; display: flex; align-items: center; gap: 10px; }
        
        .form-group { margin-bottom: 20px; }
        .form-label { font-size: 11px; color: #94a3b8; text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 8px; letter-spacing: 0.5px; }
        .form-control, .form-select {
            background: rgba(255, 255, 255, 0.05) !important;
            border: 1px solid rgba(255,255,255,0.1) !important;
            color: #fff !important; border-radius: 10px; padding: 10px 12px; font-size: 13px; width: 100%;
        }
        .form-control:focus, .form-select:focus { border-color: #4ade80 !important; outline: none; background: rgba(0,0,0,0.4) !important; }
        
        .btn-run {
            background: #4ade80; color: #000; font-weight: 700; border: none;
            padding: 14px; border-radius: 12px; width: 100%; cursor: pointer; transition: 0.3s; margin-top: 15px;
        }
        .btn-run:hover { background: #22c55e; transform: translateY(-2px); }

        /* Estilos dos Novos Botões de Exportação */
        .export-actions { display: flex; gap: 10px; }
        .btn-export {
            background: rgba(255,255,255,0.05); color: #fff; border: 1px solid rgba(255,255,255,0.1);
            padding: 8px 15px; border-radius: 8px; cursor: pointer; font-size: 12px; font-weight: 600;
            display: flex; align-items: center; gap: 8px; transition: 0.3s;
        }
        .btn-export:hover { background: rgba(255,255,255,0.15); border-color: #4ade80; }

        /* Inspection Note */
        .note-box {
            background: rgba(251, 191, 36, 0.1); border: 1px solid rgba(251, 191, 36, 0.3);
            border-radius: 18px; padding: 20px; margin-top: 25px; display: flex; gap: 15px;
        }
        .note-text { font-size: 12px; color: #cbd5e1; line-height: 1.6; }
        .note-text strong { color: #fbbf24; text-transform: uppercase; }

        /* KPIs */
        .kpi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .kpi-card {
            background: rgba(255,255,255,0.06); backdrop-filter: blur(20px);
            border: 1px solid rgba(255,255,255,0.1); border-radius: 24px; padding: 25px;
        }
        .kpi-icon { font-size: 24px; color: #4ade80; margin-bottom: 12px; }
        .kpi-val { font-size: 32px; font-weight: 700; color: #fff; margin: 0; }
        .kpi-lbl { font-size: 12px; color: #94a3b8; text-transform: uppercase; font-weight: 600; margin-top: 5px; }

        /* Table */
        .table-panel { background: rgba(20, 20, 20, 0.6); border-radius: 24px; border: 1px solid rgba(255,255,255,0.1); overflow: hidden; }
        .glass-table { width: 100%; border-collapse: collapse; }
        .glass-table th { background: rgba(255,255,255,0.03); text-align: left; padding: 18px; color: #4ade80; font-size: 11px; text-transform: uppercase; }
        .glass-table td { padding: 15px 18px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 14px; vertical-align: middle; }
        
        .badge-blocked { background: rgba(251, 191, 36, 0.15); color: #fbbf24; border: 1px solid rgba(251, 191, 36, 0.3); padding: 5px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; }
        .badge-clear { background: rgba(74, 222, 128, 0.1); color: #4ade80; border: 1px solid rgba(74, 222, 128, 0.3); padding: 5px 10px; border-radius: 6px; font-size: 11px; font-weight: 700; }
        
        /* Mobile */
        @media (max-width: 992px) { .main { grid-template-columns: 1fr; } .kpi-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Analytics</a>
    <div style="display:flex; gap:20px;">
        <a href="dashboard.php" style="color:#fff; text-decoration:none; font-size:14px;">Dashboard</a>
        <a href="reports.php" style="color:#4ade80; text-decoration:none; font-size:14px;">Reports</a>
    </div>
</div>

<div class="main">
    <aside>
        <div class="filter-panel">
            <div class="filter-title"><i class="fa-solid fa-filter"></i> Audit Filters</div>
            
            <form method="GET">
                <div class="form-group">
                    <label class="form-label">Treatment Period</label>
                    <input type="text" name="date_range" id="dateRange" class="form-control" placeholder="Select dates..." value="<?= htmlspecialchars($_GET['date_range'] ?? '') ?>">
                </div>

                <div class="form-group">
                    <label class="form-label">Company</label>
                    <select name="company_id" class="form-select" onchange="this.form.submit()">
                        <option value="">All Companies</option>
                        <?php if($companies): foreach($companies as $c): ?>
                            <option value="<?= e($c['company_id']) ?>" <?= ($_GET['company_id'] ?? '') == $c['company_id'] ? 'selected' : '' ?>>
                                <?= e($c['name']) ?>
                            </option>
                        <?php endforeach; endif; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Production Lot</label>
                    <select name="lot_id" class="form-select">
                        <option value="">All Lots</option>
                        <?php if($lots): foreach($lots as $l): ?>
                            <option value="<?= e($l['lot_id']) ?>" <?= ($_GET['lot_id'] ?? '') == $l['lot_id'] ? 'selected' : '' ?>>
                                <?= e($l['name']) ?>
                            </option>
                        <?php endforeach; endif; ?>
                    </select>
                </div>

                <div style="display: flex; gap: 10px;">
                    <div class="form-group" style="flex: 1;">
                        <label class="form-label">Breed</label>
                        <select name="type_id" class="form-select">
                            <option value="">Any</option>
                            <?php if($breeds): foreach($breeds as $b): ?>
                                <option value="<?= e($b['type_id']) ?>" <?= ($_GET['type_id'] ?? '') == $b['type_id'] ? 'selected' : '' ?>>
                                    <?= e($b['breed']) ?>
                                </option>
                            <?php endforeach; endif; ?>
                        </select>
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label class="form-label">Category</label>
                        <select name="med_type" class="form-select">
                            <option value="">Any</option>
                            <?php if($med_types): while($mt = $med_types->fetch_assoc()): ?>
                                <option value="<?= e($mt['type']) ?>" <?= ($_GET['med_type'] ?? '') == $mt['type'] ? 'selected' : '' ?>>
                                    <?= ucfirst($mt['type']) ?>
                                </option>
                            <?php endwhile; endif; ?>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Veterinarian / Supplier</label>
                    <select name="vet_name" class="form-select">
                        <option value="">All Suppliers</option>
                        <?php if($vets): foreach($vets as $v): ?>
                            <option value="<?= htmlspecialchars($v['name']) ?>" <?= (isset($_GET['vet_name']) && $_GET['vet_name'] == $v['name']) ? 'selected' : '' ?>>
                                <?= htmlspecialchars($v['name']) ?>
                            </option>
                        <?php endforeach; endif; ?>
                    </select>
                </div>

                <button type="submit" class="btn-run">Run Audit</button>
                <a href="reports_health.php" style="display:block; text-align:center; color:#94a3b8; font-size:12px; margin-top:15px; text-decoration:none;">Clear Filters</a>
            </form>

            <div class="note-box">
                <i class="fa-solid fa-circle-exclamation" style="color:#fbbf24;"></i>
                <div class="note-text">
                    <strong>Inspection Note</strong><br>
                    Animals marked as BLOCKED are within the withdrawal period. Do not harvest.
                </div>
            </div>
        </div>
    </aside>

    <section>
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-icon"><i class="fa-solid fa-heart-pulse"></i></div>
                <div class="kpi-val"><?= e($stats['total_cases']) ?></div>
                <div class="kpi-lbl">Treatments</div>
            </div>
            <div class="kpi-card" style="<?= $stats['blocked_animals'] > 0 ? 'border-color: rgba(251, 191, 36, 0.4);' : '' ?>">
                <div class="kpi-icon"><i class="fa-solid fa-hand" style="<?= $stats['blocked_animals'] > 0 ? 'color: #fbbf24;' : '' ?>"></i></div>
                <div class="kpi-val" style="<?= $stats['blocked_animals'] > 0 ? 'color: #fbbf24;' : '' ?>"><?= e($stats['blocked_animals']) ?></div>
                <div class="kpi-lbl">Blocked (Wait)</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-icon"><i class="fa-solid fa-euro-sign"></i></div>
                <div class="kpi-val">€<?= number_format($stats['total_cost'], 0) ?></div>
                <div class="kpi-lbl">Total Cost</div>
            </div>
        </div>

        <div class="table-panel">
            <div style="padding: 20px; border-bottom: 1px solid rgba(255,255,255,0.1); display:flex; justify-content:space-between; align-items:center;">
                <h4 style="margin:0; font-size:16px; color:#fff;">Traceability Log</h4>
                <div class="export-actions">
                    <button type="button" onclick="exportToExcel()" class="btn-export"><i class="fa-solid fa-file-excel" style="color:#4ade80;"></i> Excel</button>
                    <button type="button" onclick="exportToPDF()" class="btn-export"><i class="fa-solid fa-file-pdf" style="color:#f87171;"></i> PDF</button>
                </div>
            </div>
            <table class="glass-table" id="reportTable">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Animal ID</th>
                        <th>Details (Breed / Lot)</th>
                        <th>Medicine</th>
                        <th>Vet</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if(count($records) > 0): foreach($records as $row): ?>
                    <tr>
                        <td style="color:#94a3b8;"><?= date('d M Y', strtotime($row['treatment_date'])) ?></td>
                        <td><strong style="color:#fff;"><?= e($row['tag_number']) ?></strong></td>
                        <td>
                            <div style="color:#fff"><?= e($row['breed']) ?></div>
                            <small style="color:#64748b; font-size:11px;"><?= $row['lot_name'] ?: '-' ?></small>
                        </td>
                        <td>
                            <span style="color:#4ade80;"><?= e($row['item_name']) ?></span><br>
                            <small style="color:#64748b; font-size:10px;"><?= e(ucfirst((string) ($row['med_type'] ?? ''))) ?></small>
                        </td>
                        <td style="font-size:12px; color:#cbd5e1;"><?= $row['vet_name'] ?: '-' ?></td>
                        <td>
                            <?php if($row['is_blocked']): ?>
                                <span class="badge-blocked">BLOCKED (<?= e($row['days_remaining']) ?>d)</span>
                            <?php else: ?>
                                <span class="badge-clear">CLEAR</span>
                            <?php endif; ?>
                        </td>
                    </tr>
                    <?php endforeach; else: ?>
                        <tr><td colspan="6" style="text-align:center; color:#64748b; padding:30px;">No records found matching filters.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </section>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.25/jspdf.plugin.autotable.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>

<script>
    flatpickr("#dateRange", { mode: "range", dateFormat: "Y-m-d", theme: "dark" });

    // Configurações Globais do Relatório (PHP para JS)
    const reportConfig = {
        company: "<?= e($display_company) ?>",
        user: "<?= e($user_name) ?>",
        date: "<?= date('d/m/Y H:i') ?>"
    };

    function exportToExcel() {
        const table = document.getElementById("reportTable");
        const workbook = XLSX.utils.table_to_book(table, {sheet: "Sanitary Audit"});
        XLSX.writeFile(workbook, `Relatorio_Sanitario_${reportConfig.company.replace(/\s+/g, '_')}.xlsx`);
    }

    // --- CORREÇÃO 1: CABEÇALHO DO PDF EM INGLÊS ---
    function exportToPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('p', 'mm', 'a4');
        
        // Estilo do Cabeçalho
        doc.setFontSize(18);
        doc.setTextColor(40, 40, 40);
        // Alterado de "Auditoria Sanitária Profissional"
        doc.text("Professional Sanitary Audit", 14, 22);
        
        doc.setFontSize(10);
        doc.setTextColor(100, 100, 100);
        // Tradução dos campos
        doc.text(`Company: ${reportConfig.company}`, 14, 30);
        doc.text(`Generated by: ${reportConfig.user}`, 14, 35);
        doc.text(`Date: ${reportConfig.date}`, 14, 40);
        
        // Linha divisória
        doc.setLineWidth(0.5);
        doc.line(14, 45, 196, 45);

        doc.autoTable({
            html: '#reportTable',
            startY: 50,
            styles: { fontSize: 8, cellPadding: 3 },
            headStyles: { fillColor: [74, 222, 128], textColor: [0, 0, 0], fontStyle: 'bold' },
            alternateRowStyles: { fillColor: [245, 245, 245] },
            margin: { left: 14, right: 14 }
        });

        doc.save(`Sanitary_Report_${reportConfig.company.replace(/\s+/g, '_')}.pdf`);
    }
</script>

</body>
</html>