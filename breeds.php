<?php
/* =========================================================
   breeds.php — Animal Breeds Management
   Style: Premium Glass (Matched with Settings/Animal)
   Fix: Visible Descriptions & Dark Mode Layout
   ========================================================= */
require_once 'config.php';

// Verificações de Segurança
if (!isset($conn)) { die("Erro: Conexão com banco não encontrada."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// ---1---
if (isset($_GET['delete'])) {
    $id = intval($_GET['delete']);
    // Verifica se a raça está em uso antes de deletar
    $check = $conn->query("SELECT COUNT(*) as count FROM animal WHERE type_id = $id")->fetch_assoc();
    
    if ($check['count'] > 0) {
        $msg = "Cannot delete: There are animals registered with this breed.";
        $msg_type = "danger";
    } else {
        $stmt = $conn->prepare("DELETE FROM animal_types WHERE type_id = ?");
        $stmt->bind_param("i", $id);
        if ($stmt->execute()) {
            $msg = "Breed deleted successfully!"; $msg_type = "success";
        } else {
            $msg = "Error deleting: " . $conn->error; $msg_type = "danger";
        }
        $stmt->close();
    }
}

// --- 2---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_breed') {
    $type_id = $_POST['type_id'] ?? '';
    $species = $_POST['species'];
    $breed   = trim($_POST['breed']);
    $desc    = trim($_POST['description']);

    if (empty($species) || empty($breed)) {
        $msg = "Error: Species and Breed Name are required.";
        $msg_type = "danger";
    } else {
        if (!empty($type_id)) {
            // UPDATE
            $stmt = $conn->prepare("UPDATE animal_types SET species=?, breed=?, description=? WHERE type_id=?");
            $stmt->bind_param("sssi", $species, $breed, $desc, $type_id);
        } else {
            // INSERT
            $stmt = $conn->prepare("INSERT INTO animal_types (species, breed, description) VALUES (?, ?, ?)");
            $stmt->bind_param("sss", $species, $breed, $desc);
        }

        if ($stmt->execute()) {
            $msg = "Breed record saved successfully!"; $msg_type = "success";
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
    <title>Animal Breeds | Farm Project</title>
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

        /* Main Content */
        .main { padding: 40px; min-height: calc(100vh - 64px); max-width: 1300px; margin: 0 auto; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .page-header h2 { font-size: 32px; font-weight: 700; margin: 0; text-shadow: 0 2px 10px rgba(0,0,0,0.5); }
        
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
        
        /* Species Icons Badge */
        .species-badge { 
            width: 40px; height: 40px; border-radius: 50%; 
            display: flex; align-items: center; justify-content: center; 
            font-size: 18px; border: 1px solid var(--border);
            background: rgba(255,255,255,0.05); color: var(--brand);
        }

        /* Buttons */
        .btn-primary { background-color: var(--brand); border: none; color: #000; font-weight: 700; padding: 10px 24px; border-radius: 50px; box-shadow: 0 0 15px rgba(74, 222, 128, 0.2); transition: 0.3s; }
        .btn-primary:hover { background-color: #22c55e; transform: translateY(-2px); box-shadow: 0 0 20px rgba(74, 222, 128, 0.4); }
        
        .action-btn { width: 34px; height: 34px; border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; border: 1px solid var(--border); background: transparent; color: var(--muted); transition: 0.2s; text-decoration: none; }
        .action-btn:hover { background: var(--brand); color: #000; border-color: var(--brand); transform: scale(1.1); }
        .action-btn.delete:hover { background: #ef4444; color: #fff; border-color: #ef4444; }

        /* Modals (Dark) */
        .modal-content { background-color: #111827; color: var(--text); border: 1px solid var(--border); border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.8); }
        .modal-header { border-bottom: 1px solid var(--border); padding: 20px 25px; }
        .modal-body { padding: 30px; }
        .modal-footer { border-top: 1px solid var(--border); padding: 20px 25px; }
        .btn-close { filter: invert(1); opacity: 0.7; }
        
        .form-control, .form-select { 
            background-color: var(--input-bg) !important; 
            border: 1px solid var(--border) !important; 
            color: #fff !important; 
            border-radius: 10px; padding: 12px; 
        }
        .form-control:focus, .form-select:focus { 
            border-color: var(--brand) !important; 
            box-shadow: 0 0 0 2px rgba(74, 222, 128, 0.2); 
            background-color: #000 !important; 
        }
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
            <h2>Animal Breeds</h2>
            <p>Manage species and breed classifications.</p>
        </div>
        <button class="btn btn-primary" onclick="openModal('new')">
            <i class="fa-solid fa-plus me-2"></i>Add Breed
        </button>
    </div>

    <?php if ($msg): ?>
        <div class="alert alert-<?= $msg_type == 'success' ? 'success' : 'danger' ?> alert-dismissible fade show" role="alert" 
             style="background: rgba(0,0,0,0.6); border: 1px solid var(--border); color: #fff; border-left: 4px solid <?= $msg_type == 'success' ? '#4ade80' : '#ef4444' ?>;">
            <?= $msg ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <?php endif; ?>

    <div class="custom-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-3">Species</th>
                        <th>Breed Name</th>
                        <th>Description</th>
                        <th class="text-end pe-4">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $result = $conn->query("SELECT * FROM animal_types ORDER BY species, breed");
                    
                    if ($result && $result->num_rows > 0):
                        while($row = $result->fetch_assoc()):
                            // Define Icon based on Species ENUM
                            $icon = 'fa-paw';
                            switch($row['species']) {
                                case 'cattle': $icon = 'fa-cow'; break;
                                case 'sheep': $icon = 'fa-sheet-plastic'; break; // or fa-sheep if available
                                case 'horse': $icon = 'fa-horse'; break;
                                case 'pig': $icon = 'fa-piggy-bank'; break;
                                default: $icon = 'fa-paw';
                            }
                    ?>
                    <tr>
                        <td class="ps-3">
                            <div class="d-flex align-items-center gap-3">
                                <div class="species-badge"><i class="fa-solid <?= $icon ?>"></i></div>
                                <span style="text-transform:uppercase; font-weight:600; letter-spacing:1px; color:var(--muted); font-size:0.8rem;">
                                    <?= htmlspecialchars($row['species']) ?>
                                </span>
                            </div>
                        </td>
                        <td>
                            <div class="fw-bold text-white fs-6"><?= htmlspecialchars($row['breed']) ?></div>
                        </td>
                        <td>
                            <div style="color: var(--muted); font-size: 0.9rem; line-height: 1.4;">
                                <?= htmlspecialchars($row['description']) ?>
                            </div>
                        </td>
                        <td class="text-end pe-4">
                            <button class="action-btn me-2" onclick='openModal("edit", <?= e(json_encode($row)) ?>)' title="Edit">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <a href="?delete=<?= e($row['type_id']) ?>" class="action-btn delete" onclick="return confirm('Delete this breed?');" title="Delete">
                                <i class="fa-solid fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                    <?php endwhile; 
                    else: ?>
                    <tr><td colspan="4" class="text-center py-5 text-muted">No breeds found.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<div class="modal fade" id="breedModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold text-white" id="modalTitle">Add New Breed</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_breed">
                    <input type="hidden" name="type_id" id="type_id">

                    <div class="mb-3">
                        <label class="form-label">Species *</label>
                        <select name="species" id="species" class="form-select" required>
                            <option value="cattle">Cattle</option>
                            <option value="sheep">Sheep</option>
                            <option value="goat">Goat</option>
                            <option value="pig">Pig</option>
                            <option value="horse">Horse</option>
                            <option value="other">Other</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Breed Name *</label>
                        <input type="text" name="breed" id="breed" class="form-control" required placeholder="e.g. Holstein, Angus">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <textarea name="description" id="description" class="form-control" rows="3"></textarea>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" style="background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.1); color:#fff;" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Breed</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var breedModalObj;
    document.addEventListener('DOMContentLoaded', function() {
        var modalEl = document.getElementById('breedModal');
        breedModalObj = new bootstrap.Modal(modalEl);
    });

    function openModal(mode, data = null) {
        document.querySelector('form').reset();
        
        if (mode === 'new') {
            document.getElementById('modalTitle').innerText = 'Add New Breed';
            document.getElementById('type_id').value = '';
        } else if (mode === 'edit' && data) {
            document.getElementById('modalTitle').innerText = 'Edit Breed';
            document.getElementById('type_id').value = data.type_id;
            document.getElementById('species').value = data.species;
            document.getElementById('breed').value = data.breed;
            document.getElementById('description').value = data.description;
        }
        breedModalObj.show();
    }
</script>

</body>
</html>