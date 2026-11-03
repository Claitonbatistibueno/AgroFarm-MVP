<?php
/* =========================================================
   financial_dashboard.php — Financial Command Center
   ========================================================= */

require_once 'config.php';
require_login();

// --- 1. AJAX API (Micro-serviço para buscar peso) ---
if (isset($_GET['action']) && $_GET['action'] === 'get_animal_weight' && isset($_GET['animal_id'])) {
    header('Content-Type: application/json');
    try {
        $stmt = $pdo->prepare("SELECT weight_kg FROM weighing WHERE animal_id = ? ORDER BY weighing_date DESC LIMIT 1");
        $stmt->execute([$_GET['animal_id']]);
        $res = $stmt->fetch();
        echo json_encode(['weight' => $res ? $res['weight_kg'] : 0]);
    } catch (Exception $e) { echo json_encode(['weight' => 0]); }
    exit;
}

// --- 2. AUTH CHECK & DB CONNECTION ---
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }


// --- 3. COMPANY CONTEXT LOGIC ---
// Busca todas as empresas para o seletor
$companies = $pdo->query("SELECT company_id, name FROM company ORDER BY name ASC")->fetchAll();

// Define a empresa ativa (Sessão ou GET para troca rápida)
if (isset($_GET['context_company'])) {
    $_SESSION['active_company_id'] = (int) $_GET['context_company'];
    // Redireciona para limpar a URL
    header("Location: financial_dashboard.php");
    exit;
}

// Fallback se não houver empresa na sessão
if (!isset($_SESSION['active_company_id']) && count($companies) > 0) {
    $_SESSION['active_company_id'] = $companies[0]['company_id'];
}

$actCompanyId = (int) ($_SESSION['active_company_id'] ?? 0);
$actCompanyName = "Select Company";
foreach ($companies as $c) {
    if ($c['company_id'] == $actCompanyId) $actCompanyName = $c['name'];
}

// --- 4. FORM PROCESSING (POST) ---
$msg = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    
    // A. Registrar Despesa
    if (isset($_POST['action']) && $_POST['action'] === 'register_expense') {
        try {
            $filePath = null; // Lógica de upload simplificada
            if (!empty($_FILES['invoice_file']['name'])) {
                $filePath = safe_upload($_FILES['invoice_file'], 'invoices', ['pdf', 'jpg', 'png', 'webp']);
            }

            $stmt = $pdo->prepare("INSERT INTO accounts_payable (company_id, supplier_id, category_id, description, amount, due_date, status, file_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$actCompanyId, $_POST['supplier_id'], $_POST['category_id'], $_POST['description'], $_POST['amount'], $_POST['due_date'], 'pending', $filePath]);
            $msg = '<div class="glass-alert success"><i class="fa-solid fa-check"></i> Expense registered successfully!</div>';
        } catch (Exception $e) { 
            $msg = '<div class="glass-alert error"><i class="fa-solid fa-triangle-exclamation"></i> Error: ' . $e->getMessage() . '</div>'; 
        }
    }

    // B. Registrar Venda
    if (isset($_POST['action']) && $_POST['action'] === 'register_sale') {
        try {
            $pdo->beginTransaction();
            $totalValue = $_POST['final_weight'] * $_POST['price_per_unit'];

            $stmt = $pdo->prepare("INSERT INTO sales (company_id, animal_id, client_id, sale_date, final_weight, price_per_unit, total_value) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([$actCompanyId, $_POST['animal_id'], $_POST['client_id'], $_POST['sale_date'], $_POST['final_weight'], $_POST['price_per_unit'], $totalValue]);

            // Update status animal
            $pdo->prepare("UPDATE animal SET status = 'sold' WHERE animal_id = ?")->execute([$_POST['animal_id']]);
            $pdo->commit();
            $msg = '<div class="glass-alert success"><i class="fa-solid fa-check"></i> Sale registered & Animal archived!</div>';
        } catch (Exception $e) { 
            $pdo->rollBack(); 
            $msg = '<div class="glass-alert error"><i class="fa-solid fa-triangle-exclamation"></i> Error: ' . $e->getMessage() . '</div>'; 
        }
    }
}

// --- 5. DATA FETCHING (KPIs & Lists) ---

// Listas para Dropdowns
$suppliers = $pdo->query("SELECT supplier_id, name FROM suppliers WHERE status='active' ORDER BY name")->fetchAll();
$clients = $pdo->query("SELECT client_id, name FROM clients ORDER BY name")->fetchAll();
try { 
    $categories = $pdo->query("SELECT category_id, name FROM financial_categories ORDER BY name")->fetchAll(); 
} catch (Exception $e) { $categories = []; }

// Animal
$activeAnimals = $pdo->prepare("
    SELECT a.animal_id, a.tag_number 
    FROM animal a 
    JOIN lot_animals la ON a.animal_id = la.animal_id 
    JOIN lot l ON la.lot_id = l.lot_id 
    WHERE l.company_id = ? AND a.status = 'active'
    ORDER BY a.tag_number ASC
");
$activeAnimals->execute([$actCompanyId]);
$animalsList = $activeAnimals->fetchAll();

// KPIs
$sqlRev = "SELECT COALESCE(SUM(total_value), 0) FROM sales WHERE company_id = ? AND date_trunc('month', sale_date) = date_trunc('month', CURRENT_DATE)";
$stmt = $pdo->prepare($sqlRev); $stmt->execute([$actCompanyId]);
$kpiSales = $stmt->fetchColumn();

$sqlExp1 = "SELECT COALESCE(SUM(amount), 0) FROM accounts_payable WHERE company_id = ? AND date_trunc('month', due_date) = date_trunc('month', CURRENT_DATE)";
$stmt = $pdo->prepare($sqlExp1); $stmt->execute([$actCompanyId]);
$exp1 = $stmt->fetchColumn();

$sqlExp2 = "SELECT COALESCE(SUM(oc.cost_value), 0) FROM operational_costs oc JOIN lot l ON oc.lot_id = l.lot_id WHERE l.company_id = ? AND date_trunc('month', oc.cost_date) = date_trunc('month', CURRENT_DATE)";
$stmt = $pdo->prepare($sqlExp2); $stmt->execute([$actCompanyId]);
$exp2 = $stmt->fetchColumn();
$kpiExpenses = $exp1 + $exp2;

$kpiProfit = $kpiSales - $kpiExpenses;

// Ledger 
$sqlLedger = "
    SELECT * FROM (
        SELECT 'expense' as type, description as \"desc\", amount, due_date as t_date 
        FROM accounts_payable WHERE company_id = ?
        UNION ALL
        SELECT 'sale' as type, CONCAT('Sale Animal #', animal_id) as \"desc\", total_value as amount, sale_date as t_date 
        FROM sales WHERE company_id = ?
    ) as combined_ledger
    ORDER BY t_date DESC LIMIT 10
";
$stmtLedger = $pdo->prepare($sqlLedger);
$stmtLedger->execute([$actCompanyId, $actCompanyId]);
$ledgerData = $stmtLedger->fetchAll();

?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Financial Hub | <?= htmlspecialchars($actCompanyName) ?></title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
    /* --- INHERITED THEME (Same as dashboard.php) --- */
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
    
    /* Layout */
    .main { max-width: 1200px; margin: 40px auto; padding: 0 20px; min-height: 80vh; animation: fadeIn 0.6s ease; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

    .page-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 20px; }
    .page-title h1 { font-size: 32px; font-weight: 700; margin: 0; color: #fff; }
    .page-title p { color: #94a3b8; margin: 5px 0 0 0; }
    
    /* Company Switcher Styled */
    .company-switcher { position: relative; }
    .cs-btn { 
        background: rgba(74, 222, 128, 0.1); border: 1px solid rgba(74, 222, 128, 0.3); 
        color: #4ade80; padding: 10px 20px; border-radius: 12px; cursor: pointer; 
        font-weight: 600; display: flex; align-items: center; gap: 10px; transition: 0.3s;
    }
    .cs-btn:hover { background: rgba(74, 222, 128, 0.2); transform: translateY(-2px); }
    .cs-menu { 
        display: none; position: absolute; top: 110%; right: 0; 
        background: #1e293b; border: 1px solid rgba(255,255,255,0.1); 
        border-radius: 12px; width: 240px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); z-index: 1000; overflow: hidden;
    }
    .company-switcher:hover .cs-menu { display: block; }
    .cs-menu a { display: block; padding: 12px 20px; color: #cbd5e1; text-decoration: none; border-bottom: 1px solid rgba(255,255,255,0.05); }
    .cs-menu a:hover { background: rgba(74, 222, 128, 0.1); color: #4ade80; }

    /* --- DASHBOARD GRIDS --- */
    .kpi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; margin-bottom: 30px; }
    
    .glass-card {
        background: linear-gradient(145deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.03) 100%);
        backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.1);
        border-radius: 20px; padding: 25px; color: white; position: relative;
    }

    .kpi-label { font-size: 13px; text-transform: uppercase; color: #94a3b8; letter-spacing: 1px; font-weight: 600; }
    .kpi-value { font-size: 36px; font-weight: 700; margin: 10px 0 0 0; }
    .kpi-value.green { color: #4ade80; }
    .kpi-value.red { color: #f87171; }
    .kpi-value.blue { color: #60a5fa; }

    /* --- SPLIT LAYOUT (Forms & Ledger) --- */
    .split-grid { display: grid; grid-template-columns: 2fr 1fr; gap: 24px; }
    
    /* Tabs & Forms */
    .tab-header { display: flex; gap: 15px; margin-bottom: 20px; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 10px; }
    .tab-btn { 
        background: transparent; border: none; color: #94a3b8; font-size: 16px; font-weight: 600; 
        cursor: pointer; padding: 8px 15px; border-radius: 8px; transition: 0.3s;
    }
    .tab-btn.active { background: rgba(255,255,255,0.1); color: #fff; }
    
    .form-group { margin-bottom: 15px; }
    .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
    
    label { display: block; font-size: 13px; color: #cbd5e1; margin-bottom: 5px; }
    input, select { 
        width: 100%; box-sizing: border-box; background: rgba(0,0,0,0.2); 
        border: 1px solid rgba(255,255,255,0.15); border-radius: 8px; padding: 10px 15px; 
        color: #fff; font-size: 14px; outline: none; transition: 0.3s;
    }
    input:focus, select:focus { border-color: #4ade80; background: rgba(0,0,0,0.4); }
    
    .btn-action { 
        width: 100%; padding: 12px; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; margin-top: 10px; font-size: 15px; transition: 0.3s; 
    }
    .btn-save { background: #4ade80; color: #0f172a; }
    .btn-save:hover { background: #22c55e; }
    .btn-expense { background: #f87171; color: #fff; }
    .btn-expense:hover { background: #ef4444; }

    /* Ledger Table */
    .ledger-table { width: 100%; border-collapse: collapse; }
    .ledger-table td { padding: 12px 0; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 14px; }
    .ledger-table tr:last-child td { border-bottom: none; }
    
    .icon-box { 
        width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 14px; 
    }
    .ib-in { background: rgba(74, 222, 128, 0.2); color: #4ade80; }
    .ib-out { background: rgba(248, 113, 113, 0.2); color: #f87171; }
    
    /* Alerts */
    .glass-alert { padding: 15px; border-radius: 12px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
    .glass-alert.success { background: rgba(74, 222, 128, 0.15); border: 1px solid rgba(74, 222, 128, 0.3); color: #4ade80; }
    .glass-alert.error { background: rgba(248, 113, 113, 0.15); border: 1px solid rgba(248, 113, 113, 0.3); color: #f87171; }

    /* Dropdown CSS (Nav) */
    .dropdown { position: relative; }
    .drop-menu { 
        display: none; position: absolute; top: 100%; right: 0; 
        background: #1e293b; border: 1px solid rgba(255,255,255,0.1); 
        border-radius: 12px; width: 220px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); padding: 8px 0; z-index: 1000; 
    }
    .dropdown:hover .drop-menu { display: block; }
    .drop-menu a { padding: 12px 20px; display: block; color: #cbd5e1; text-decoration: none; font-size: 14px; transition: .2s; border-bottom: 1px solid rgba(255,255,255,0.02); }
    .drop-menu a:hover { background: rgba(74, 222, 128, 0.1); color: #4ade80; padding-left: 25px; }

</style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <div class="nav">
        <a href="dashboard.php"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php"><i class="fa-solid fa-cow"></i> Animals</a>
        <a href="feeding.php"><i class="fa-solid fa-bucket"></i> Feeding</a>
        <a href="weighing.php"><i class="fa-solid fa-scale-balanced"></i> Weighing</a>
        <a href="financial_dashboard.php" class="active"><i class="fa-solid fa-coins"></i> Financial Hub</a>
        
        <div class="dropdown">
            <a href="reports.php"><i class="fa-solid fa-chart-line"></i> Reports</a>
            <div class="drop-menu"> 
                <a href="reports_animals.php">Animal Reports</a>
                <a href="reports_weight.php">Weight Control</a>
                <a href="reports_financial.php">Financial Overview</a>
            </div>
        </div>
        
        <div class="dropdown">
            <a href="#"><i class="fa-solid fa-gear"></i> Admin</a>
            <div class="drop-menu">
                <a href="settings.php">Company Settings</a>
                <a href="suppliers_list.php">Suppliers</a>
                <a href="clients.php">Clients Management</a>
                <a href="users.php">User Management</a>
            </div>
        </div>
        
        <a href="dashboard.php?logout=true" style="color:#f87171"><i class="fa-solid fa-right-from-bracket"></i></a>
    </div>
</div>

<main class="main">
    
    <div class="page-header">
        <div class="page-title">
            <h1>Financial Dashboard</h1>
            <p>Manage expenses, sales, and cash flow.</p>
        </div>
        
        <div class="company-switcher">
            <div class="cs-btn">
                <i class="fa-solid fa-building"></i> <?= htmlspecialchars($actCompanyName) ?> <i class="fa-solid fa-caret-down"></i>
            </div>
            <div class="cs-menu">
                <div style="padding:10px 20px; font-size:11px; text-transform:uppercase; color:#64748b; letter-spacing:1px;">Switch Farm</div>
                <?php foreach ($companies as $comp): ?>
                    <a href="?context_company=<?= e($comp['company_id']) ?>">
                        <?= $comp['company_id'] == $actCompanyId ? '<i class="fa-solid fa-check" style="color:#4ade80; margin-right:5px;"></i>' : '' ?>
                        <?= htmlspecialchars($comp['name']) ?>
                    </a>
                <?php endforeach; ?>
            </div>
        </div>
    </div>

    <?= $msg ?>

    <div class="kpi-grid">
        <div class="glass-card">
            <div class="kpi-label"><i class="fa-solid fa-arrow-trend-up"></i> Monthly Revenue</div>
            <div class="kpi-value green">€ <?= number_format($kpiSales, 2, ',', '.') ?></div>
            <div style="margin-top:10px; height: 50px;"><canvas id="chartRev"></canvas></div>
        </div>
        <div class="glass-card">
            <div class="kpi-label"><i class="fa-solid fa-arrow-trend-down"></i> Monthly Expenses</div>
            <div class="kpi-value red">€ <?= number_format($kpiExpenses, 2, ',', '.') ?></div>
            <div style="margin-top:10px; height: 50px;"><canvas id="chartExp"></canvas></div>
        </div>
        <div class="glass-card">
            <div class="kpi-label"><i class="fa-solid fa-wallet"></i> Net Profit (Est.)</div>
            <div class="kpi-value blue">€ <?= number_format($kpiProfit, 2, ',', '.') ?></div>
            <div style="font-size:12px; color:#94a3b8; margin-top:5px;">Based on cash flow this month</div>
        </div>
    </div>

    <div class="split-grid">
        
        <div class="glass-card">
            <div class="tab-header">
                <button class="tab-btn active" onclick="openTab('sale')"><i class="fa-solid fa-sack-dollar"></i> New Sale</button>
                <button class="tab-btn" onclick="openTab('expense')"><i class="fa-solid fa-file-invoice-dollar"></i> New Expense</button>
            </div>

            <div id="tab-sale" class="tab-content">
                <form method="POST">
                    <input type="hidden" name="action" value="register_sale">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Animal Tag</label>
                            <select name="animal_id" id="animalSelect" required>
                                <option value="">Select Animal...</option>
                                <?php foreach($animalsList as $a): ?>
                                    <option value="<?= e($a['animal_id']) ?>"><?= e($a['tag_number']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Client</label>
                            <select name="client_id" required>
                                <?php foreach($clients as $c): ?><option value="<?= e($c['client_id']) ?>"><?= e($c['name']) ?></option><?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Final Weight (kg)</label>
                            <input type="number" step="0.01" name="final_weight" id="animalWeight" placeholder="0.00" required>
                            <small id="loadingWeight" style="display:none; color:#4ade80;">Fetching...</small>
                        </div>
                        <div class="form-group">
                            <label>Price per Kg (€)</label>
                            <input type="number" step="0.01" name="price_per_unit" id="pricePerKg" value="3.50" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Sale Date</label>
                        <input type="date" name="sale_date" value="<?= date('Y-m-d') ?>" required>
                    </div>
                    
                    <div style="background: rgba(0,0,0,0.3); padding: 15px; border-radius: 10px; margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center;">
                        <span style="color:#94a3b8;">Estimated Total:</span>
                        <span id="totalCalc" style="font-size: 18px; font-weight: 700; color: #4ade80;">€ 0,00</span>
                    </div>

                    <button type="submit" class="btn-action btn-save">Confirm Sale</button>
                </form>
            </div>

            <div id="tab-expense" class="tab-content" style="display:none;">
                <form method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="register_expense">
                    <div class="form-row">
                        <div class="form-group">
                            <label>Supplier</label>
                            <select name="supplier_id" required>
                                <?php foreach($suppliers as $s): ?><option value="<?= e($s['supplier_id']) ?>"><?= e($s['name']) ?></option><?php endforeach; ?>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Category</label>
                            <select name="category_id" required>
                                <?php foreach($categories as $c): ?><option value="<?= e($c['category_id']) ?>"><?= e($c['name']) ?></option><?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Description</label>
                        <input type="text" name="description" placeholder="e.g. Monthly Feed Purchase" required>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>Amount (€)</label>
                            <input type="number" step="0.01" name="amount" required>
                        </div>
                        <div class="form-group">
                            <label>Due Date</label>
                            <input type="date" name="due_date" value="<?= date('Y-m-d') ?>" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Invoice File (Optional)</label>
                        <input type="file" name="invoice_file">
                    </div>
                    <button type="submit" class="btn-action btn-expense">Register Expense</button>
                </form>
            </div>
        </div>

        <div class="glass-card">
            <h3 style="font-size: 16px; font-weight: 700; margin-top:0; margin-bottom: 20px;">Recent Activity</h3>
            <table class="ledger-table">
                <?php if(empty($ledgerData)): ?>
                    <tr><td colspan="3" style="text-align:center; color:#64748b; padding: 20px;">No recent transactions.</td></tr>
                <?php else: ?>
                    <?php foreach($ledgerData as $row): $isSale = $row['type'] == 'sale'; ?>
                    <tr>
                        <td width="40">
                            <div class="icon-box <?= $isSale ? 'ib-in' : 'ib-out' ?>">
                                <i class="fa-solid <?= $isSale ? 'fa-arrow-up' : 'fa-arrow-down' ?>"></i>
                            </div>
                        </td>
                        <td>
                            <div style="font-weight: 600; color: #f1f5f9;"><?= htmlspecialchars($row['desc']) ?></div>
                            <div style="font-size: 11px; color: #64748b;"><?= date('d M Y', strtotime($row['t_date'])) ?></div>
                        </td>
                        <td align="right" style="font-weight: 700; color: <?= $isSale ? '#4ade80' : '#f87171' ?>">
                            <?= $isSale ? '+' : '-' ?> €<?= number_format($row['amount'], 2, ',', '.') ?>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </table>
        </div>
    </div>
</main>

<script>
    // 1. Tab Switching Logic
    function openTab(tabName) {
        document.querySelectorAll('.tab-content').forEach(el => el.style.display = 'none');
        document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
        document.getElementById('tab-' + tabName).style.display = 'block';
        // Encontra o botão clicado (simplificado)
        event.target.classList.add('active');
    }

    // 2. Real-time Calculation & AJAX Weight
    const animalSelect = document.getElementById('animalSelect');
    const weightInput = document.getElementById('animalWeight');
    const priceInput = document.getElementById('pricePerKg');
    const totalCalc = document.getElementById('totalCalc');
    const loadingMsg = document.getElementById('loadingWeight');

    function updateTotal() {
        const w = parseFloat(weightInput.value) || 0;
        const p = parseFloat(priceInput.value) || 0;
        totalCalc.innerText = '€ ' + (w * p).toFixed(2).replace('.', ',');
    }

    if(animalSelect) {
        animalSelect.addEventListener('change', function() {
            const id = this.value;
            if(id) {
                loadingMsg.style.display = 'inline';
                weightInput.value = '';
                fetch(`?action=get_animal_weight&animal_id=${id}`)
                    .then(res => res.json())
                    .then(data => {
                        weightInput.value = data.weight;
                        loadingMsg.style.display = 'none';
                        updateTotal();
                    });
            }
        });
    }

    if(priceInput) priceInput.addEventListener('input', updateTotal);
    if(weightInput) weightInput.addEventListener('input', updateTotal);

    // 3. Mini Charts (Sparklines aesthetic)
    const commonOptions = {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: { x: { display: false }, y: { display: false } },
        elements: { point: { radius: 0 }, line: { borderWidth: 2, tension: 0.4 } }
    };

    new Chart(document.getElementById('chartRev'), {
        type: 'line',
        data: { labels: [1,2,3,4,5], datasets: [{ data: [10, 15, 12, 18, 25], borderColor: '#4ade80' }] },
        options: commonOptions
    });

    new Chart(document.getElementById('chartExp'), {
        type: 'line',
        data: { labels: [1,2,3,4,5], datasets: [{ data: [20, 18, 22, 15, 12], borderColor: '#f87171' }] },
        options: commonOptions
    });
</script>
</body>
</html>