<?php
/* =========================================================
   settings.php — Company Settings
   Style: Premium Glass (Matched with Animal/Dashboard)
   Features: CRUD Company, Logo Upload, Validation
   ========================================================= */
require_once 'config.php';

// Verificações de Segurança
if (!isset($conn)) { die("Erro: Conexão com banco não encontrada."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// --- 1. DELETAR EMPRESA ---
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    $stmt = $conn->prepare("DELETE FROM company WHERE company_id = ?");
    $stmt->bind_param("i", $id);
    if ($stmt->execute()) {
        $msg = "Company deleted successfully!"; $msg_type = "success";
    } else {
        $msg = "Error deleting: " . $conn->error; $msg_type = "danger";
    }
    $stmt->close();
}

// --- 2. SALVAR/ATUALIZAR EMPRESA ---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_company') {
    $company_id = $_POST['company_id'];
    
    // Sanitização e Trim
    $name       = trim($_POST['name']);
    $legal_name = trim($_POST['legal_name']);
    $tax_id     = trim($_POST['tax_id']);
    $owner_name = trim($_POST['owner_name']);
    $address    = trim($_POST['address']);
    $phone      = trim($_POST['phone']);
    $email      = trim($_POST['email']);
    
    // Validação PHP (Back-end)
    if (empty($name) || empty($legal_name) || empty($tax_id) || empty($owner_name) || empty($address) || empty($phone) || empty($email)) {
        $msg = "Error: There are fields that must be filled.";
        $msg_type = "danger";
    } else {
        // Upload de Logo
        $logo_path = $_POST['existing_logo']; 
        if (isset($_FILES['logo']) && $_FILES['logo']['error'] == 0) {
            $saved = safe_upload($_FILES['logo'], 'logos', ['jpg', 'png', 'webp', 'gif'], 2 * 1024 * 1024);
            if ($saved) { $logo_path = $saved; }
        }

        if (!empty($company_id)) {
            // UPDATE
            $stmt = $conn->prepare("UPDATE company SET name=?, legal_name=?, owner_name=?, address=?, phone=?, email=?, tax_id=?, logo_path=? WHERE company_id=?");
            $stmt->bind_param("ssssssssi", $name, $legal_name, $owner_name, $address, $phone, $email, $tax_id, $logo_path, $company_id);
        } else {
            // INSERT
            $stmt = $conn->prepare("INSERT INTO company (name, legal_name, owner_name, address, phone, email, tax_id, logo_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("ssssssss", $name, $legal_name, $owner_name, $address, $phone, $email, $tax_id, $logo_path);
        }

        if ($stmt->execute()) {
            $msg = "Company settings saved successfully!"; $msg_type = "success";
        } else {
            $msg = "Database Error: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Company Settings | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    
    <style>
        /* --- PREMIUM GLASS THEME (Matched with Animal.php) --- */
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
        
        /* Dark Overlay */
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

        /* Main Content */
        .main { padding: 40px; min-height: calc(100vh - 64px); max-width: 1300px; margin: 0 auto; }
        
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-header h2 { font-size: 32px; font-weight: 700; margin: 0; text-shadow: 0 2px 10px rgba(0,0,0,0.5); }
        .page-header p { color: var(--muted); margin: 0; }

        /* Glass Card */
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
        
        .company-logo-thumb { width: 50px; height: 50px; object-fit: contain; border-radius: 8px; border: 1px solid var(--border); background: rgba(255,255,255,0.1); padding: 2px; }

        /* Buttons */
        .btn-primary { background-color: var(--brand); border: none; color: #000; font-weight: 700; padding: 10px 24px; border-radius: 50px; box-shadow: 0 0 15px rgba(74, 222, 128, 0.2); transition: 0.3s; }
        .btn-primary:hover { background-color: #22c55e; transform: translateY(-2px); box-shadow: 0 0 20px rgba(74, 222, 128, 0.4); }
        
        .action-btn { width: 34px; height: 34px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--border); background: transparent; color: var(--muted); transition: 0.2s; text-decoration: none; }
        .action-btn:hover { background: var(--brand); color: #000; border-color: var(--brand); transform: scale(1.1); }
        .action-btn.delete:hover { background: #ef4444; color: #fff; border-color: #ef4444; }

        /* Modals (Glass/Dark) */
        .modal-content { background-color: #111827; color: var(--text); border: 1px solid var(--border); border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.8); }
        .modal-header { border-bottom: 1px solid var(--border); padding: 20px 25px; }
        .modal-body { padding: 30px; }
        .modal-footer { border-top: 1px solid var(--border); padding: 20px 25px; }
        .btn-close { filter: invert(1); opacity: 0.7; }
        
        /* Inputs */
        .form-control { 
            background-color: var(--input-bg) !important; 
            border: 1px solid var(--border) !important; 
            color: #fff !important; 
            border-radius: 10px; padding: 12px;
        }
        .form-control:focus { 
            border-color: var(--brand) !important; box-shadow: 0 0 0 2px rgba(74, 222, 128, 0.2); background-color: #000 !important;
        }
        .form-control::placeholder { color: rgba(255,255,255,0.3); }
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
            <h2>Company Settings</h2>
            <p>Manage farm details and logos.</p>
        </div>
        <button class="btn btn-primary" onclick="openModal('new')">
            <i class="fa-solid fa-plus me-2"></i>New Company
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
                        <th class="ps-3" width="80">Logo</th>
                        <th>Company Name</th>
                        <th>Owner</th>
                        <th>Tax ID</th>
                        <th>Contact</th>
                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $result = $conn->query("SELECT * FROM company ORDER BY company_id DESC");
                    
                    if ($result && $result->num_rows > 0):
                        while($row = $result->fetch_assoc()):
                    ?>
                    <tr>
                        <td class="ps-3">
                            <?php if(!empty($row['logo_path']) && file_exists($row['logo_path'])): ?>
                                <img src="<?= htmlspecialchars($row['logo_path']) ?>" class="company-logo-thumb">
                            <?php else: ?>
                                <div class="company-logo-thumb d-flex align-items-center justify-content-center text-muted">
                                    <i class="fa-solid fa-image"></i>
                                </div>
                            <?php endif; ?>
                        </td>
                        <td>
                            <div class="fw-bold text-white"><?= htmlspecialchars($row['name']) ?></div>
                            <small class="text-muted"><?= htmlspecialchars($row['address']) ?></small>
                        </td>
                        <td><?= htmlspecialchars($row['owner_name']) ?></td>
                        <td><span class="badge bg-dark border border-secondary text-light"><?= htmlspecialchars($row['tax_id'] ?? 'N/A') ?></span></td>
                        <td>
                            <div style="font-size: 0.85rem; color:var(--muted)">
                                <i class="fa-solid fa-phone me-1 text-success"></i> <?= htmlspecialchars($row['phone']) ?><br>
                                <i class="fa-solid fa-envelope me-1 text-primary"></i> <?= htmlspecialchars($row['email']) ?>
                            </div>
                        </td>
                        <td class="text-end pe-4">
                            <button class="action-btn me-2" onclick='openModal("edit", <?= e(json_encode($row)) ?>)' title="Edit">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <a href="?delete=<?= e($row['company_id']) ?>" class="action-btn delete" onclick="return confirm('Delete this company?');" title="Delete">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endwhile; 
                    else: ?>
                    <tr>
                        <td colspan="6" class="text-center py-5 text-muted">
                            <i class="fa-solid fa-folder-open fa-2x mb-3 opacity-50"></i><br>
                            No companies registered yet.
                        </td>
                    </tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<div class="modal fade" id="companyModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form method="POST" enctype="multipart/form-data">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-white" id="modalTitle">Company Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_company">
                    <input type="hidden" name="company_id" id="company_id">
                    <input type="hidden" name="existing_logo" id="existing_logo">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Company Name *</label>
                            <input type="text" name="name" id="name" class="form-control" required placeholder="Ex: Green Valley Farms">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Legal Name *</label>
                            <input type="text" name="legal_name" id="legal_name" class="form-control" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Owner Name *</label>
                            <input type="text" name="owner_name" id="owner_name" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Tax ID / CNPJ *</label>
                            <input type="text" name="tax_id" id="tax_id" class="form-control" required>
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Phone *</label>
                            <input type="text" name="phone" id="phone" class="form-control" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email *</label>
                            <input type="email" name="email" id="email" class="form-control" required>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Address *</label>
                            <input type="text" name="address" id="address" class="form-control" required>
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Logo Image</label>
                            <input type="file" name="logo" class="form-control" accept="image/*">
                            <small class="text-muted">Allowed: JPG, PNG. Leave empty to keep current.</small>
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.1); color:#fff;" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var companyModalObj;
    document.addEventListener('DOMContentLoaded', function() {
        var modalEl = document.getElementById('companyModal');
        companyModalObj = new bootstrap.Modal(modalEl);
    });

    function openModal(mode, data = null) {
        document.querySelector('form').reset();
        
        if (mode === 'new') {
            document.getElementById('modalTitle').innerText = 'Register New Company';
            document.getElementById('company_id').value = '';
            document.getElementById('existing_logo').value = '';
        } else if (mode === 'edit' && data) {
            document.getElementById('modalTitle').innerText = 'Edit Company';
            document.getElementById('company_id').value = data.company_id;
            document.getElementById('name').value = data.name;
            document.getElementById('legal_name').value = data.legal_name || '';
            document.getElementById('owner_name').value = data.owner_name;
            document.getElementById('tax_id').value = data.tax_id || '';
            document.getElementById('phone').value = data.phone;
            document.getElementById('email').value = data.email;
            document.getElementById('address').value = data.address;
            document.getElementById('existing_logo').value = data.logo_path;
        }
        companyModalObj.show();
    }
</script>

</body>
</html>