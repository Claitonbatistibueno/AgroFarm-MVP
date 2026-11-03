<?php
/* =========================================================
   clients.php — Client Management
   Style: EXACT DASHBOARD REPLICA (Fixed Edit Button)
   ========================================================= */

require_once 'config.php';
require_login();

$msg = '';

// --- 2. CRUD ACTIONS ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    try {
        if (!empty($_POST['client_id'])) {
            // EDITAR
            $stmt = $pdo->prepare("UPDATE clients SET company_id=?, name=?, phone=?, email=?, address=? WHERE client_id=?");
            $stmt->execute([$_POST['company_id'], $_POST['name'], $_POST['phone'], $_POST['email'], $_POST['address'], $_POST['client_id']]);
            header("Location: clients.php?msg=updated"); exit;
        } else {
            // NOVO
            $stmt = $pdo->prepare("INSERT INTO clients (company_id, name, phone, email, address) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([$_POST['company_id'], $_POST['name'], $_POST['phone'], $_POST['email'], $_POST['address']]);
            header("Location: clients.php?msg=added"); exit;
        }
    } catch (Exception $e) { $msg = "Error: " . $e->getMessage(); }
}

if (isset($_GET['delete'])) {
    $stmt = $pdo->prepare("DELETE FROM clients WHERE client_id = ?");
    $stmt->execute([$_GET['delete']]);
    header("Location: clients.php?msg=deleted"); exit;
}

if (isset($_GET['msg'])) {
    if ($_GET['msg'] == 'added') $msg = "Client added successfully!";
    if ($_GET['msg'] == 'updated') $msg = "Client updated successfully!";
    if ($_GET['msg'] == 'deleted') $msg = "Client deleted successfully!";
}

$companies = $pdo->query("SELECT company_id, name FROM company ORDER BY name ASC")->fetchAll();
$clients = $pdo->query("SELECT c.*, comp.name as company_name FROM clients c LEFT JOIN company comp ON c.company_id = comp.company_id ORDER BY c.name ASC")->fetchAll();
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Farm Project | Clients</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
<style>
    /* --- STYLE IDENTICAL TO DASHBOARD.PHP --- */
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
    * { box-sizing: border-box; }

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

    .page-header { margin-bottom: 30px; display: flex; justify-content: space-between; align-items: center; }
    .page-header h1 { font-size: 32px; font-weight: 700; margin: 0; text-shadow: 0 4px 20px rgba(0,0,0,0.5); }
    
    .content-grid {
        display: grid;
        grid-template-columns: 350px 1fr;
        gap: 24px;
    }

    .glass-card {
        background: linear-gradient(145deg, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0.05) 100%);
        backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
        border: 1px solid rgba(255,255,255,0.15);
        border-radius: 24px; padding: 30px;
        color: white; box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
        height: fit-content;
    }

    /* Form Elements */
    .form-group { margin-bottom: 15px; }
    .form-label { display: block; font-size: 13px; color: #94a3b8; margin-bottom: 5px; font-weight: 500; }
    
    .form-input, .form-select {
        width: 100%; padding: 12px 15px;
        background: rgba(15, 23, 42, 0.6);
        border: 1px solid rgba(255,255,255,0.1);
        border-radius: 12px; color: #fff; font-family: inherit; font-size: 14px;
        outline: none; transition: 0.3s;
    }
    .form-input:focus, .form-select:focus {
        border-color: #4ade80; box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.1);
        background: rgba(15, 23, 42, 0.8);
    }

    .btn {
        cursor: pointer; padding: 12px 24px; border-radius: 12px; font-weight: 600; font-size: 14px;
        border: none; transition: 0.3s; width: 100%; display: inline-flex; align-items: center; justify-content: center; gap: 8px;
    }
    .btn-primary { background: #4ade80; color: #0f172a; }
    .btn-primary:hover { background: #22c55e; transform: translateY(-2px); }
    
    .btn-text { background: transparent; color: #94a3b8; margin-top: 10px; }
    .btn-text:hover { color: #fff; }

    /* Table */
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { text-align: left; color: #4ade80; font-size: 13px; text-transform: uppercase; padding: 15px; border-bottom: 2px solid rgba(255,255,255,0.1); }
    td { padding: 15px; border-bottom: 1px solid rgba(255,255,255,0.05); vertical-align: middle; font-size: 14px; color: #cbd5e1; }
    tr:last-child td { border-bottom: none; }
    tr:hover td { background: rgba(255,255,255,0.02); color: #fff; }

    .badge {
        padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; text-transform: uppercase;
        background: rgba(74, 222, 128, 0.1); color: #4ade80; border: 1px solid rgba(74, 222, 128, 0.2);
    }
    
    .btn-icon {
        width: 32px; height: 32px; border-radius: 8px; display: inline-flex; align-items: center; justify-content: center;
        background: rgba(255,255,255,0.05); color: #fff; text-decoration: none; border: 1px solid rgba(255,255,255,0.1); transition: 0.2s; cursor: pointer;
    }
    .btn-icon:hover { background: #4ade80; color: #0f172a; }
    .btn-icon.del:hover { background: #ef4444; color: #fff; }

    .msg-box { padding: 10px 20px; border-radius: 12px; background: rgba(74, 222, 128, 0.2); color: #4ade80; font-weight: 500; border: 1px solid rgba(74, 222, 128, 0.3); }

    /* Dropdown */
    .dropdown { position: relative; }
    .drop-menu { display: none; position: absolute; top: 100%; right: 0; background: #1e293b; border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; width: 220px; box-shadow: 0 10px 40px rgba(0,0,0,0.5); padding: 8px 0; z-index: 1000; }
    .dropdown:hover .drop-menu { display: block; }
    .drop-menu a { padding: 12px 20px; display: block; color: #cbd5e1; text-decoration: none; font-size: 14px; border-bottom: 1px solid rgba(255,255,255,0.02); }
    .drop-menu a:hover { background: rgba(74, 222, 128, 0.1); color: #4ade80; }

    @media (max-width: 768px) {
        .content-grid { grid-template-columns: 1fr; }
        .topbar { padding: 0 20px; }
    }
</style>
</head>
<body>

<div class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    <div class="nav">
        <a href="dashboard.php"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php"><i class="fa-solid fa-cow"></i> Animals</a>
        
        <div class="dropdown">
            <a href="#" class="active"><i class="fa-solid fa-gear"></i> Admin <i class="fa-solid fa-caret-down" style="font-size:10px; margin-left:3px;"></i></a>
            <div class="drop-menu">
                <a href="settings.php">Company Settings</a>
                <a href="clients.php" style="color:#4ade80"> Clients Management</a>
                <a href="users.php">User Management</a>
            </div>
        </div>
        
        <a href="dashboard.php?logout=true" style="color:#f87171" title="Logout"><i class="fa-solid fa-right-from-bracket"></i></a>
    </div>
</div>

<main class="main">
    <div class="page-header">
        <h1>Client Management</h1>
        <?php if($msg): ?>
            <div class="msg-box"><i class="fa-solid fa-check me-2"></i> <?= $msg ?></div>
        <?php endif; ?>
    </div>

    <div class="content-grid">
        <div class="glass-card">
            <h3 style="margin-top:0; color:#4ade80; font-size:18px; margin-bottom:20px;">
                <span id="formTitle">Register New Client</span>
            </h3>
            
            <form method="POST" id="clientForm">
                <input type="hidden" name="action" value="save_client">
                <input type="hidden" name="client_id" id="client_id">

                <div class="form-group">
                    <label class="form-label">Client Name</label>
                    <input type="text" name="name" id="name" class="form-input" required placeholder="Ex: Liam O'Connor">
                </div>

                <div class="form-group">
                    <label class="form-label">Company</label>
                    <select name="company_id" id="company_id" class="form-select" required>
                        <option value="">Select Company...</option>
                        <?php foreach($companies as $comp): ?>
                            <option value="<?= e($comp['company_id']) ?>"><?= e($comp['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label">Phone</label>
                    <input type="text" name="phone" id="phone" class="form-input" placeholder="+353 ...">
                </div>

                <div class="form-group">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" id="email" class="form-input" placeholder="client@example.ie">
                </div>

                <div class="form-group">
                    <label class="form-label">Address</label>
                    <input type="text" name="address" id="address" class="form-input" placeholder="Address...">
                </div>

                <button type="submit" class="btn btn-primary">
                    <i class="fa-solid fa-floppy-disk"></i> Save Client
                </button>
                
                <button type="button" onclick="resetForm()" class="btn btn-text">
                    Cancel
                </button>
            </form>
        </div>

        <div class="glass-card">
            <div style="overflow-x:auto;">
                <table>
                    <thead>
                        <tr>
                            <th>Name / Info</th>
                            <th>Company</th>
                            <th>Contact</th>
                            <th style="text-align:right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if(count($clients) > 0): foreach($clients as $c): ?>
                        <tr>
                            <td>
                                <strong style="color:#fff; display:block; font-size:15px;"><?= htmlspecialchars($c['name']) ?></strong>
                                <span style="color:#64748b; font-size:12px;"><?= htmlspecialchars($c['address']) ?></span>
                            </td>
                            <td>
                                <span class="badge"><?= htmlspecialchars($c['company_name'] ?? 'N/A') ?></span>
                            </td>
                            <td>
                                <div style="font-size:13px;"><?= e($c['phone']) ?></div>
                                <div style="font-size:13px; color:#4ade80;"><?= e($c['email']) ?></div>
                            </td>
                            <td style="text-align:right;">
                                <button onclick='edit(<?= htmlspecialchars(json_encode($c), ENT_QUOTES, 'UTF-8') ?>)' class="btn-icon" title="Edit">
                                    <i class="fa-solid fa-pen"></i>
                                </button>
                                <a href="?delete=<?= e($c['client_id']) ?>" class="btn-icon del" 
                                   onclick="return confirm('Delete this client?')" title="Delete">
                                    <i class="fa-solid fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <?php endforeach; else: ?>
                            <tr><td colspan="4" style="text-align:center; padding:30px; color:#64748b;">No clients found.</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</main>

<script>
function edit(data) {
    // Debug para verificar no Console (F12) se os dados chegaram
    console.log("Editando:", data);

    // Preencher campos
    document.getElementById('formTitle').innerText = "Edit Client: " + data.name;
    document.getElementById('client_id').value = data.client_id;
    document.getElementById('name').value = data.name;
    document.getElementById('company_id').value = data.company_id;
    document.getElementById('phone').value = data.phone;
    document.getElementById('email').value = data.email;
    document.getElementById('address').value = data.address;
    
    // Rolar para o topo
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function resetForm() {
    document.getElementById('formTitle').innerText = "Register New Client";
    document.getElementById('client_id').value = "";
    document.getElementById('clientForm').reset();
}
</script>

</body>
</html>