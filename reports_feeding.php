<?php
/* =========================================================
   reports_feeding.php — Feeding Intelligence Dashboard
   Style: Premium Glass (Matches animal.php)
   Features: Cost Analysis, Consumption Trends, KPI Cards
   ========================================================= */
require_once 'config.php';

// Security Check
if (!isset($conn)) { die("Database connection error."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

// --- FILTER LOGIC ---
$start_date = valid_date($_GET['start_date'] ?? null, date('Y-m-01')); // Default: 1st of current month
$end_date   = valid_date($_GET['end_date'] ?? null, date('Y-m-d'));     // Default: Today
$lot_filter = !empty($_GET['lot_id']) ? (int) $_GET['lot_id'] : '';

// --- 1. KPI QUERIES (Aggregated Data) ---
// We join daily_feeding with feed to calculate costs dynamically based on quantity * cost_per_kg
$sql_kpi = "SELECT 
                COUNT(df.feeding_id) as total_events,
                SUM(df.quantity_kg) as total_kg,
                SUM(df.quantity_kg * f.cost_per_kg) as total_cost,
                AVG(df.quantity_kg) as avg_consumption
            FROM daily_feeding df
            JOIN feed f ON df.feed_id = f.feed_id
            LEFT JOIN lot_animals la ON df.animal_id = la.animal_id AND df.feeding_date >= la.entry_date AND (la.exit_date IS NULL OR df.feeding_date <= la.exit_date)
            WHERE df.feeding_date BETWEEN ? AND ?";

$params_kpi = [$start_date, $end_date];
$types_kpi = "ss";

if (!empty($lot_filter)) {
    $sql_kpi .= " AND la.lot_id = ?";
    $params_kpi[] = $lot_filter;
    $types_kpi .= "i";
}

$stmt_kpi = $conn->prepare($sql_kpi);
$stmt_kpi->bind_param($types_kpi, ...$params_kpi);
$stmt_kpi->execute();
$kpi_data = $stmt_kpi->get_result()->fetch_assoc();

// --- 2. CHART DATA: Consumption per Day ---
$sql_chart_daily = "SELECT df.feeding_date, SUM(df.quantity_kg) as daily_kg 
                    FROM daily_feeding df 
                    LEFT JOIN lot_animals la ON df.animal_id = la.animal_id AND df.feeding_date >= la.entry_date AND (la.exit_date IS NULL OR df.feeding_date <= la.exit_date)
                    WHERE df.feeding_date BETWEEN ? AND ? ";
if (!empty($lot_filter)) { $sql_chart_daily .= " AND la.lot_id = " . intval($lot_filter); }
$sql_chart_daily .= " GROUP BY df.feeding_date ORDER BY df.feeding_date ASC";

$stmt_chart1 = $conn->prepare($sql_chart_daily);
$stmt_chart1->bind_param("ss", $start_date, $end_date);
$stmt_chart1->execute();
$res_chart1 = $stmt_chart1->get_result();

$dates_arr = [];
$kg_arr = [];
while($row = $res_chart1->fetch_assoc()) {
    $dates_arr[] = date('d/m', strtotime($row['feeding_date']));
    $kg_arr[] = $row['daily_kg'];
}

// --- 3. CHART DATA: Cost by Feed Type ---
$sql_chart_type = "SELECT f.name, SUM(df.quantity_kg * f.cost_per_kg) as type_cost
                   FROM daily_feeding df
                   JOIN feed f ON df.feed_id = f.feed_id
                   LEFT JOIN lot_animals la ON df.animal_id = la.animal_id AND df.feeding_date >= la.entry_date AND (la.exit_date IS NULL OR df.feeding_date <= la.exit_date)
                   WHERE df.feeding_date BETWEEN ? AND ? ";
if (!empty($lot_filter)) { $sql_chart_type .= " AND la.lot_id = " . intval($lot_filter); }
$sql_chart_type .= " GROUP BY f.feed_id";

$stmt_chart2 = $conn->prepare($sql_chart_type);
$stmt_chart2->bind_param("ss", $start_date, $end_date);
$stmt_chart2->execute();
$res_chart2 = $stmt_chart2->get_result();

$feed_names = [];
$feed_costs = [];
while($row = $res_chart2->fetch_assoc()) {
    $feed_names[] = $row['name'];
    $feed_costs[] = $row['type_cost'];
}

// --- 4. DETAILED TABLE DATA ---
$sql_table = "SELECT df.*, a.tag_number, f.name as feed_name, f.cost_per_kg,
              (df.quantity_kg * f.cost_per_kg) as calculated_cost,
              l.name as lot_name
              FROM daily_feeding df
              JOIN animal a ON df.animal_id = a.animal_id
              JOIN feed f ON df.feed_id = f.feed_id
              LEFT JOIN lot_animals la ON a.animal_id = la.animal_id AND df.feeding_date >= la.entry_date AND (la.exit_date IS NULL OR df.feeding_date <= la.exit_date)
              LEFT JOIN lot l ON la.lot_id = l.lot_id
              WHERE df.feeding_date BETWEEN ? AND ?";

if (!empty($lot_filter)) {
    $sql_table .= " AND l.lot_id = ?";
}
$sql_table .= " ORDER BY df.feeding_date DESC, df.feeding_id DESC LIMIT 200";

$stmt_table = $conn->prepare($sql_table);
if (!empty($lot_filter)) {
    $stmt_table->bind_param("ssi", $start_date, $end_date, $lot_filter);
} else {
    $stmt_table->bind_param("ss", $start_date, $end_date);
}
$stmt_table->execute();
$table_data = $stmt_table->get_result();

// --- FETCH LOTS FOR FILTER ---
$lots_opts = $conn->query("SELECT lot_id, name FROM lot ORDER BY name ASC");

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Feeding Reports | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        /* --- COPYING STYLE FROM animal.php (Premium Glass) --- */
        :root { --brand: #4ade80; --bg-dark: #05070a; --panel: rgba(20, 26, 38, 0.85); --border: rgba(255, 255, 255, 0.15); --text: #eaf1ff; --muted: #9fb0d0; --input-bg: rgba(255, 255, 255, 0.07); }
        
        body { background-color: var(--bg-dark); background-image: url('assets/img/dowloag.png'); background-size: cover; background-position: center; background-attachment: fixed; color: var(--text); font-family: "Segoe UI", sans-serif; overflow-x: hidden; }
        body::before { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(10, 15, 25, 0.85); z-index: -1; }
        
        /* HEADER */
        .topbar { background: rgba(15, 23, 42, 0.95); padding: 0 40px; height: 64px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); backdrop-filter: blur(15px); position: sticky; top: 0; z-index: 1000; }
        .brand { font-size: 22px; font-weight: 700; color: var(--brand); display:flex; gap:10px; align-items:center; text-decoration: none; }
        .menu { display:flex; gap:15px; align-items:center; height: 100%; }
        .menu a.nav-link { color: var(--muted); text-decoration:none; display:flex; gap:8px; align-items:center; font-size:14px; transition:.2s; height: 100%; padding: 0 10px; }
        .menu a.nav-link:hover, .menu a.nav-link.active { color: var(--brand); }

        /* MAIN LAYOUT */
        .main { padding: 40px; min-height: calc(100vh - 64px); max-width: 1400px; margin: 0 auto; }
        
        /* CARDS & GLASS */
        .glass-panel { background: var(--panel); backdrop-filter: blur(12px); border: 1px solid var(--border); border-radius: 16px; padding: 25px; margin-bottom: 25px; box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3); }
        .kpi-card { background: linear-gradient(145deg, rgba(255,255,255,0.05) 0%, rgba(255,255,255,0.01) 100%); border: 1px solid var(--border); border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 20px; transition: transform 0.2s; }
        .kpi-card:hover { transform: translateY(-5px); border-color: var(--brand); }
        .kpi-icon { width: 50px; height: 50px; border-radius: 12px; background: rgba(74, 222, 128, 0.1); display: flex; align-items: center; justify-content: center; font-size: 24px; color: var(--brand); }
        .kpi-val { font-size: 24px; font-weight: 700; color: #fff; margin: 0; }
        .kpi-label { font-size: 13px; color: var(--muted); text-transform: uppercase; letter-spacing: 0.5px; }

        /* FORMS & FILTERS */
        .filter-bar { display: flex; gap: 15px; align-items: end; flex-wrap: wrap; margin-bottom: 30px; }
        .form-control, .form-select { background: var(--input-bg) !important; border: 1px solid var(--border) !important; color: #fff !important; border-radius: 8px; padding: 10px 15px; }
        .form-control:focus, .form-select:focus { border-color: var(--brand) !important; box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.1); }
        label { font-size: 11px; text-transform: uppercase; color: var(--muted); font-weight: 600; margin-bottom: 6px; display: block; }
        .btn-brand { background: var(--brand); color: #000; font-weight: 600; border: none; padding: 10px 25px; border-radius: 8px; transition: .2s; }
        .btn-brand:hover { background: #3dd670; transform: scale(1.02); }

        /* TABLE */
        .table-custom { width: 100%; border-collapse: separate; border-spacing: 0 8px; }
        .table-custom th { color: var(--muted); font-size: 12px; text-transform: uppercase; font-weight: 600; padding: 15px; border-bottom: 1px solid var(--border); }
        .table-custom td { background: rgba(255,255,255,0.02); color: var(--text); padding: 15px; font-size: 14px; border-top: 1px solid var(--border); border-bottom: 1px solid var(--border); }
        .table-custom td:first-child { border-left: 1px solid var(--border); border-radius: 10px 0 0 10px; }
        .table-custom td:last-child { border-right: 1px solid var(--border); border-radius: 0 10px 10px 0; }
        .tag-badge { background: rgba(74, 222, 128, 0.15); color: var(--brand); padding: 4px 10px; border-radius: 6px; font-family: monospace; font-size: 13px; }
        
        .section-title { font-size: 18px; font-weight: 600; color: #fff; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
        .section-title i { color: var(--brand); }
    </style>
</head>
<body>

    <div class="topbar">
        <a href="index.php" class="brand">
            <i class="fa-solid fa-cow"></i> FarmProject
        </a>
        <div class="menu">
            <a href="index.php" class="nav-link"><i class="fa-solid fa-home"></i> Dashboard</a>
            <a href="animal.php" class="nav-link"><i class="fa-solid fa-paw"></i> Animals</a>
            <a href="reports_feeding.php" class="nav-link active"><i class="fa-solid fa-chart-pie"></i> Reports</a>
            <a href="logout.php" class="nav-link" style="color: #ef4444;"><i class="fa-solid fa-sign-out"></i></a>
        </div>
    </div>

    <div class="main">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="text-white fw-bold"><i class="fa-solid fa-wheat-awn me-2 text-success"></i> Feeding Intelligence</h2>
            <button onclick="window.print()" class="btn btn-outline-light btn-sm"><i class="fa-solid fa-print"></i> Print Report</button>
        </div>

        <div class="glass-panel">
            <form method="GET" class="filter-bar mb-0">
                <div class="flex-grow-1" style="max-width: 200px;">
                    <label>Start Date</label>
                    <input type="date" name="start_date" class="form-control" value="<?= e($start_date) ?>">
                </div>
                <div class="flex-grow-1" style="max-width: 200px;">
                    <label>End Date</label>
                    <input type="date" name="end_date" class="form-control" value="<?= e($end_date) ?>">
                </div>
                <div class="flex-grow-1" style="max-width: 250px;">
                    <label>Filter by Lot</label>
                    <select name="lot_id" class="form-select">
                        <option value="">All Lots</option>
                        <?php while($l = $lots_opts->fetch_assoc()): ?>
                            <option value="<?= e($l['lot_id']) ?>" <?php echo ($lot_filter == $l['lot_id']) ? 'selected' : ''; ?>>
                                <?php echo htmlspecialchars($l['name']); ?>
                            </option>
                        <?php endwhile; ?>
                    </select>
                </div>
                <div>
                    <button type="submit" class="btn btn-brand"><i class="fa-solid fa-filter"></i> Apply Filters</button>
                </div>
            </form>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-icon"><i class="fa-solid fa-weight-hanging"></i></div>
                    <div>
                        <div class="kpi-label">Total Consumed</div>
                        <div class="kpi-val"><?php echo number_format($kpi_data['total_kg'], 1); ?> <small class="fs-6 text-muted">kg</small></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-icon" style="color: #facc15; background: rgba(250, 204, 21, 0.1);"><i class="fa-solid fa-euro-sign"></i></div>
                    <div>
                        <div class="kpi-label">Total Cost (Est)</div>
                        <div class="kpi-val">€ <?php echo number_format($kpi_data['total_cost'], 2); ?></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-icon" style="color: #60a5fa; background: rgba(96, 165, 250, 0.1);"><i class="fa-solid fa-scale-balanced"></i></div>
                    <div>
                        <div class="kpi-label">Avg / Feeding</div>
                        <div class="kpi-val"><?php echo number_format($kpi_data['avg_consumption'], 2); ?> <small class="fs-6 text-muted">kg</small></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="kpi-card">
                    <div class="kpi-icon" style="color: #f472b6; background: rgba(244, 114, 182, 0.1);"><i class="fa-solid fa-calendar-check"></i></div>
                    <div>
                        <div class="kpi-label">Feeding Events</div>
                        <div class="kpi-val"><?= e($kpi_data['total_events']) ?></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4 mb-4">
            <div class="col-md-8">
                <div class="glass-panel h-100">
                    <div class="section-title"><i class="fa-solid fa-chart-area"></i> Consumption Trend (Kg)</div>
                    <canvas id="consumptionChart" style="max-height: 300px;"></canvas>
                </div>
            </div>
            <div class="col-md-4">
                <div class="glass-panel h-100">
                    <div class="section-title"><i class="fa-solid fa-coins"></i> Cost by Feed Type</div>
                    <canvas id="costChart" style="max-height: 250px;"></canvas>
                </div>
            </div>
        </div>

        <div class="glass-panel">
            <div class="section-title"><i class="fa-solid fa-list"></i> Detailed Feeding Log</div>
            <div class="table-responsive">
                <table class="table-custom">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Animal Tag</th>
                            <th>Lot</th>
                            <th>Feed Type</th>
                            <th>Quantity (Kg)</th>
                            <th>Unit Cost</th>
                            <th>Total Cost</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if($table_data->num_rows > 0): ?>
                            <?php while($row = $table_data->fetch_assoc()): ?>
                            <tr>
                                <td><?php echo date('d M Y', strtotime($row['feeding_date'])); ?></td>
                                <td><span class="tag-badge"><?= e($row['tag_number']) ?></span></td>
                                <td class="text-muted"><?php echo $row['lot_name'] ? $row['lot_name'] : '-'; ?></td>
                                <td><?= e($row['feed_name']) ?></td>
                                <td class="fw-bold text-white"><?= e($row['quantity_kg']) ?></td>
                                <td class="text-muted">€<?= e($row['cost_per_kg']) ?></td>
                                <td style="color: var(--brand);">€<?php echo number_format($row['calculated_cost'], 2); ?></td>
                            </tr>
                            <?php endwhile; ?>
                        <?php else: ?>
                            <tr><td colspan="7" class="text-center py-4 text-muted">No records found for this period.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

    </div>

    <script>
        // Data from PHP
        const dates = <?php echo json_encode($dates_arr); ?>;
        const dailyKg = <?php echo json_encode($kg_arr); ?>;
        const feedNames = <?php echo json_encode($feed_names); ?>;
        const feedCosts = <?php echo json_encode($feed_costs); ?>;

        // Chart 1: Line Chart for Daily Consumption
        const ctx1 = document.getElementById('consumptionChart').getContext('2d');
        // Create Gradient
        let gradient = ctx1.createLinearGradient(0, 0, 0, 400);
        gradient.addColorStop(0, 'rgba(74, 222, 128, 0.5)'); // Brand color
        gradient.addColorStop(1, 'rgba(74, 222, 128, 0.0)');

        new Chart(ctx1, {
            type: 'line',
            data: {
                labels: dates,
                datasets: [{
                    label: 'Feed Consumed (Kg)',
                    data: dailyKg,
                    borderColor: '#4ade80',
                    backgroundColor: gradient,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#fff',
                    pointRadius: 4
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } },
                scales: {
                    x: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#9fb0d0' } },
                    y: { grid: { color: 'rgba(255,255,255,0.05)' }, ticks: { color: '#9fb0d0' } }
                }
            }
        });

        // Chart 2: Doughnut for Cost
        new Chart(document.getElementById('costChart'), {
            type: 'doughnut',
            data: {
                labels: feedNames,
                datasets: [{
                    data: feedCosts,
                    backgroundColor: ['#4ade80', '#60a5fa', '#facc15', '#f472b6'],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                plugins: { 
                    legend: { position: 'bottom', labels: { color: '#9fb0d0' } } 
                }
            }
        });
    </script>

</body>
</html>