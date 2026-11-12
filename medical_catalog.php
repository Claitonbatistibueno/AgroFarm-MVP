<?php
/* =========================================================
   medical_catalog.php — Veterinary & Services Catalog
   ========================================================= */
require_once 'config.php';

// Security
if (!isset($conn)) { die("Database connection error."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// --- 1. DELETAR ---
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    
    // Verifica se o item já foi usado em registros de saúde (Integridade)
    $check = $conn->query("SELECT COUNT(*) as c FROM health_records WHERE item_id = $id")->fetch_assoc();
    
    if ($check['c'] > 0) {
        $msg = "Cannot delete: This item has been used in health records.";
        $msg_type = "danger";
    } else {
        $stmt = $conn->prepare("DELETE FROM medical_catalog WHERE item_id = ?");
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            $msg = "Item deleted successfully!"; $msg_type = "success";
        } else {
            $msg = "Error deleting: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}

// --- 2. SAVE / UPDATE ---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_item') {
    $item_id = $_POST['item_id'];
    
    // Dados
    $name     = trim($_POST['item_name']);
    $type     = $_POST['type'];
    $supplier = !empty($_POST['supplier_id']) ? $_POST['supplier_id'] : NULL;
    $unit     = trim($_POST['unit']);
    $stock    = intval($_POST['stock_quantity']);
    $cost     = floatval($_POST['cost_price']); // obrigatórios
    $desc     = trim($_POST['description']);

    // Validation: Name, type and price
    if (empty($name) || empty($type) || $cost <= 0) {
        $msg = "Error: Item Name, Type and a valid Cost Price are required.";
        $msg_type = "danger";
    } else {
        
        if (!empty($item_id)) {
            // UPDATE (Removido sale_price)
            $stmt = $conn->prepare("UPDATE medical_catalog SET item_name=?, type=?, supplier_id=?, unit=?, stock_quantity=?, cost_price=?, description=? WHERE item_id=?");
            $stmt->bind_param("ssisidsi", $name, $type, $supplier, $unit, $stock, $cost, $desc, $item_id);
        } else {
            // INSERT (Removido sale_price)
            $stmt = $conn->prepare("INSERT INTO medical_catalog (item_name, type, supplier_id, unit, stock_quantity, cost_price, description) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssisids", $name, $type, $supplier, $unit, $stock, $cost, $desc);
        }

        if ($stmt->execute()) {
            $msg = "Catalog item saved successfully!"; $msg_type = "success";
        } else {
            $msg = "Database Error: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}

// --- LOOK ---
// Select Suppliers
$suppliers = $conn->query("SELECT supplier_id, name FROM suppliers WHERE status='active' ORDER BY name");

// Lista de Itens (JOIN com Fornecedores)
$sql_items = "SELECT m.*, s.name as supplier_name 
              FROM medical_catalog m 
              LEFT JOIN suppliers s ON m.supplier_id = s.supplier_id 
              ORDER BY CASE m.type WHEN 'medicine' THEN 1 WHEN 'vaccine' THEN 2 WHEN 'service' THEN 3 WHEN 'equipment' THEN 4 ELSE 5 END, m.item_name"; // same order as the old MySQL ENUM
$items_list = $conn->query($sql_items);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Medical Catalog | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    
    <style>
        /* --- PREMIUM GLASS THEME --- */
        :root {
            --brand: #4ade80;
            --bg-dark: #05070a;
            --panel: rgba(20, 26, 38, 0.85);
            --border: rgba(255, 255, 255, 0.15);
            --text: #eaf1ff;
            --muted: #9fb0d0;
            --input-bg: rgba(0, 0, 0, 0.4);
        }
        
        body {
            background-color: var(--bg-dark);
            background-image: url('assets/img/dowloag.png');
            background-size: cover; background-position: center; background-attachment: fixed;
            color: var(--text); font-family: "Segoe UI", sans-serif; overflow-x: hidden;
        }
        body::before {
            content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(10, 15, 25, 0.7); z-index: -1;
        }

        /* Topbar */
        .topbar { background: rgba(15, 23, 42, 0.9); padding: 0 40px; height: 64px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); backdrop-filter: blur(15px); position: sticky; top: 0; z-index: 1000; }
        .brand { font-size: 22px; font-weight: 700; color: var(--brand); display:flex; gap:10px; align-items:center; text-decoration: none; }
        .menu { display:flex; gap:20px; align-items:center; height: 100%; }
        .menu a.nav-link { color: var(--muted); text-decoration:none; display:flex; gap:8px; align-items:center; font-size:14px; transition:.2s; height: 100%; padding: 0 10px; }
        .menu a.nav-link:hover, .menu a.nav-link.active { color: var(--brand); }

        /* Dropdown */
        .dropdown { position: relative; display: flex; align-items: center; height: 100%; }
        .dropbtn { background: transparent; color: var(--muted); font-size: 14px; border: none; cursor: pointer; display: flex; align-items: center; gap: 8px; font-family: inherit; transition: .2s; padding: 0 10px; height: 100%; }
        .dropdown:hover .dropbtn { color: var(--brand); }
        .dropdown-content { display: none; position: absolute; background-color: #1e293b; min-width: 220px; box-shadow: 0px 10px 30px rgba(0,0,0,0.7); border: 1px solid var(--border); border-radius: 12px; z-index: 1000; top: 100%; right: 0; padding: 10px 0; }
        .dropdown-content a { color: var(--text); padding: 12px 20px; text-decoration: none; display: flex; align-items: center; gap: 10px; font-size: 14px; transition: all 0.2s; }
        .dropdown-content a:hover { background-color: rgba(74, 222, 128, 0.15); color: var(--brand); }
        .dropdown:hover .dropdown-content { display: block; }

        /* Content */
        .main { padding: 40px; min-height: calc(100vh - 64px); max-width: 1300px; margin: 0 auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-header h2 { font-size: 32px; font-weight: 700; margin: 0; text-shadow: 0 2px 10px rgba(0,0,0,0.5); }
        
        .custom-card { 
            background: linear-gradient(145deg, rgba(255,255,255,0.08) 0%, rgba(255,255,255,0.03) 100%);
            backdrop-filter: blur(20px); border: 1px solid var(--border);
            border-radius: 20px; padding: 25px; box-shadow: 0 10px 40px rgba(0,0,0,0.4); 
        }

        /* Table */
        .table { --bs-table-bg: transparent; --bs-table-color: var(--text); --bs-table-border-color: var(--border); margin-bottom: 0; }
        .table thead th { border-bottom: 1px solid var(--border); color: var(--brand); font-weight: 700; text-transform: uppercase; font-size: 0.8rem; background: rgba(0,0,0,0.2); letter-spacing: 1px; }
        .table tbody td { vertical-align: middle; border-bottom: 1px solid rgba(255,255,255,0.05); padding: 15px 12px; font-size: 0.95rem; }
        .table-hover tbody tr:hover { background-color: rgba(255,255,255,0.03); color: #fff; }

        /* Type Badges */
        .type-badge { display:inline-flex; align-items:center; gap:6px; padding: 4px 10px; border-radius: 6px; font-size: 0.8rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .type-medicine { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }
        .type-vaccine { background: rgba(59, 130, 246, 0.15); color: #60a5fa; border: 1px solid rgba(59, 130, 246, 0.3); }
        .type-service { background: rgba(168, 85, 247, 0.15); color: #c084fc; border: 1px solid rgba(168, 85, 247, 0.3); }
        .type-equipment { background: rgba(148, 163, 184, 0.15); color: #cbd5e1; border: 1px solid rgba(148, 163, 184, 0.3); }

        /* Buttons */
        .btn-primary { background-color: var(--brand); border: none; color: #000; font-weight: 700; padding: 10px 24px; border-radius: 50px; box-shadow: 0 0 15px rgba(74, 222, 128, 0.2); transition: 0.3s; }
        .btn-primary:hover { background-color: #22c55e; transform: translateY(-2px); box-shadow: 0 0 20px rgba(74, 222, 128, 0.4); }
        
        .action-btn { width: 34px; height: 34px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--border); background: transparent; color: var(--muted); transition: 0.2s; text-decoration: none; }
        .action-btn:hover { background: var(--brand); color: #000; border-color: var(--brand); transform: scale(1.1); }
        .action-btn.delete:hover { background: #ef4444; color: #fff; border-color: #ef4444; }

        /* Modal & Form */
        .modal-content { background-color: #111827; color: var(--text); border: 1px solid var(--border); border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.8); }
        .modal-header { border-bottom: 1px solid var(--border); padding: 20px 25px; }
        .modal-body { padding: 30px; }
        .modal-footer { border-top: 1px solid var(--border); padding: 20px 25px; }
        .btn-close { filter: invert(1); opacity: 0.7; }
        
        .form-control, .form-select { background-color: var(--input-bg) !important; border: 1px solid var(--border) !important; color: #fff !important; border-radius: 10px; padding: 12px; }
        .form-control:focus, .form-select:focus { border-color: var(--brand) !important; box-shadow: 0 0 0 2px rgba(74, 222, 128, 0.2); background-color: #000 !important; }
        label { color: var(--muted) !important; font-size: 0.85rem; font-weight: 600; text-transform: uppercase; margin-bottom: 6px; }

        @media (max-width: 768px) { .main { padding: 20px; } .topbar { padding: 0 20px; } }
    </style>
</head>
<body>

<header class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <nav class="menu">
        <a href="dashboard.php" class="nav-link"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php" class="nav-link"><i class="fa-solid fa-cow"></i> Animals</a>
        <a href="feeding.php" class="nav-link"><i class="fa-solid fa-bucket"></i> Feeding</a>
        <a href="weighing.php" class="nav-link"><i class="fa-solid fa-scale-balanced"></i> Weighing</a>
        <a href="reports.php" class="nav-link"><i class="fa-solid fa-chart-line"></i> Reports</a>
        
        <div class="dropdown">
            <button class="dropbtn">
                <i class="fa-solid fa-gear"></i> Admin <i class="fa-solid fa-caret-down" style="font-size:10px; margin-left:4px; opacity: 0.7;"></i>
            </button>
            <div class="dropdown-content">
                <a href="settings.php"><i class="fa-solid fa-building"></i> Company Settings</a>
                <a href="suppliers_list.php"><i class="fa-solid fa-truck-field"></i> Suppliers</a>
                <a href="medical_catalog.php"><i class="fa-solid fa-file-medical"></i> Medical Catalog</a>
                <a href="breeds.php"><i class="fa-solid fa-dna"></i> Animal Breeds</a>
                <a href="users.php"><i class="fa-solid fa-users-gear"></i> Users</a>
            </div>
        </div>
        <a href="dashboard.php?logout=true" class="nav-link" style="color:#f87171 !important" title="Exit"><i class="fa-solid fa-right-from-bracket"></i></a>
    </nav>
</header>

<main class="main">
    <div class="page-header">
        <div>
            <h2>Medical Catalog</h2>
            <p>Manage prices for medicines, vaccines, and services.</p>
        </div>
        <button class="btn btn-primary" onclick="openModal('new')">
            <i class="fa-solid fa-plus me-2"></i>Add Item
        </button>
    </div>

    <?php if ($msg): ?>
        <div class="alert alert-<?= $msg_type == 'success' ? 'success' : 'danger' ?> alert-dismissible fade show" role="alert" 
             style="background: rgba(0,0,0,0.6); border: 1px solid var(--border); color: #fff; border-left: 4px solid <?= $msg_type == 'success' ? '#4ade80' : '#ef4444' ?>;">
            <i class="fa-solid <?= $msg_type == 'success' ? 'fa-check-circle' : 'fa-triangle-exclamation' ?> me-2"></i> <?= $msg ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <?php endif; ?>

    <div class="custom-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-3">Item Name</th>
                        <th>Category</th>
                        <th>Stock / Unit</th>
                        <th>Supplier</th>
                        <th>Cost Price</th>
                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    if($items_list && $items_list->num_rows > 0) {
                        while($row = $items_list->fetch_assoc()): 
                            
                            $icon = 'fa-box'; 
                            $class = 'type-equipment';
                            switch($row['type']) {
                                case 'medicine': $icon = 'fa-pills'; $class='type-medicine'; break;
                                case 'vaccine': $icon = 'fa-syringe'; $class='type-vaccine'; break;
                                case 'service': $icon = 'fa-user-doctor'; $class='type-service'; break;
                            }
                    ?>
                    <tr>
                        <td class="ps-3">
                            <div class="fw-bold text-white"><?= htmlspecialchars($row['item_name']) ?></div>
                            <small class="text-muted"><?= htmlspecialchars(substr($row['description'], 0, 40)) ?>...</small>
                        </td>
                        <td>
                            <span class="type-badge <?= e($class) ?>">
                                <i class="fa-solid <?= $icon ?>"></i> <?= ucfirst($row['type']) ?>
                            </span>
                        </td>
                        <td>
                            <div class="fw-bold"><?= e($row['stock_quantity']) ?></div>
                            <small class="text-muted"><?= htmlspecialchars($row['unit']) ?></small>
                        </td>
                        <td>
                            <?= $row['supplier_name'] ? htmlspecialchars($row['supplier_name']) : '<span class="text-muted">-</span>' ?>
                        </td>
                        <td>
                            <span style="color:#4ade80; font-weight:700;">€ <?= number_format($row['cost_price'], 2) ?></span>
                        </td>
                        <td class="text-end pe-4">
                            <button class="action-btn me-2" onclick='openModal("edit", <?= e(json_encode($row)) ?>)' title="Edit">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <a href="?delete=<?= e($row['item_id']) ?>" class="action-btn delete" onclick="return confirm('Delete this item?');" title="Delete">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endwhile; 
                    } else {
                        echo "<tr><td colspan='6' class='text-center py-5 text-muted'>No items in catalog.</td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<div class="modal fade" id="itemModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-white" id="modalTitle">Add Catalog Item</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_item">
                    <input type="hidden" name="item_id" id="item_id">

                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label">Item Name / Service *</label>
                            <input type="text" name="item_name" id="item_name" class="form-control" required placeholder="e.g. Oxytetracycline 20%">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Type *</label>
                            <select name="type" id="type" class="form-select" required>
                                <option value="medicine">Medicine</option>
                                <option value="vaccine">Vaccine</option>
                                <option value="service">Service (Vet)</option>
                                <option value="equipment">Equipment</option>
                            </select>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Supplier</label>
                            <select name="supplier_id" id="supplier_id" class="form-select">
                                <option value="">-- Select Supplier --</option>
                                <?php 
                                if($suppliers) {
                                    $suppliers->data_seek(0);
                                    while($s = $suppliers->fetch_assoc()): ?>
                                        <option value="<?= e($s['supplier_id']) ?>"><?= htmlspecialchars($s['name']) ?></option>
                                    <?php endwhile; 
                                }?>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Unit</label>
                            <input type="text" name="unit" id="unit" class="form-control" placeholder="ml, dose, unit">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Stock Qty</label>
                            <input type="number" name="stock_quantity" id="stock_quantity" class="form-control" value="0">
                        </div>

                        <div class="col-md-12">
                            <label class="form-label" style="color:#4ade80 !important;">Cost Price (€) *</label>
                            <input type="number" step="0.01" name="cost_price" id="cost_price" class="form-control" required placeholder="0.00">
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Description / Instructions</label>
                            <textarea name="description" id="description" class="form-control" rows="3"></textarea>
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.1); color:#fff;" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Item</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var itemModalObj;
    document.addEventListener('DOMContentLoaded', function() {
        var modalEl = document.getElementById('itemModal');
        itemModalObj = new bootstrap.Modal(modalEl);
    });

    function openModal(mode, data = null) {
        document.querySelector('form').reset();
        
        if (mode === 'new') {
            document.getElementById('modalTitle').innerText = 'Add Catalog Item';
            document.getElementById('item_id').value = '';
        } else if (mode === 'edit' && data) {
            document.getElementById('modalTitle').innerText = 'Edit Item';
            document.getElementById('item_id').value = data.item_id;
            document.getElementById('item_name').value = data.item_name;
            document.getElementById('type').value = data.type;
            document.getElementById('supplier_id').value = data.supplier_id || '';
            document.getElementById('unit').value = data.unit;
            document.getElementById('stock_quantity').value = data.stock_quantity;
            document.getElementById('cost_price').value = data.cost_price;
            document.getElementById('description').value = data.description;
        }
        itemModalObj.show();
    }
</script>

</body>
</html>