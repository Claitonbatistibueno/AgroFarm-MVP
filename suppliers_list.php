<?php
/* =========================================================
   suppliers_list.php — Supplier Management
   Style: Premium Glass
   Features: CRUD, Type Icons, Mandatory Field Validation
   ========================================================= */
require_once 'config.php';

// Segurança
if (!isset($conn)) { die("Database connection error."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// --- 1. DELETAR FORNECEDOR ---
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    
    // Verifica se o fornecedor está sendo usado em outras tabelas (Integridade)
    $checkFeed = $conn->query("SELECT COUNT(*) as c FROM feed WHERE supplier_id = $id")->fetch_assoc();
    $checkMed  = $conn->query("SELECT COUNT(*) as c FROM medical_catalog WHERE supplier_id = $id")->fetch_assoc();
    
    if ($checkFeed['c'] > 0 || $checkMed['c'] > 0) {
        $msg = "Cannot delete: This supplier is linked to registered Feeds or Medicines.";
        $msg_type = "danger";
    } else {
        $stmt = $conn->prepare("DELETE FROM suppliers WHERE supplier_id = ?");
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            $msg = "Supplier deleted successfully!"; $msg_type = "success";
        } else {
            $msg = "Error deleting: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}

// --- 2. SALVAR/ATUALIZAR FORNECEDOR ---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_supplier') {
    $supplier_id = $_POST['supplier_id'];
    
    // Dados
    $name    = trim($_POST['name']);
    $contact = trim($_POST['contact_person']);
    $type    = $_POST['supplier_type'];
    $status  = $_POST['status'];
    $phone   = trim($_POST['phone']);
    $email   = trim($_POST['email']);
    $address = trim($_POST['address']);

    // VALIDAÇÃO: Campos Obrigatórios (Nome e Tipo)
    if (empty($name) || empty($type)) {
        $msg = "Error: Company Name and Supplier Type are required fields.";
        $msg_type = "danger";
    } else {
        
        if (!empty($supplier_id)) {
            // UPDATE
            $stmt = $conn->prepare("UPDATE suppliers SET name=?, contact_person=?, supplier_type=?, status=?, phone=?, email=?, address=? WHERE supplier_id=?");
            $stmt->bind_param("sssssssi", $name, $contact, $type, $status, $phone, $email, $address, $supplier_id);
        } else {
            // INSERT
            $stmt = $conn->prepare("INSERT INTO suppliers (name, contact_person, supplier_type, status, phone, email, address) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("sssssss", $name, $contact, $type, $status, $phone, $email, $address);
        }

        if ($stmt->execute()) {
            $msg = "Supplier record saved successfully!"; $msg_type = "success";
        } else {
            $msg = "Database Error: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}

// --- BUSCAR DADOS ---
$suppliers_list = $conn->query("SELECT * FROM suppliers ORDER BY status ASC, name ASC");
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Suppliers | Farm Project</title>
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
        .type-feed { background: rgba(234, 179, 8, 0.15); color: #facc15; border: 1px solid rgba(234, 179, 8, 0.3); }
        .type-medicine { background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.3); }
        .type-animals { background: rgba(59, 130, 246, 0.15); color: #60a5fa; border: 1px solid rgba(59, 130, 246, 0.3); }
        .type-other { background: rgba(148, 163, 184, 0.15); color: #cbd5e1; border: 1px solid rgba(148, 163, 184, 0.3); }

        .status-dot { height: 8px; width: 8px; border-radius: 50%; display: inline-block; margin-right: 6px; }
        .status-active { background-color: #4ade80; box-shadow: 0 0 5px #4ade80; }
        .status-inactive { background-color: #94a3b8; }

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
            <h2>Suppliers List</h2>
            <p>Manage external partners for feed, medicine and animals.</p>
        </div>
        <button class="btn btn-primary" onclick="openModal('new')">
            <i class="fa-solid fa-plus me-2"></i>Add Supplier
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
                        <th class="ps-3">Company Name</th>
                        <th>Type</th>
                        <th>Contact Person</th>
                        <th>Contact Info</th>
                        <th>Status</th>
                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    if($suppliers_list && $suppliers_list->num_rows > 0) {
                        while($row = $suppliers_list->fetch_assoc()): 
                            
                            // Visual Logic for Type
                            $icon = 'fa-box'; 
                            $class = 'type-other';
                            switch($row['supplier_type']) {
                                case 'feed': $icon = 'fa-wheat'; $class='type-feed'; break;
                                case 'medicine': $icon = 'fa-pills'; $class='type-medicine'; break;
                                case 'animals': $icon = 'fa-cow'; $class='type-animals'; break;
                            }
                    ?>
                    <tr>
                        <td class="ps-3">
                            <div class="fw-bold text-white"><?= htmlspecialchars($row['name']) ?></div>
                            <small class="text-muted"><?= htmlspecialchars($row['address']) ?></small>
                        </td>
                        <td>
                            <span class="type-badge <?= e($class) ?>">
                                <i class="fa-solid <?= $icon ?>"></i> <?= ucfirst($row['supplier_type']) ?>
                            </span>
                        </td>
                        <td>
                            <?= $row['contact_person'] ? htmlspecialchars($row['contact_person']) : '<span class="text-muted">-</span>' ?>
                        </td>
                        <td>
                            <div style="font-size: 0.85rem; color:var(--muted)">
                                <?php if($row['email']): ?><i class="fa-solid fa-envelope me-1"></i> <?= htmlspecialchars($row['email']) ?><br><?php endif; ?>
                                <?php if($row['phone']): ?><i class="fa-solid fa-phone me-1"></i> <?= htmlspecialchars($row['phone']) ?><?php endif; ?>
                            </div>
                        </td>
                        <td>
                            <?php if($row['status'] == 'active'): ?>
                                <span style="color:#4ade80; font-size:0.9rem;"><span class="status-dot status-active"></span>Active</span>
                            <?php else: ?>
                                <span style="color:#94a3b8; font-size:0.9rem;"><span class="status-dot status-inactive"></span>Inactive</span>
                            <?php endif; ?>
                        </td>
                        <td class="text-end pe-4">
                            <button class="action-btn me-2" onclick='openModal("edit", <?= e(json_encode($row)) ?>)' title="Edit">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <a href="?delete=<?= e($row['supplier_id']) ?>" class="action-btn delete" onclick="return confirm('Delete this supplier?');" title="Delete">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endwhile; 
                    } else {
                        echo "<tr><td colspan='6' class='text-center py-5 text-muted'>No suppliers found.</td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<div class="modal fade" id="supplierModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-white" id="modalTitle">Add Supplier</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_supplier">
                    <input type="hidden" name="supplier_id" id="supplier_id">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Company Name *</label>
                            <input type="text" name="name" id="name" class="form-control" required placeholder="Supplier Name">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Contact Person</label>
                            <input type="text" name="contact_person" id="contact_person" class="form-control" placeholder="Sales Representative">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Supplier Type *</label>
                            <select name="supplier_type" id="supplier_type" class="form-select" required>
                                <option value="" disabled selected>Select Type...</option>
                                <option value="feed">Feed / Nutrition</option>
                                <option value="medicine">Medicine / Veterinary</option>
                                <option value="animals">Livestock (Buying)</option>
                                <option value="other">Other / Equipment</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Status</label>
                            <select name="status" id="status" class="form-select">
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                            <div class="form-text text-muted" style="font-size:11px;">Inactive suppliers won't appear in new purchase lists.</div>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Phone</label>
                            <input type="text" name="phone" id="phone" class="form-control" placeholder="+1 234 567 890">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" id="email" class="form-control" placeholder="contact@supplier.com">
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Address</label>
                            <input type="text" name="address" id="address" class="form-control" placeholder="Full Address">
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.1); color:#fff;" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Supplier</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var supplierModalObj;
    document.addEventListener('DOMContentLoaded', function() {
        var modalEl = document.getElementById('supplierModal');
        supplierModalObj = new bootstrap.Modal(modalEl);
    });

    function openModal(mode, data = null) {
        document.querySelector('form').reset();
        
        if (mode === 'new') {
            document.getElementById('modalTitle').innerText = 'Add Supplier';
            document.getElementById('supplier_id').value = '';
            document.getElementById('status').value = 'active';
        } else if (mode === 'edit' && data) {
            document.getElementById('modalTitle').innerText = 'Edit Supplier';
            document.getElementById('supplier_id').value = data.supplier_id;
            document.getElementById('name').value = data.name;
            document.getElementById('contact_person').value = data.contact_person || '';
            document.getElementById('supplier_type').value = data.supplier_type;
            document.getElementById('status').value = data.status;
            document.getElementById('phone').value = data.phone || '';
            document.getElementById('email').value = data.email || '';
            document.getElementById('address').value = data.address || '';
        }
        supplierModalObj.show();
    }
</script>

</body>
</html>