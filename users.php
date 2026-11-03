<?php
/* =========================================================
   users.php — User Management
   Style: Premium Glass
   Features: Company Association, Full Validation, Friendly Errors
   ========================================================= */
require_once 'config.php';

// Segurança
if (!isset($conn)) { die("Database connection error."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// --- 1. DELETAR USUÁRIO ---
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    // Evita que o usuário delete a si mesmo
    if ($id == $_SESSION['user_id']) {
        $msg = "Error: You cannot delete your own account.";
        $msg_type = "danger";
    } else {
        $stmt = $conn->prepare("DELETE FROM users WHERE user_id = ?");
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            $msg = "User deleted successfully!"; $msg_type = "success";
        } else {
            $msg = "Error: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}

// --- 2. SALVAR/ATUALIZAR USUÁRIO ---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_user') {
    $user_id = $_POST['user_id']; 
    
    // Dados
    $full_name  = trim($_POST['full_name']);
    $username   = trim($_POST['username']);
    $email      = trim($_POST['email']);
    $phone      = trim($_POST['phone']);
    $company_id = $_POST['company_id'];
    $login_code = trim($_POST['login_code']);
    $password   = $_POST['password'] ?? '';
    if ($password !== '' && strlen($password) < 8) {
        $msg = "Error: Password must have at least 8 characters.";
        $msg_type = "danger";
        $password_invalid = true;
    }
    $password_hash = $password !== '' ? password_hash($password, PASSWORD_DEFAULT) : '';

    // Validação
    if (!empty($password_invalid)) {
        // message already set above
    } elseif (empty($full_name) || empty($username) || empty($company_id) || empty($login_code)) {
        $msg = "Error: Name, Username, Company and Login Code are required.";
        $msg_type = "danger";
    } elseif (empty($user_id) && empty($password)) {
        $msg = "Error: Password is required for new users.";
        $msg_type = "danger";
    } else {
        
        // INSERT
        if (empty($user_id)) {
            $sql = "INSERT INTO users (full_name, username, email, phone, company_id, login_code, password) VALUES (?, ?, ?, ?, ?, ?, ?)";
            $stmt = $conn->prepare($sql);
            $stmt->bind_param("ssssiss", $full_name, $username, $email, $phone, $company_id, $login_code, $password_hash);
        } 
        // UPDATE
        else {
            if (!empty($password)) {
                $sql = "UPDATE users SET full_name=?, username=?, email=?, phone=?, company_id=?, login_code=?, password=? WHERE user_id=?";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("ssssissi", $full_name, $username, $email, $phone, $company_id, $login_code, $password_hash, $user_id);
            } else {
                $sql = "UPDATE users SET full_name=?, username=?, email=?, phone=?, company_id=?, login_code=? WHERE user_id=?";
                $stmt = $conn->prepare($sql);
                $stmt->bind_param("ssssisi", $full_name, $username, $email, $phone, $company_id, $login_code, $user_id);
            }
        }

        // --- EXECUÇÃO COM TRATAMENTO DE ERRO AMIGÁVEL ---
        if ($stmt->execute()) {
            $msg = "User saved successfully!"; 
            $msg_type = "success";
        } else {
            // Código 1062 = Duplicate Entry (Entrada Duplicada)
            if ($conn->errno == 1062) {
                $msg = "Error: A user is already registered with this Username.";
                $msg_type = "danger";
            } else {
                $msg = "Database Error: " . $conn->error;
                $msg_type = "danger";
            }
        }
        $stmt->close();
    }
}

// --- BUSCAR DADOS ---
$companies = $conn->query("SELECT company_id, name FROM company ORDER BY name");
$sql_users = "SELECT u.user_id, u.company_id, u.username, u.full_name, u.email, u.phone, u.login_code, c.name as company_name 
              FROM users u 
              LEFT JOIN company c ON u.company_id = c.company_id 
              ORDER BY u.user_id DESC";
$users_list = $conn->query($sql_users);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Users Management | Farm Project</title>
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

        /* ID Badge */
        .id-badge { font-family: monospace; font-size: 0.9rem; background: rgba(0,0,0,0.4); color: #94a3b8; padding: 4px 8px; border-radius: 6px; border: 1px solid var(--border); }

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
            <h2>User Management</h2>
            <p>Manage access, passwords and company association.</p>
        </div>
        <button class="btn btn-primary" onclick="openModal('new')">
            <i class="fa-solid fa-user-plus me-2"></i>Add New User
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
                        <th class="ps-3">ID</th>
                        <th>User Info</th>
                        <th>Company</th>
                        <th>Contact</th>
                        <th>Login Code</th>
                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php 
                    if($users_list && $users_list->num_rows > 0) {
                        while($row = $users_list->fetch_assoc()): 
                    ?>
                    <tr>
                        <td class="ps-3"><span class="id-badge">#<?= str_pad($row['user_id'], 3, '0', STR_PAD_LEFT) ?></span></td>
                        <td>
                            <div class="fw-bold text-white"><?= htmlspecialchars($row['full_name']) ?></div>
                            <small class="text-muted"><i class="fa-solid fa-user me-1"></i> <?= htmlspecialchars($row['username']) ?></small>
                        </td>
                        <td>
                            <?php if($row['company_name']): ?>
                                <span style="color:#4ade80"><i class="fa-solid fa-building me-1"></i> <?= htmlspecialchars($row['company_name']) ?></span>
                            <?php else: ?>
                                <span class="text-muted text-opacity-50">- No Company -</span>
                            <?php endif; ?>
                        </td>
                        <td>
                            <div style="font-size: 0.85rem; color:var(--muted)">
                                <?php if($row['email']): ?><i class="fa-solid fa-envelope me-1"></i> <?= htmlspecialchars($row['email']) ?><br><?php endif; ?>
                                <?php if($row['phone']): ?><i class="fa-solid fa-phone me-1"></i> <?= htmlspecialchars($row['phone']) ?><?php endif; ?>
                            </div>
                        </td>
                        <td>
                            <span style="font-family:monospace; color:#facc15; border:1px solid #facc15; padding:2px 6px; border-radius:4px;">
                                <?= htmlspecialchars($row['login_code']) ?>
                            </span>
                        </td>
                        <td class="text-end pe-4">
                            <button class="action-btn me-2" onclick='openModal("edit", <?= e(json_encode($row)) ?>)' title="Edit">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <a href="?delete=<?= e($row['user_id']) ?>" class="action-btn delete" onclick="return confirm('Delete this user?');" title="Delete">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endwhile; 
                    } else {
                        echo "<tr><td colspan='6' class='text-center py-5 text-muted'>No users found.</td></tr>";
                    }
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<div class="modal fade" id="userModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-white" id="modalTitle">Add New User</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_user">
                    <input type="hidden" name="user_id" id="user_id">

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Full Name *</label>
                            <input type="text" name="full_name" id="full_name" class="form-control" required placeholder="John Doe">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Username *</label>
                            <input type="text" name="username" id="username" class="form-control" required placeholder="johndoe">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Company Association *</label>
                            <select name="company_id" id="company_id" class="form-select" required>
                                <option value="">Select Company...</option>
                                <?php 
                                if($companies) {
                                    $companies->data_seek(0);
                                    while($c = $companies->fetch_assoc()): ?>
                                        <option value="<?= e($c['company_id']) ?>"><?= htmlspecialchars($c['name']) ?></option>
                                    <?php endwhile; 
                                }?>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Login Code (PIN) *</label>
                            <input type="text" name="login_code" id="login_code" class="form-control" required placeholder="e.g. 123456">
                        </div>

                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" name="email" id="email" class="form-control" placeholder="user@farm.com">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Phone</label>
                            <input type="text" name="phone" id="phone" class="form-control" placeholder="+1 234 567 890">
                        </div>

                        <div class="col-md-12">
                            <label class="form-label">Password <span id="pwd-required">*</span></label>
                            <input type="password" name="password" id="password" class="form-control" placeholder="Enter password">
                            <small class="text-muted" id="pwd-hint" style="display:none;">Leave blank to keep current password.</small>
                        </div>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.1); color:#fff;" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save User</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var userModalObj;
    document.addEventListener('DOMContentLoaded', function() {
        var modalEl = document.getElementById('userModal');
        userModalObj = new bootstrap.Modal(modalEl);
    });

    function openModal(mode, data = null) {
        document.querySelector('form').reset();
        var pwdReq = document.getElementById('pwd-required');
        var pwdHint = document.getElementById('pwd-hint');
        var pwdInput = document.getElementById('password');
        
        if (mode === 'new') {
            document.getElementById('modalTitle').innerText = 'Add New User';
            document.getElementById('user_id').value = '';
            
            // Senha obrigatória para novo usuário
            pwdReq.style.display = 'inline';
            pwdHint.style.display = 'none';
            pwdInput.required = true;
        } else if (mode === 'edit' && data) {
            document.getElementById('modalTitle').innerText = 'Edit User';
            document.getElementById('user_id').value = data.user_id;
            document.getElementById('full_name').value = data.full_name;
            document.getElementById('username').value = data.username;
            document.getElementById('company_id').value = data.company_id;
            document.getElementById('login_code').value = data.login_code;
            document.getElementById('email').value = data.email || '';
            document.getElementById('phone').value = data.phone || '';
            
            // Senha opcional na edição
            pwdReq.style.display = 'none';
            pwdHint.style.display = 'block';
            pwdInput.required = false;
        }
        userModalObj.show();
    }
</script>

</body>
</html>