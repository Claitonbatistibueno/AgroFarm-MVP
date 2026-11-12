<?php
/* =========================================================
   FARM PROJECT - FEEDING MANAGER (PRO VERSION)
   Style: Matched to Login.php (Premium Glass / Neon Green)
   Features: Individual, Fixed Batch, & Proportional Batch
   ========================================================= */

require_once 'config.php';
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// --- FORM PROCESSING ---

// 1. DELETE RECORD
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    $del = $conn->prepare("DELETE FROM daily_feeding WHERE feeding_id = ?");
    $del->bind_param("i", $id);
    $del->execute();
    $msg = "Record deleted."; $msg_type = "success";
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    
    // 2. INDIVIDUAL FEEDING
    if ($_POST['action'] == 'save_individual') {
        $stmt = $conn->prepare("INSERT INTO daily_feeding (animal_id, feed_id, feeding_date, quantity_kg) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("iisd", $_POST['animal_id'], $_POST['feed_id'], $_POST['date'], $_POST['quantity']);
        if ($stmt->execute()) { $msg = "Individual feeding saved."; $msg_type = "success"; }
        else { $msg = "Error: " . $conn->error; $msg_type = "danger"; }
    }

    // 3. FIXED BATCH (Example: Give 2kg to EVERY animal in Lot A)
    if ($_POST['action'] == 'save_batch_fixed') {
        $lot_id = $_POST['lot_id'];
        $date   = $_POST['date'];
        $qty    = floatval($_POST['quantity']); // Amount per animal

        // Find animals active in this lot ON THIS DATE
        $sql = "SELECT animal_id FROM lot_animals 
                WHERE lot_id = ? AND entry_date <= ? AND (exit_date IS NULL OR exit_date >= ?)";
        $stmt_lot = $conn->prepare($sql);
        $stmt_lot->bind_param("iss", $lot_id, $date, $date);
        $stmt_lot->execute();
        $result = $stmt_lot->get_result();

        if ($result->num_rows > 0) {
            $stmt_ins = $conn->prepare("INSERT INTO daily_feeding (animal_id, feed_id, feeding_date, quantity_kg) VALUES (?, ?, ?, ?)");
            $count = 0;
            while ($row = $result->fetch_assoc()) {
                $stmt_ins->bind_param("iisd", $row['animal_id'], $_POST['feed_id'], $date, $qty);
                $stmt_ins->execute();
                $count++;
            }
            $msg = "Fixed Batch: Fed $qty kg to <b>$count</b> animals."; $msg_type = "success";
        } else {
            $msg = "No active animals found in this lot on selected date."; $msg_type = "warning";
        }
    }

    // 4. PROPORTIONAL BATCH (Example: Split 50kg bag among all animals in Lot A)
   
    if ($_POST['action'] == 'save_batch_proportional') {
        $lot_id    = $_POST['lot_id'];
        $date      = $_POST['date'];
        $total_qty = floatval($_POST['total_quantity']); // Total bag weight

        // Find animals active in this lot ON THIS DATE
        $sql = "SELECT animal_id FROM lot_animals 
                WHERE lot_id = ? AND entry_date <= ? AND (exit_date IS NULL OR exit_date >= ?)";
        $stmt_lot = $conn->prepare($sql);
        $stmt_lot->bind_param("iss", $lot_id, $date, $date);
        $stmt_lot->execute();
        $result = $stmt_lot->get_result();
        $animal_count = $result->num_rows;

        if ($animal_count > 0) {
            // Calculate proportional amount
            $qty_per_head = $total_qty / $animal_count;

            $stmt_ins = $conn->prepare("INSERT INTO daily_feeding (animal_id, feed_id, feeding_date, quantity_kg) VALUES (?, ?, ?, ?)");
            while ($row = $result->fetch_assoc()) {
                $stmt_ins->bind_param("iisd", $row['animal_id'], $_POST['feed_id'], $date, $qty_per_head);
                $stmt_ins->execute();
            }
            // Format number for cleaner message
            $per_head_fmt = number_format($qty_per_head, 3);
            $msg = "Proportional Feed: Split $total_qty kg among $animal_count animals ($per_head_fmt kg/each)."; $msg_type = "success";
        } else {
            $msg = "No active animals found in this lot on selected date."; $msg_type = "warning";
        }
    }
}

// --- DATA FETCHING ---
$today = date('Y-m-d');
$kpi = $conn->query("SELECT COUNT(*) as drops, COALESCE(SUM(quantity_kg),0) as kg, COALESCE(SUM(df.quantity_kg * f.cost_per_kg),0) as cost 
                     FROM daily_feeding df JOIN feed f ON df.feed_id = f.feed_id WHERE df.feeding_date = '$today'")->fetch_assoc();

$feeds = $conn->query("SELECT * FROM feed ORDER BY name");
$lots  = $conn->query("SELECT * FROM lot ORDER BY name");
$animals = $conn->query("SELECT animal_id, tag_number FROM animal WHERE status='active' ORDER BY tag_number");

$history = $conn->query("SELECT df.*, a.tag_number, f.name as feed_name, (df.quantity_kg * f.cost_per_kg) as cost 
                         FROM daily_feeding df 
                         JOIN animal a ON df.animal_id = a.animal_id 
                         JOIN feed f ON df.feed_id = f.feed_id 
                         ORDER BY df.feeding_id DESC LIMIT 20");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Feeding | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        :root {
            --brand-green: #3cff8f;
            --brand-glow: rgba(60, 255, 143, 0.2);
            --bg-dark: #05070a;
            --glass: rgba(18, 24, 33, 0.70);
            --glass-hover: rgba(18, 24, 33, 0.90);
            --border: rgba(255, 255, 255, 0.1);
            --input-bg: rgba(0, 0, 0, 0.4);
            --text-main: #ffffff;
            --text-muted: rgba(255, 255, 255, 0.6);
        }

        body {
            background-color: var(--bg-dark);
            background-image: url('assets/img/dowloag.png'); 
            background-size: cover; background-position: center; background-attachment: fixed;
            color: var(--text-main); font-family: 'Inter', sans-serif;
            min-height: 100vh; overflow-x: hidden;
        }
        body::before {
            content: ""; position: fixed; inset: 0; background: rgba(5, 7, 10, 0.85); backdrop-filter: blur(5px); z-index: -1;
        }

        /* --- NAVIGATION --- */
        .topbar {
            background: var(--glass); border-bottom: 1px solid var(--border);
            padding: 0 40px; height: 70px; display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 1000; backdrop-filter: blur(15px);
        }
        .brand { font-size: 20px; font-weight: 700; color: var(--brand-green); text-decoration: none; letter-spacing: -0.5px; display: flex; align-items: center; gap: 10px; }
        .nav-items a { color: var(--text-muted); text-decoration: none; margin-left: 25px; font-size: 14px; font-weight: 500; transition: 0.3s; }
        .nav-items a:hover, .nav-items a.active { color: var(--brand-green); }
        .nav-items a.active { font-weight: 700; text-shadow: 0 0 10px var(--brand-glow); }

        /* --- CARDS & LAYOUT --- */
        .main-container { max-width: 1400px; margin: 40px auto; padding: 0 20px; }
        
        .glass-card {
            background: var(--glass); border: 1px solid var(--border); border-radius: 20px;
            padding: 30px; margin-bottom: 30px; box-shadow: 0 20px 50px rgba(0,0,0,0.3);
            transition: transform 0.3s ease;
        }
        
        /* --- KPI GRID --- */
        .kpi-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 30px; }
        .kpi-box { 
            background: rgba(255,255,255,0.03); border: 1px solid var(--border); 
            border-radius: 16px; padding: 20px; display: flex; align-items: center; gap: 20px; 
        }
        .kpi-icon { 
            width: 50px; height: 50px; background: rgba(60, 255, 143, 0.1); 
            color: var(--brand-green); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px;
        }
        .kpi-value { font-size: 24px; font-weight: 700; line-height: 1; margin-bottom: 5px; }
        .kpi-label { font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 1px; }

        /* --- BUTTONS --- */
        .btn-neon {
            background: var(--brand-green); color: #05070a; font-weight: 700; border: none;
            padding: 12px 24px; border-radius: 10px; text-transform: uppercase; font-size: 13px; letter-spacing: 0.5px;
            cursor: pointer; transition: 0.3s; box-shadow: 0 0 15px var(--brand-glow);
        }
        .btn-neon:hover { background: #6effad; transform: translateY(-2px); box-shadow: 0 0 25px var(--brand-glow); }
        
        .btn-glass {
            background: rgba(255,255,255,0.05); color: #fff; border: 1px solid var(--border);
            padding: 12px 24px; border-radius: 10px; font-weight: 600; font-size: 13px; cursor: pointer; transition: 0.3s;
        }
        .btn-glass:hover { background: rgba(255,255,255,0.1); border-color: #fff; }

        /* --- INPUTS (Matched to Login) --- */
        .custom-input {
            background: var(--input-bg); border: 1px solid var(--border); color: #fff;
            padding: 12px 15px; border-radius: 10px; width: 100%; outline: none; transition: 0.3s;
        }
        .custom-input:focus { border-color: var(--brand-green); box-shadow: 0 0 0 2px var(--brand-glow); }
        label { font-size: 12px; text-transform: uppercase; color: var(--text-muted); font-weight: 600; margin-bottom: 8px; display: block; letter-spacing: 0.5px; }

        /* --- TABLE --- */
        .neon-table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        .neon-table th { text-align: left; padding: 15px; color: var(--text-muted); font-size: 12px; text-transform: uppercase; border-bottom: 1px solid var(--border); }
        .neon-table td { padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.05); font-size: 14px; }
        .neon-table tr:hover td { background: rgba(255,255,255,0.02); }
        .tag-badge { background: rgba(255,255,255,0.1); padding: 4px 8px; border-radius: 6px; font-family: monospace; }
        .delete-btn { color: #ff5555; cursor: pointer; transition: 0.2s; }
        .delete-btn:hover { color: #ff8888; transform: scale(1.1); }

        /* --- MODAL OVERRIDES --- */
        .modal-content { background: #0f131a; border: 1px solid var(--border); color: #fff; border-radius: 20px; }
        .modal-header { border-bottom: 1px solid var(--border); }
        .modal-footer { border-top: 1px solid var(--border); }
        .btn-close { filter: invert(1); }
    </style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> FARM PROJECT</a>
    <div class="nav-items">
        <a href="dashboard.php">Overview</a>
        <a href="animal.php">Animals</a>
        <a href="feeding.php" class="active">Feeding</a>
        <a href="weighing.php">Weighing</a>
        <a href="reports.php">Reports</a>
        <a href="dashboard.php?logout=true" style="color: #ff5555;"><i class="fa-solid fa-power-off"></i></a>
    </div>
</div>

<div class="main-container">

    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:30px;">
        <div>
            <h1 style="font-size:28px; font-weight:700; margin:0;">Feeding Management</h1>
            <p style="color:var(--text-muted); margin-top:5px;">Nutrition control and cost tracking</p>
        </div>
        <div style="display:flex; gap:10px;">
            <button class="btn-glass" data-bs-toggle="modal" data-bs-target="#individualModal">
                <i class="fa-solid fa-cow me-2"></i> Individual
            </button>
            <button class="btn-glass" data-bs-toggle="modal" data-bs-target="#fixedBatchModal">
                <i class="fa-solid fa-layer-group me-2"></i> Fixed Batch
            </button>
            <button class="btn-neon" data-bs-toggle="modal" data-bs-target="#proportionalModal">
                <i class="fa-solid fa-scale-unbalanced me-2"></i> Proportional Split
            </button>
        </div>
    </div>

    <div class="kpi-grid">
        <div class="kpi-box">
            <div class="kpi-icon"><i class="fa-solid fa-weight-hanging"></i></div>
            <div>
                <div class="kpi-value"><?= number_format($kpi['kg'], 2) ?> kg</div>
                <div class="kpi-label">Fed Today</div>
            </div>
        </div>
        <div class="kpi-box">
            <div class="kpi-icon" style="color:#ffbb55; background:rgba(255,187,85,0.1);"><i class="fa-solid fa-sack-dollar"></i></div>
            <div>
                <div class="kpi-value">€ <?= number_format($kpi['cost'], 2) ?></div>
                <div class="kpi-label">Today's Cost</div>
            </div>
        </div>
        <div class="kpi-box">
            <div class="kpi-icon" style="color:#55aaff; background:rgba(85,170,255,0.1);"><i class="fa-solid fa-list-check"></i></div>
            <div>
                <div class="kpi-value"><?= e($kpi['drops']) ?></div>
                <div class="kpi-label">Feedings</div>
            </div>
        </div>
    </div>

    <?php if ($msg): ?>
        <div style="background: rgba(60,255,143,0.1); border: 1px solid var(--brand-green); color: var(--brand-green); padding: 15px; border-radius: 10px; margin-bottom: 30px;">
            <i class="fa-solid fa-circle-info me-2"></i> <?= $msg ?>
        </div>
    <?php endif; ?>

    <div class="glass-card">
        <h3 style="font-size:18px; font-weight:600; margin-bottom:20px; color:#fff;">Recent Activity</h3>
        <div style="overflow-x:auto;">
            <table class="neon-table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Animal</th>
                        <th>Feed</th>
                        <th>Quantity</th>
                        <th>Cost</th>
                        <th style="text-align:right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php while($row = $history->fetch_assoc()): ?>
                    <tr>
                        <td style="color:var(--text-muted);"><?= date('d/m/Y', strtotime($row['feeding_date'])) ?></td>
                        <td><span class="tag-badge"><?= e($row['tag_number']) ?></span></td>
                        <td><?= e($row['feed_name']) ?></td>
                        <td style="color:var(--brand-green); font-weight:700;"><?= number_format($row['quantity_kg'], 2) ?> kg</td>
                        <td>€ <?= number_format($row['cost'], 2) ?></td>
                        <td style="text-align:right;">
                            <a href="?delete=<?= e($row['feeding_id']) ?>" class="delete-btn" onclick="return confirm('Remove entry?')"><i class="fa-solid fa-trash"></i></a>
                        </td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    </div>

</div>

<div class="modal fade" id="proportionalModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" style="color:var(--brand-green); font-weight:700;">
                    <i class="fa-solid fa-scale-unbalanced me-2"></i> Proportional Split
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_batch_proportional">
                    <p style="font-size:13px; color:var(--text-muted); margin-bottom:20px;">
                        Distribute a total weight (e.g., 50kg bag) across all animals present in a lot on the specific date.
                    </p>

                    <div class="mb-3">
                        <label>Target Lot</label>
                        <select name="lot_id" class="custom-input" required>
                            <?php 
                            $lots->data_seek(0);
                            while($l = $lots->fetch_assoc()): ?>
                                <option value="<?= e($l['lot_id']) ?>"><?= e($l['name']) ?></option>
                            <?php endwhile; ?>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label>Feed Type</label>
                        <select name="feed_id" class="custom-input" required>
                            <?php 
                            $feeds->data_seek(0);
                            while($f = $feeds->fetch_assoc()): ?>
                                <option value="<?= e($f['feed_id']) ?>"><?= e($f['name']) ?></option>
                            <?php endwhile; ?>
                        </select>
                    </div>

                    <div class="row">
                        <div class="col-6 mb-3">
                            <label>Total Qty (Bag Weight)</label>
                            <input type="number" step="0.01" name="total_quantity" class="custom-input" placeholder="e.g. 50" required>
                        </div>
                        <div class="col-6 mb-3">
                            <label>Date of Feeding</label>
                            <input type="date" name="date" class="custom-input" value="<?= date('Y-m-d') ?>" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn-neon" style="width:100%">Distribute & Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="fixedBatchModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Fixed Batch Feed</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_batch_fixed">
                    <p style="font-size:13px; color:var(--text-muted);">Give the exact same amount to every animal in a lot.</p>

                    <div class="mb-3">
                        <label>Target Lot</label>
                        <select name="lot_id" class="custom-input" required>
                            <?php 
                            $lots->data_seek(0);
                            while($l = $lots->fetch_assoc()): ?>
                                <option value="<?= e($l['lot_id']) ?>"><?= e($l['name']) ?></option>
                            <?php endwhile; ?>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>Feed Type</label>
                        <select name="feed_id" class="custom-input" required>
                            <?php 
                            $feeds->data_seek(0);
                            while($f = $feeds->fetch_assoc()): ?>
                                <option value="<?= e($f['feed_id']) ?>"><?= e($f['name']) ?></option>
                            <?php endwhile; ?>
                        </select>
                    </div>
                    <div class="row">
                        <div class="col-6 mb-3">
                            <label>Qty Per Animal (kg)</label>
                            <input type="number" step="0.01" name="quantity" class="custom-input" required>
                        </div>
                        <div class="col-6 mb-3">
                            <label>Date</label>
                            <input type="date" name="date" class="custom-input" value="<?= date('Y-m-d') ?>" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn-glass" style="width:100%; background:var(--brand-green); color:#000;">Run Batch</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="individualModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Individual Feed</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form method="POST">
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_individual">
                    
                    <div class="mb-3">
                        <label>Animal Tag</label>
                        <select name="animal_id" class="custom-input" required>
                            <option value="">Select...</option>
                            <?php while($a = $animals->fetch_assoc()): ?>
                                <option value="<?= e($a['animal_id']) ?>"><?= e($a['tag_number']) ?></option>
                            <?php endwhile; ?>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label>Feed</label>
                        <select name="feed_id" class="custom-input" required>
                            <?php 
                            $feeds->data_seek(0);
                            while($f = $feeds->fetch_assoc()): ?>
                                <option value="<?= e($f['feed_id']) ?>"><?= e($f['name']) ?></option>
                            <?php endwhile; ?>
                        </select>
                    </div>
                    <div class="row">
                        <div class="col-6">
                            <label>Quantity (kg)</label>
                            <input type="number" step="0.01" name="quantity" class="custom-input" required>
                        </div>
                        <div class="col-6">
                            <label>Date</label>
                            <input type="date" name="date" class="custom-input" value="<?= date('Y-m-d') ?>" required>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn-glass" style="width:100%; border-color:var(--brand-green); color:var(--brand-green);">Save Record</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>