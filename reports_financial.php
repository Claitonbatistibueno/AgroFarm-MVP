<?php
/**
 * RELATÓRIO FINANCEIRO AVANÇADO (FARM PROJECT)
 * Estilo: Premium Glass (Dark Mode)
 * Funcionalidades: Filtro de Data Único (Flatpickr), Ledger Unificado, Gráficos, PDF/Excel
 */

// 1. Connection and Security
require_once 'config.php';
require_login();

// 2. DATA RANGE
// Padrão: Do dia 01 deste mês até hoje
$defaultStart = date('Y-m-01');
$defaultEnd   = date('Y-m-t');

$dateRange = $_GET['date_range'] ?? "$defaultStart to $defaultEnd";
$dates = explode(" to ", $dateRange);

// Se o usuário selecionou apenas uma data ou o range veio incompleto
$startDate = valid_date(trim($dates[0] ?? ''), $defaultStart);
$endDate   = valid_date(trim($dates[1] ?? $dates[0] ?? ''), $defaultEnd);

$filterType = in_array($_GET['type'] ?? 'all', ['all', 'income', 'expense'], true) ? ($_GET['type'] ?? 'all') : 'all'; // all, income, expense

// 3. CONSULTA UNIFICADA (O "Segredo" do Relatório)
// Une Vendas, Contas a Pagar e Custos Operacionais em uma única lista cronológica
$params = [$startDate, $endDate, $startDate, $endDate, $startDate, $endDate];

$sql = "
SELECT * FROM (
    -- 1. RECEITAS (Vendas de Animais)
    SELECT 
        sale_date as trans_date, 
        'Income' as type, 
        'Livestock Sales' as category, 
        CONCAT('Animal Tag: ', (SELECT tag_number FROM animal WHERE animal_id = s.animal_id)) as description,
        total_value as amount
    FROM sales s
    WHERE sale_date BETWEEN ? AND ?

    UNION ALL

    -- 2. DESPESAS (Contas a Pagar)
    SELECT 
        due_date as trans_date, 
        'Expense' as type, 
        (SELECT name FROM financial_categories WHERE category_id = ap.category_id) as category,
        description,
        amount
    FROM accounts_payable ap
    WHERE status != 'cancelled' AND due_date BETWEEN ? AND ?

    UNION ALL

    -- 3. DESPESAS (Custos Operacionais Diários)
    SELECT 
        cost_date as trans_date, 
        'Expense' as type, 
        CONCAT(UPPER(LEFT(category, 1)), SUBSTRING(category, 2)) as category, 
        COALESCE(description, 'Custo Operacional') as description,
        cost_value as amount
    FROM operational_costs oc
    WHERE cost_date BETWEEN ? AND ?
) AS unified_ledger
WHERE 1=1
";

if ($filterType !== 'all') {
    $sql .= " AND type = ?";
    $params[] = ucfirst($filterType);
}

$sql .= " ORDER BY trans_date DESC, type, description"; // tie-breaker: stable order for rows on the same date

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$transactions = $stmt->fetchAll();

// 4. CÁLCULO DE MÉTRICAS (No PHP para aliviar o banco)
$totalIncome = 0;
$totalExpense = 0;
$catBreakdown = []; // Para o gráfico de pizza
$monthlyStats = []; // Para o gráfico de barras

foreach ($transactions as $t) {
    $amt = (float)$t['amount'];
    $monthKey = date('M Y', strtotime($t['trans_date'])); // Ex: Feb 2026
    
    // Inicializa array do mês se não existir
    if (!isset($monthlyStats[$monthKey])) { 
        $monthlyStats[$monthKey] = ['income' => 0, 'expense' => 0]; 
    }

    if ($t['type'] === 'Income') {
        $totalIncome += $amt;
        $monthlyStats[$monthKey]['income'] += $amt;
    } else {
        $totalExpense += $amt;
        $monthlyStats[$monthKey]['expense'] += $amt;
        
        // Categoria (agrupar nulos como 'Geral')
        $cat = $t['category'] ?: 'Geral';
        if (!isset($catBreakdown[$cat])) $catBreakdown[$cat] = 0;
        $catBreakdown[$cat] += $amt;
    }
}

$netProfit = $totalIncome - $totalExpense;
$margin = ($totalIncome > 0) ? round(($netProfit / $totalIncome) * 100, 1) : 0;

// Prepara dados para os gráficos JS
$chartLabels = array_reverse(array_keys($monthlyStats));
$chartIncome = [];
$chartExpense = [];
foreach($chartLabels as $lbl) {
    $chartIncome[] = $monthlyStats[$lbl]['income'];
    $chartExpense[] = $monthlyStats[$lbl]['expense'];
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Financial Intelligence | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/dark.css">
    
    <style>
        /* --- PREMIUM GLASS THEME --- */
        body {
            margin: 0; font-family: "Segoe UI", sans-serif;
            background: url('assets/img/dowloag.png') no-repeat center center fixed;
            background-size: cover; color: #fff;
            min-height: 100vh; overflow-y: scroll;
        }
        /* Overlay Escuro */
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(10, 15, 25, 0.85); z-index: -1;
        }

        /* Topbar */
        .topbar {
            background: rgba(15, 23, 42, 0.9); backdrop-filter: blur(15px);
            border-bottom: 1px solid rgba(255,255,255,0.1); padding: 0 40px; height: 64px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .brand { font-size: 22px; font-weight: 700; color: #4ade80; text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav { display: flex; gap: 20px; align-items: center; }
        .nav a { color: #cbd5e1; text-decoration: none; font-size: 14px; font-weight: 500; transition: .3s; display: flex; align-items: center; gap: 8px; padding: 8px 12px; border-radius: 8px; }
        .nav a:hover, .nav a.active { background: rgba(74, 222, 128, 0.15); color: #4ade80; }

        /* Container Grid */
        .main-container {
            max-width: 1500px; margin: 30px auto; padding: 0 20px;
            display: grid; grid-template-columns: 280px 1fr; gap: 25px;
            animation: fadeIn 0.6s ease;
        }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }

        /* Glass Cards */
        .glass-card {
            background: linear-gradient(145deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.02) 100%);
            backdrop-filter: blur(20px); border: 1px solid rgba(255,255,255,0.1);
            border-radius: 16px; padding: 25px; color: white;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3); margin-bottom: 25px;
        }

        /* KPI Cards Mini */
        .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 25px; }
        .kpi-val { font-size: 26px; font-weight: 700; margin: 5px 0; }
        .kpi-label { font-size: 11px; color: #94a3b8; text-transform: uppercase; letter-spacing: 1px; font-weight: 600; }
        .kpi-icon { float: right; font-size: 20px; opacity: 0.5; }

        /* Inputs Modernos */
        .form-control, .form-select {
            background: rgba(0, 0, 0, 0.4) !important; 
            border: 1px solid rgba(255,255,255,0.15) !important;
            color: #fff !important; border-radius: 8px; padding: 12px; width: 100%;
            font-size: 14px; margin-bottom: 15px;
        }
        .form-control:focus, .form-select:focus { border-color: #4ade80 !important; outline: none; box-shadow: none; }
        .form-label { font-size: 12px; color: #cbd5e1; margin-bottom: 6px; display: block; font-weight: 700; text-transform: uppercase; }

        /* Tabela */
        .glass-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .glass-table th { text-align: left; padding: 15px; color: #94a3b8; border-bottom: 1px solid rgba(255,255,255,0.1); text-transform: uppercase; font-size: 11px; font-weight: 700; }
        .glass-table td { padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.03); color: #e2e8f0; vertical-align: middle; }
        .glass-table tr:last-child td { border-bottom: none; }
        .glass-table tr:hover td { background: rgba(255,255,255,0.03); }

        /* Botões */
        .btn-green { background: #4ade80; color: #0f172a; font-weight: 700; border: none; padding: 12px; border-radius: 8px; cursor: pointer; width: 100%; transition: .2s; }
        .btn-green:hover { background: #22c55e; }
        .btn-outline { background: transparent; border: 1px solid rgba(255,255,255,0.2); color: #cbd5e1; padding: 10px; border-radius: 8px; cursor: pointer; width: 100%; text-align: left; transition: .2s; display: flex; align-items: center; gap: 10px; margin-bottom: 8px;}
        .btn-outline:hover { border-color: #fff; color: #fff; background: rgba(255,255,255,0.05); }

        /* Cores de Texto */
        .text-success { color: #4ade80 !important; }
        .text-danger { color: #f87171 !important; }
        .text-info { color: #38bdf8 !important; }

        /* Responsivo */
        @media (max-width: 1024px) { .main-container { grid-template-columns: 1fr; } .kpi-grid { grid-template-columns: 1fr 1fr; } }
    </style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <div class="nav">
        <a href="dashboard.php"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="financial_dashboard.php"><i class="fa-solid fa-sack-dollar"></i> Financial Hub</a>
        <a href="reports.php" class="active"><i class="fa-solid fa-chart-pie"></i> Reports</a>
        <a href="dashboard.php?logout=true" style="color:#f87171" title="Sair"><i class="fa-solid fa-power-off"></i></a>
    </div>
</div>

<div class="main-container">
    
    <aside>
        <div class="glass-card">
            <h5 class="mb-4" style="color:#4ade80; font-size:16px;"><i class="fa-solid fa-filter me-2"></i> Filters</h5>
            <form method="GET" id="filterForm">
                
                <label class="form-label">Date Range</label>
                <div style="position: relative;">
                    <input type="text" name="date_range" id="dateRangePicker" class="form-control" 
                           value="<?= htmlspecialchars($dateRange) ?>" 
                           placeholder="Select date range...">
                    <i class="fa-regular fa-calendar" style="position: absolute; right: 15px; top: 15px; color: #94a3b8; pointer-events: none;"></i>
                </div>
                
                <label class="form-label">Transaction Type</label>
                <select name="type" class="form-select">
                    <option value="all" <?= $filterType == 'all' ? 'selected' : '' ?>>All Transactions</option>
                    <option value="income" <?= $filterType == 'income' ? 'selected' : '' ?>>Income Only</option>
                    <option value="expense" <?= $filterType == 'expense' ? 'selected' : '' ?>>Expenses Only</option>
                </select>

                <button type="submit" class="btn-green mt-3">Apply Filters</button>
                <a href="reports_financial.php" style="display:block; text-align:center; margin-top:15px; color:#94a3b8; text-decoration:none; font-size:13px;">Reset Filters</a>
            </form>
        </div>

        <div class="glass-card">
            <h5 class="mb-4" style="color:#38bdf8; font-size:16px;"><i class="fa-solid fa-file-export me-2"></i> Export</h5>
            <button class="btn-outline" onclick="genPDF()"><i class="fa-solid fa-file-pdf text-danger"></i> Download PDF</button>
            <button class="btn-outline" onclick="exportXLS()"><i class="fa-solid fa-file-excel text-success"></i> Export Excel</button>
            <button class="btn-outline" onclick="window.print()"><i class="fa-solid fa-print text-white"></i> Print View</button>
        </div>
    </aside>

    <section>
        
        <div class="kpi-grid">
            <div class="glass-card" style="margin:0; padding:20px;">
                <i class="fa-solid fa-arrow-trend-up kpi-icon text-success"></i>
                <div class="kpi-label">Revenue</div>
                <div class="kpi-val text-success">€ <?= number_format($totalIncome, 2, ',', '.') ?></div>
            </div>
            <div class="glass-card" style="margin:0; padding:20px;">
                <i class="fa-solid fa-arrow-trend-down kpi-icon text-danger"></i>
                <div class="kpi-label">Expenses</div>
                <div class="kpi-val text-danger">€ <?= number_format($totalExpense, 2, ',', '.') ?></div>
            </div>
            <div class="glass-card" style="margin:0; padding:20px;">
                <i class="fa-solid fa-scale-balanced kpi-icon text-white"></i>
                <div class="kpi-label">Net Profit</div>
                <div class="kpi-val <?= $netProfit >= 0 ? 'text-success' : 'text-danger' ?>">
                    <?= $netProfit >= 0 ? '+' : '' ?> € <?= number_format($netProfit, 2, ',', '.') ?>
                </div>
            </div>
            <div class="glass-card" style="margin:0; padding:20px;">
                <i class="fa-solid fa-percent kpi-icon text-info"></i>
                <div class="kpi-label">Margin</div>
                <div class="kpi-val text-info"><?= e($margin) ?>%</div>
            </div>
        </div>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 25px; margin-bottom: 25px;">
            <div class="glass-card" style="margin:0;">
                <h5 class="mb-4 text-white-50" style="font-size:14px; text-transform:uppercase;">Cash Flow Analysis</h5>
                <div style="height: 250px;">
                    <canvas id="cashFlowChart"></canvas>
                </div>
            </div>
            <div class="glass-card" style="margin:0;">
                <h5 class="mb-4 text-white-50" style="font-size:14px; text-transform:uppercase;">Cost Distribution</h5>
                <div style="height: 250px;">
                    <canvas id="costPieChart"></canvas>
                </div>
            </div>
        </div>

        <div class="glass-card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:20px;">
                <h5 class="mb-0" style="font-size:18px;">Unified Financial Ledger</h5>
                <span style="font-size:12px; color:#94a3b8; background:rgba(255,255,255,0.05); padding:5px 10px; border-radius:20px;">
                    <?= count($transactions) ?> records
                </span>
            </div>
            
            <div style="overflow-x:auto;">
                <table class="glass-table" id="finTable">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Category</th>
                            <th>Description</th>
                            <th class="text-end">Value (€)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($transactions)): ?>
                            <tr><td colspan="5" style="text-align:center; padding:30px; color:#94a3b8;">No records found for this period.</td></tr>
                        <?php else: foreach($transactions as $row): 
                            $isInc = $row['type'] === 'Income';
                        ?>
                        <tr>
                            <td><?= date('d/m/Y', strtotime($row['trans_date'])) ?></td>
                            <td>
                                <span style="font-size:11px; font-weight:700; padding:4px 8px; border-radius:4px; text-transform:uppercase; 
                                    background: <?= $isInc ? 'rgba(74,222,128,0.1); color:#4ade80;' : 'rgba(248,113,113,0.1); color:#f87171;' ?>">
                                    <?= e($row['type']) ?>
                                </span>
                            </td>
                            <td><?= $row['category'] ?: 'General' ?></td>
                            <td style="color:#cbd5e1;"><?= htmlspecialchars($row['description']) ?></td>
                            <td class="text-end" style="font-family:monospace; font-size:14px; font-weight:600; color: <?= $isInc ? '#4ade80' : '#fff' ?>">
                                <?= $isInc ? '+' : '-' ?> <?= number_format($row['amount'], 2, ',', '.') ?>
                            </td>
                        </tr>
                        <?php endforeach; endif; ?>
                    </tbody>
                    <tfoot>
                        <tr style="border-top: 2px solid rgba(255,255,255,0.1);">
                            <td colspan="4" style="text-align:right; font-weight:700; color:#fff; padding-top:20px;">TOTAL BALANCE</td>
                            <td style="text-align:right; font-weight:700; font-size:16px; padding-top:20px; color:<?= $netProfit >= 0 ? '#4ade80' : '#f87171' ?>">
                                € <?= number_format($netProfit, 2, ',', '.') ?>
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

    </section>
</div>

<div id="metaData" 
     data-start="<?= date('d/m/Y', strtotime($startDate)) ?>" 
     data-end="<?= date('d/m/Y', strtotime($endDate)) ?>"
     data-profit="€ <?= number_format($netProfit, 2, ',', '.') ?>">
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.31/jspdf.plugin.autotable.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>

<script>
    // 1. INICIALIZAR FLATPICKR (O Ajuste Visual)
    flatpickr("#dateRangePicker", {
        mode: "range",
        dateFormat: "Y-m-d",
        theme: "dark",
        // Mostra o range atual como padrão
        defaultDate: ["<?= e($startDate) ?>", "<?= e($endDate) ?>"]
    });

    // 2. CONFIGURAÇÃO DOS GRÁFICOS
    Chart.defaults.color = '#94a3b8';
    Chart.defaults.borderColor = 'rgba(255,255,255,0.05)';
    Chart.defaults.font.family = "'Segoe UI', sans-serif";

    // Gráfico de Barras (Fluxo de Caixa)
    new Chart(document.getElementById('cashFlowChart'), {
        type: 'bar',
        data: {
            labels: <?= json_encode($chartLabels, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
            datasets: [
                {
                    label: 'Income',
                    data: <?= json_encode($chartIncome, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
                    backgroundColor: '#4ade80',
                    borderRadius: 4,
                    barPercentage: 0.6
                },
                {
                    label: 'Expenses',
                    data: <?= json_encode($chartExpense, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
                    backgroundColor: '#f87171',
                    borderRadius: 4,
                    barPercentage: 0.6
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: { y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.05)' } } },
            plugins: { legend: { position: 'top', align: 'end' } }
        }
    });

    // Gráfico de Rosca (Categorias)
    new Chart(document.getElementById('costPieChart'), {
        type: 'doughnut',
        data: {
            labels: <?= json_encode(array_keys($catBreakdown), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
            datasets: [{
                data: <?= json_encode(array_values($catBreakdown), JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>,
                backgroundColor: ['#f87171', '#fbbf24', '#60a5fa', '#a78bfa', '#34d399', '#f472b6'],
                borderWidth: 0,
                hoverOffset: 10
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { position: 'right', labels: { boxWidth: 12, font: { size: 11 } } } },
            cutout: '70%'
        }
    });

    // 3. EXPORTAR EXCEL
    function exportXLS() {
        const table = document.getElementById("finTable");
        // Remove footer for clean excel export if needed, or keep it
        const wb = XLSX.utils.table_to_book(table, {sheet: "Financials"});
        XLSX.writeFile(wb, "Farm_Financial_Report.xlsx");
    }

    // 4. EXPORTAR PDF (Layout Profissional)
    function genPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        
        const start = document.getElementById('metaData').dataset.start;
        const end = document.getElementById('metaData').dataset.end;
        const profit = document.getElementById('metaData').dataset.profit;

        // Cabeçalho Escuro
        doc.setFillColor(15, 23, 42); 
        doc.rect(0, 0, 210, 45, 'F');

        // Título e Logo Texto
        doc.setFontSize(22);
        doc.setTextColor(74, 222, 128); // Verde
        doc.text("FARM FINANCIAL REPORT", 14, 20);

        // Subtítulo
        doc.setFontSize(10);
        doc.setTextColor(200, 200, 200);
        doc.text(`Period: ${start} to ${end}`, 14, 30);
        doc.text(`Generated on: ${new Date().toLocaleDateString()}`, 14, 36);

        // Caixa de Lucro Líquido no PDF
        doc.setDrawColor(255, 255, 255);
        doc.setFillColor(30, 41, 59);
        doc.roundedRect(140, 10, 60, 25, 3, 3, 'FD');
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(9);
        doc.text("NET PROFIT", 170, 18, {align:'center'});
        doc.setFontSize(14);
        // Define cor verde ou vermelha baseada no sinal
        if(profit.includes('-')) doc.setTextColor(248, 113, 113);
        else doc.setTextColor(74, 222, 128);
        
        doc.text(profit, 170, 28, {align:'center'});

        // Tabela
        doc.autoTable({
            html: '#finTable',
            startY: 55,
            theme: 'grid',
            headStyles: { fillColor: [15, 23, 42], textColor: [255, 255, 255], lineColor: [50, 50, 50] },
            bodyStyles: { textColor: [40, 40, 40], fontSize: 9 },
            footStyles: { fillColor: [240, 240, 240], textColor: [0, 0, 0], fontStyle: 'bold' },
            alternateRowStyles: { fillColor: [248, 248, 248] },
            columnStyles: { 4: { halign: 'right', fontStyle: 'bold' } }
        });

        doc.save('Farm_Financial_Report.pdf');
    }
</script>

</body>
</html>