<?php
/* =========================================================
   animal.php — Livestock Management
   Style: Premium Glass (Updated Rules)
   Features: Auto-Tag, Unique Lots, Country Origin, Vet Suppliers
   UPDATED: Fixed Search, Added Status Filter, Fixed Menu
   ========================================================= */
require_once 'config.php';

// Verificação de Segurança
if (!isset($conn)) { die("Erro de conexão com o banco de dados."); }
if (!isset($_SESSION['user_id'])) { header("Location: login.php"); exit; }

$msg = "";
$msg_type = "";

// --- 1. ACTION: CREATE NEW LOT ---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_lot') {
    $lot_name    = trim($_POST['lot_name']);
    $lot_desc    = trim($_POST['lot_description']);
    $company_id  = $_POST['company_id'];
    $date        = date('Y-m-d'); 
    
    $check = $conn->prepare("SELECT lot_id FROM lot WHERE name = ?");
    $check->bind_param("s", $lot_name);
    $check->execute();
    $check->store_result();

    if ($check->num_rows > 0) {
        $msg = "Error: A Lot with this name already exists."; 
        $msg_type = "danger";
    } elseif (empty($company_id)) {
        $msg = "Error: Please select a company.";
        $msg_type = "danger";
    } else {
        $stmt = $conn->prepare("INSERT INTO lot (name, description, creation_date, company_id) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssi", $lot_name, $lot_desc, $date, $company_id);
        
        if ($stmt->execute()) {
            $msg = "New Lot created successfully!"; $msg_type = "success";
        } else {
            $msg = "Error creating lot: " . $conn->error; $msg_type = "danger";
        }
    }
}

// --- 2. ACTION: SAVE ANIMAL ---
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['action']) && $_POST['action'] == 'save_animal') {
    $animal_id = $_POST['animal_id'];
    $type_id   = $_POST['type_id']; 
    $gender    = $_POST['sex'];
    $status    = $_POST['status'];
    $dob       = $_POST['birth_date'];
    $city      = trim($_POST['birth_city']); 
    $country   = $_POST['country_id'];       
    $new_lot_id = !empty($_POST['lot_id']) ? (int) $_POST['lot_id'] : null;
    $current_lot_id = !empty($_POST['current_lot_id']) ? (int) $_POST['current_lot_id'] : null;

    if (empty($type_id) || empty($gender) || empty($status) || empty($dob) || empty($city) || empty($country) || empty($new_lot_id)) {
        $msg = "Error: All fields (Sex, Status, Date, Origin, Lot) are required.";
        $msg_type = "danger";
    } else {
        if (empty($animal_id)) {
            $tag = "TAG-" . strtoupper(substr(uniqid(), -5)); 
            $stmt = $conn->prepare("INSERT INTO animal (tag_number, type_id, sex, status, birth_date, birth_place, country_id) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->bind_param("sissssi", $tag, $type_id, $gender, $status, $dob, $city, $country);
            
            if ($stmt->execute()) {
                $saved_id = $conn->insert_id;
                $la = $conn->prepare("INSERT INTO lot_animals (lot_id, animal_id, entry_date) VALUES (?, ?, NOW())");
                $la->bind_param("ii", $new_lot_id, $saved_id);
                $la->execute();
                $msg = "Animal registered successfully! Generated Tag: <strong>$tag</strong>"; 
                $msg_type = "success";
            } else {
                $msg = "Error: " . $conn->error; $msg_type = "danger";
            }
        } else {
            // Edição
            $stmt = $conn->prepare("UPDATE animal SET type_id=?, sex=?, status=?, birth_date=?, birth_place=?, country_id=? WHERE animal_id=?");
            $stmt->bind_param("issssii", $type_id, $gender, $status, $dob, $city, $country, $animal_id);
            $stmt->execute();
            $saved_id = (int) $animal_id;

            if ($new_lot_id != $current_lot_id) {
                if ($current_lot_id) {
                    $ex = $conn->prepare("UPDATE lot_animals SET exit_date = NOW() WHERE animal_id = ? AND lot_id = ? AND exit_date IS NULL");
                    $ex->bind_param("ii", $saved_id, $current_lot_id);
                    $ex->execute();
                }
                $la = $conn->prepare("INSERT INTO lot_animals (lot_id, animal_id, entry_date) VALUES (?, ?, NOW())");
                $la->bind_param("ii", $new_lot_id, $saved_id);
                $la->execute();
            }
            $msg = "Animal updated successfully!"; $msg_type = "success";
        }
    }
}

// --- FETCH AUXILIARY DATA ---
$breeds = $conn->query("SELECT * FROM animal_types ORDER BY breed"); 
$medical_items = $conn->query("SELECT * FROM medical_catalog ORDER BY CASE type WHEN 'medicine' THEN 1 WHEN 'vaccine' THEN 2 WHEN 'service' THEN 3 WHEN 'equipment' THEN 4 ELSE 5 END, item_name");
$countries = $conn->query("SELECT * FROM european_countries ORDER BY country_name ASC");
$companies = $conn->query("SELECT * FROM company ORDER BY name ASC");
$vet_suppliers = $conn->query("SELECT * FROM suppliers WHERE status='active' ORDER BY name ASC");
$all_lots = $conn->query("SELECT * FROM lot ORDER BY name ASC");

// --- FILTER LOGIC ---
$search_query = isset($_GET['search']) ? trim($_GET['search']) : '';
$filter_company = isset($_GET['filter_company']) ? $_GET['filter_company'] : '';
$filter_lot = isset($_GET['filter_lot']) ? $_GET['filter_lot'] : '';
$filter_status = isset($_GET['filter_status']) ? $_GET['filter_status'] : ''; // Novo Filtro

$sql_animals = "SELECT a.*, t.breed, t.species, c.country_name, l.name as lot_name, l.lot_id as active_lot_id, l.company_id
                FROM animal a 
                LEFT JOIN animal_types t ON a.type_id = t.type_id 
                LEFT JOIN european_countries c ON a.country_id = c.country_id
                LEFT JOIN lot_animals la ON a.animal_id = la.animal_id AND la.exit_date IS NULL
                LEFT JOIN lot l ON la.lot_id = l.lot_id
                WHERE 1=1 ";

$params = [];
$types = "";

if (!empty($search_query)) {
    $sql_animals .= " AND (a.tag_number ILIKE ? OR t.breed ILIKE ?) ";
    $search_term = "%" . $search_query . "%";
    $params[] = $search_term; $params[] = $search_term;
    $types .= "ss";
}
if (!empty($filter_company)) {
    $sql_animals .= " AND l.company_id = ? ";
    $params[] = $filter_company; $types .= "i";
}
if (!empty($filter_lot)) {
    $sql_animals .= " AND l.lot_id = ? ";
    $params[] = $filter_lot; $types .= "i";
}
// Novo Filtro de Status na Query
if (!empty($filter_status)) {
    $sql_animals .= " AND a.status = ? ";
    $params[] = $filter_status; $types .= "s";
}

$sql_animals .= " ORDER BY CASE a.status WHEN 'active' THEN 1 WHEN 'sold' THEN 2 WHEN 'dead' THEN 3 ELSE 4 END, a.animal_id DESC"; // same order as the old MySQL ENUM

$stmt = $conn->prepare($sql_animals);
if (!empty($params)) { $stmt->bind_param($types, ...$params); }
$stmt->execute();
$animals_list = $stmt->get_result();

$lots_filter_sql = "SELECT * FROM lot";
if(!empty($filter_company)) { $lots_filter_sql .= " WHERE company_id = " . intval($filter_company); }
$lots_for_filter = $conn->query($lots_filter_sql . " ORDER BY name ASC");
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Livestock Management | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        :root { --brand: #4ade80; --bg-dark: #05070a; --panel: rgba(20, 26, 38, 0.85); --border: rgba(255, 255, 255, 0.15); --text: #eaf1ff; --muted: #9fb0d0; --input-bg: rgba(255, 255, 255, 0.07); }
        
        body { background-color: var(--bg-dark); background-image: url('assets/img/dowloag.png'); background-size: cover; background-position: center; background-attachment: fixed; color: var(--text); font-family: "Segoe UI", sans-serif; overflow-x: hidden; }
        body::before { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(10, 15, 25, 0.8); z-index: -1; }
        
        /* HEADER & MENU FIX */
        .topbar { background: rgba(15, 23, 42, 0.95); padding: 0 40px; height: 64px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); backdrop-filter: blur(15px); position: sticky; top: 0; z-index: 1000; }
        .brand { font-size: 22px; font-weight: 700; color: var(--brand); display:flex; gap:10px; align-items:center; text-decoration: none; }
        .menu { display:flex; gap:15px; align-items:center; height: 100%; }
        .menu a.nav-link { color: var(--muted); text-decoration:none; display:flex; gap:8px; align-items:center; font-size:14px; transition:.2s; height: 100%; padding: 0 10px; }
        .menu a.nav-link:hover, .menu a.nav-link.active { color: var(--brand); }
        
        /* Dropdown Styles */
        .dropdown { position: relative; display: flex; align-items: center; height: 100%; }
        .dropbtn { background: transparent; color: var(--muted); font-size: 14px; border: none; cursor: pointer; display: flex; align-items: center; gap: 8px; font-family: inherit; transition: .2s; padding: 0 10px; height: 100%; }
        .dropdown:hover .dropbtn { color: var(--brand); }
        .dropdown-content { display: none; position: absolute; background-color: #1e293b; min-width: 230px; box-shadow: 0px 10px 30px rgba(0,0,0,0.8); border: 1px solid var(--border); border-radius: 12px; z-index: 1000; top: 100%; right: 0; padding: 8px 0; overflow: hidden; }
        .dropdown-content a { color: var(--text); padding: 12px 20px; text-decoration: none; display: flex; align-items: center; gap: 12px; font-size: 14px; transition: all 0.2s; }
        .dropdown-content a:hover { background-color: rgba(74, 222, 128, 0.1); color: var(--brand); padding-left: 25px; }
        .dropdown:hover .dropdown-content { display: block; }

        .main { padding: 40px; min-height: calc(100vh - 64px); max-width: 1300px; margin: 0 auto; }
        
        /* FIXED FILTER BAR */
        .filter-bar { background: rgba(255,255,255,0.03); backdrop-filter: blur(10px); border: 1px solid var(--border); border-radius: 16px; padding: 20px; margin-bottom: 25px; display: flex; gap: 15px; align-items: end; flex-wrap: wrap; }
        
        /* Improved Input Search */
        .form-control, .form-select { 
            background: rgba(0, 0, 0, 0.3) !important; /* Mais escuro para contraste */
            border: 1px solid rgba(255, 255, 255, 0.2) !important; 
            color: #fff !important; 
            border-radius: 8px;
            padding: 10px 12px;
        }
        .form-control:focus, .form-select:focus {
            background: rgba(0, 0, 0, 0.5) !important;
            border-color: var(--brand) !important;
            box-shadow: 0 0 0 3px rgba(74, 222, 128, 0.1);
        }
        .form-control::placeholder { color: rgba(255, 255, 255, 0.4); }
        label { font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; color: var(--muted); margin-bottom: 5px; font-weight: 600; }

        .custom-card { background: rgba(20, 26, 38, 0.6); backdrop-filter: blur(20px); border: 1px solid var(--border); border-radius: 20px; padding: 25px; }
        .table { --bs-table-bg: transparent; --bs-table-color: var(--text); }
        .table-hover tbody tr:hover { color: var(--text) !important; background-color: rgba(255, 255, 255, 0.08); }
        
        /* CORES DE STATUS */
        .status-badge { padding: 5px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; border: 1px solid transparent; }
        .status-active { background: rgba(74, 222, 128, 0.15); color: #4ade80; border-color: rgba(74, 222, 128, 0.3); }
        .status-sold { background: rgba(250, 204, 21, 0.15); color: #facc15; border-color: rgba(250, 204, 21, 0.3); } /* Dourado */
        .status-dead { background: rgba(239, 68, 68, 0.15); color: #ef4444; border-color: rgba(239, 68, 68, 0.3); }   /* Vermelho */

        .tag-badge { font-family: monospace; color: #fbbf24; background: rgba(0,0,0,0.4); padding: 4px 8px; border-radius: 6px; border: 1px solid rgba(251,191,36,0.3); }
        .btn-primary { background: var(--brand); color: #000; border: none; border-radius: 50px; font-weight: 700; padding: 8px 24px; transition: .2s; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(74, 222, 128, 0.4); }
        .action-btn { width: 34px; height: 34px; border-radius: 50%; border: 1px solid var(--border); background: transparent; color: var(--muted); transition: .2s; }
        .action-btn:hover { background: var(--brand); color: #000; border-color: var(--brand); }
        .modal-content { background: #111827; border: 1px solid var(--border); border-radius: 16px; color: #fff; }
    </style>
</head>
<body>

<header class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    
    <nav class="menu">
        <a href="dashboard.php" class="nav-link"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php" class="nav-link active"><i class="fa-solid fa-cow"></i> Animals</a>
        <a href="feeding.php" class="nav-link"><i class="fa-solid fa-bucket"></i> Feeding</a>
        <a href="weighing.php" class="nav-link"><i class="fa-solid fa-scale-balanced"></i> Weighing</a>
        <a href="financial_dashboard.php" class="nav-link"><i class="fa-solid fa-coins"></i> Financial</a>
        
        <div class="dropdown">
            <button class="dropbtn"><i class="fa-solid fa-chart-pie"></i> Reports <i class="fa-solid fa-caret-down"></i></button>
            <div class="dropdown-content">
                <a href="reports_animals.php"><i class="fa-solid fa-cow"></i> Animal Reports</a>
                <a href="reports_weight.php"><i class="fa-solid fa-weight-scale"></i> Weight Control</a>
                <a href="reports_health.php"><i class="fa-solid fa-heart-pulse"></i> Health & Medical</a>
                <a href="reports_financial.php"><i class="fa-solid fa-file-invoice-dollar"></i> Financial Overview</a>
            </div>
        </div>

        <div class="dropdown">
            <button class="dropbtn"><i class="fa-solid fa-gear"></i> Admin <i class="fa-solid fa-caret-down"></i></button>
            <div class="dropdown-content">
                <a href="settings.php"><i class="fa-solid fa-sliders"></i> Settings</a>
                <a href="suppliers_list.php"><i class="fa-solid fa-truck-field"></i> Suppliers</a>
                <a href="medical_catalog.php"><i class="fa-solid fa-prescription-bottle-medical"></i> Medical Catalog</a>
                <a href="breeds.php"><i class="fa-solid fa-dna"></i> Breeds</a>
            </div>
        </div>
        <a href="login.php?logout=true" class="nav-link" style="color:#ef4444 !important" title="Exit"><i class="fa-solid fa-right-from-bracket"></i></a>
    </nav>
</header>

<main class="main">
    <div class="page-header d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2>Livestock Management</h2>
            <p class="text-muted">Manage animals, treatments and movements.</p>
        </div>
        <div>
            <button class="btn btn-outline-light rounded-pill me-2" onclick="openLotModal()"><i class="fa-solid fa-layer-group me-2"></i>New Lot</button>
            <button class="btn btn-primary" onclick="openAnimalModal('new')"><i class="fa-solid fa-plus me-2"></i>Register Animal</button>
        </div>
    </div>

    <?php if ($msg): ?>
        <div class="alert alert-<?= e($msg_type) ?> alert-dismissible fade show" style="background:rgba(0,0,0,0.5); color:#fff; border-left:4px solid <?= $msg_type=='success'?'#4ade80':'#ef4444'?>">
            <?= $msg ?> <button type="button" class="btn-close btn-close-white" data-bs-dismiss="alert"></button>
        </div>
    <?php endif; ?>

    <form class="filter-bar" method="GET">
        <div class="flex-grow-1">
            <label>Search (Tag/Breed)</label>
            <div class="input-group">
                <span class="input-group-text" style="background:rgba(0,0,0,0.3); border-color:rgba(255,255,255,0.2); color:#999;"><i class="fa-solid fa-magnifying-glass"></i></span>
                <input type="text" name="search" class="form-control" placeholder="Type to search..." value="<?= htmlspecialchars($search_query) ?>">
            </div>
        </div>
        
        <div style="min-width: 150px;">
            <label>Status</label>
            <select name="filter_status" class="form-select" onchange="this.form.submit()">
                <option value="">All Status</option>
                <option value="active" <?= $filter_status=='active'?'selected':'' ?>>Active</option>
                <option value="sold" <?= $filter_status=='sold'?'selected':'' ?>>Sold</option>
                <option value="dead" <?= $filter_status=='dead'?'selected':'' ?>>Dead</option>
            </select>
        </div>

        <div style="min-width: 200px;">
            <label>Company</label>
            <select name="filter_company" class="form-select" onchange="this.form.submit()">
                <option value="">All Companies</option>
                <?php while($co = $companies->fetch_assoc()): ?>
                    <option value="<?= e($co['company_id']) ?>" <?= $filter_company==$co['company_id']?'selected':'' ?>><?= htmlspecialchars($co['name']) ?></option>
                <?php endwhile; ?>
            </select>
        </div>
        
        <div style="min-width: 200px;">
            <label>Lot</label>
            <select name="filter_lot" class="form-select">
                <option value="">All Lots</option>
                <?php if($lots_for_filter) { $lots_for_filter->data_seek(0); while($lf = $lots_for_filter->fetch_assoc()): ?>
                    <option value="<?= e($lf['lot_id']) ?>" <?= $filter_lot==$lf['lot_id']?'selected':'' ?>><?= htmlspecialchars($lf['name']) ?></option>
                <?php endwhile; } ?>
            </select>
        </div>
        <div>
            <label style="visibility:hidden">Action</label>
            <button type="submit" class="btn btn-primary d-block">Filter</button>
        </div>
    </form>

    <div class="custom-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th>Tag</th>
                        <th>Breed / Origin</th>
                        <th>Current Lot</th>
                        <th>Status</th>
                        <th class="text-end">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php if($animals_list->num_rows > 0): while($row = $animals_list->fetch_assoc()): 
                        // Lógica de Cores de Status
                        $status_class = 'status-active';
                        if($row['status'] == 'sold') $status_class = 'status-sold';
                        if($row['status'] == 'dead') $status_class = 'status-dead';
                    ?>
                    <tr>
                        <td><span class="tag-badge"><?= e($row['tag_number']) ?></span></td>
                        <td><strong><?= e($row['breed']) ?></strong><br><small class="text-muted"><?= e($row['country_name']) ?></small></td>
                        <td><span class="badge bg-dark border border-secondary"><?= $row['lot_name'] ?? 'No Lot' ?></span></td>
                        <td>
                            <span class="status-badge <?= e($status_class) ?>">
                                <?= strtoupper($row['status']) ?>
                            </span>
                        </td>
                        <td class="text-end">
                            <button class="action-btn me-1" onclick='openHealthModal(<?= e(json_encode($row)) ?>)'><i class="fa-solid fa-heart-pulse"></i></button>
                            <button class="action-btn" onclick='openAnimalModal("edit", <?= e(json_encode($row)) ?>)'><i class="fa-solid fa-pen"></i></button>
                        </td>
                    </tr>
                    <?php endwhile; else: ?>
                        <tr><td colspan="5" class="text-center py-4 text-muted">No animals found matching filters.</td></tr>
                    <?php endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</main>

<div class="modal fade" id="animalModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header border-secondary"><h5 class="modal-title" id="animalModalTitle">Animal Record</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_animal">
                    <input type="hidden" name="animal_id" id="animal_id">
                    <input type="hidden" name="current_lot_id" id="current_lot_id">
                    <input type="hidden" name="tag_number_hidden" id="tag_number_hidden">
                    <div class="row g-3">
                        <div class="col-md-6"><label>Breed *</label><select name="type_id" id="type_id" class="form-select" required><?php $breeds->data_seek(0); while($b = $breeds->fetch_assoc()) echo "<option value='" . e($b['type_id']) . "'>" . e($b['breed']) . "</option>"; ?></select></div>
                        <div class="col-md-6"><label>Lot *</label><select name="lot_id" id="lot_id" class="form-select" required><?php $all_lots->data_seek(0); while($l = $all_lots->fetch_assoc()) echo "<option value='" . e($l['lot_id']) . "'>" . e($l['name']) . "</option>"; ?></select></div>
                        <div class="col-md-4"><label>Sex</label><select name="sex" id="sex" class="form-select"><option value="male">Male</option><option value="female">Female</option></select></div>
                        <div class="col-md-4"><label>Status</label><select name="status" id="status" class="form-select"><option value="active">Active</option><option value="sold">Sold</option><option value="dead">Dead</option></select></div>
                        <div class="col-md-4"><label>Birth Date</label><input type="date" name="birth_date" id="birth_date" class="form-control" required></div>
                        <div class="col-md-6"><label>Origin Country</label><select name="country_id" id="country_id" class="form-select"><?php $countries->data_seek(0); while($c = $countries->fetch_assoc()) echo "<option value='" . e($c['country_id']) . "'>" . e($c['country_name']) . "</option>"; ?></select></div>
                        <div class="col-md-6"><label>City/Farm</label><input type="text" name="birth_city" id="birth_city" class="form-control"></div>
                    </div>
                </div>
                <div class="modal-footer border-secondary"><button type="submit" class="btn btn-primary w-100">Save Animal</button></div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="lotModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="POST">
                <div class="modal-header border-secondary"><h5 class="modal-title">New Lot</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
                <div class="modal-body">
                    <input type="hidden" name="action" value="save_lot">
                    <div class="mb-3"><label>Company</label><select name="company_id" class="form-select" required><option value="">Select...</option><?php $companies->data_seek(0); while($co = $companies->fetch_assoc()) echo "<option value='" . e($co['company_id']) . "'>" . e($co['name']) . "</option>"; ?></select></div>
                    <div class="mb-3"><label>Lot Name</label><input type="text" name="lot_name" class="form-control" required></div>
                    <div class="mb-3"><label>Description</label><textarea name="lot_description" class="form-control"></textarea></div>
                </div>
                <div class="modal-footer border-secondary"><button type="submit" class="btn btn-primary w-100">Create Lot</button></div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="healthModal" tabindex="-1">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header border-danger"><h5 class="modal-title"><i class="fa-solid fa-heart-pulse me-2 text-danger"></i>Health: <span id="healthTagDisplay"></span></h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <form id="healthForm" class="mb-4 p-3 rounded" style="background:rgba(255,255,255,0.05)">
                    <input type="hidden" name="animal_id" id="health_animal_id">
                    <div class="row g-2">
                        <div class="col-md-6"><label>Vet/Supplier</label><select name="vet_name" id="h_vet" class="form-select form-select-sm"><?php if($vet_suppliers) { $vet_suppliers->data_seek(0); while($v = $vet_suppliers->fetch_assoc()) echo "<option value='".htmlspecialchars($v['name'])."'>".htmlspecialchars($v['name'])."</option>"; } ?></select></div>
                        <div class="col-md-6"><label>Medicine/Procedure</label><select name="item_id" id="h_item_id" class="form-select form-select-sm"><?php if($medical_items) { $medical_items->data_seek(0); while($m = $medical_items->fetch_assoc()) echo "<option value='" . e($m['item_id']) . "'>" . e($m['item_name']) . "</option>"; } ?></select></div>
                        <div class="col-md-12"><label>Diagnosis/Notes</label><textarea name="diagnosis" id="h_diagnosis" class="form-control form-control-sm" rows="2"></textarea></div>
                        <div class="col-md-12 text-end mt-2"><button type="submit" class="btn btn-danger btn-sm" id="btnSaveHealth">Add Record</button></div>
                    </div>
                </form>
                <h6>History</h6>
                <div class="table-responsive"><table class="table table-sm"><thead class="text-muted"><tr><th>Date</th><th>Item</th><th>Vet</th><th>Notes</th></tr></thead><tbody id="historyBody"></tbody></table></div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function esc(v){return String(v ?? '').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
    const animalModal = new bootstrap.Modal(document.getElementById('animalModal'));
    const lotModal = new bootstrap.Modal(document.getElementById('lotModal'));
    const healthModal = new bootstrap.Modal(document.getElementById('healthModal'));

    function openLotModal() { lotModal.show(); }

    function openAnimalModal(mode, data = null) {
        document.getElementById('animalModal').querySelector('form').reset();
        if (mode === 'edit' && data) {
            document.getElementById('animalModalTitle').innerText = 'Edit Animal: ' + data.tag_number;
            document.getElementById('animal_id').value = data.animal_id;
            document.getElementById('tag_number_hidden').value = data.tag_number;
            document.getElementById('type_id').value = data.type_id;
            document.getElementById('lot_id').value = data.active_lot_id || '';
            document.getElementById('current_lot_id').value = data.active_lot_id || ''; 
            document.getElementById('sex').value = data.sex;
            document.getElementById('status').value = data.status;
            document.getElementById('birth_date').value = data.birth_date;
            document.getElementById('birth_city').value = data.birth_place; 
            document.getElementById('country_id').value = data.country_id;
        } else {
            document.getElementById('animalModalTitle').innerText = 'Register New Animal';
            document.getElementById('animal_id').value = '';
        }
        animalModal.show();
    }

    function openHealthModal(data) {
        document.getElementById('healthTagDisplay').innerText = data.tag_number;
        document.getElementById('health_animal_id').value = data.animal_id;
        loadHealthHistory(data.animal_id);
        healthModal.show();
    }

    function loadHealthHistory(id) {
        const tbody = document.getElementById('historyBody');
        tbody.innerHTML = '<tr><td colspan="4" class="text-center">Loading...</td></tr>';
        fetch('get_health_history.php?animal_id=' + id)
            .then(r => r.json())
            .then(data => {
                tbody.innerHTML = '';
                data.forEach(h => {
                    tbody.innerHTML += `<tr><td>${esc(h.treatment_date)}</td><td>${esc(h.item_name)}</td><td>${esc(h.vet_name)}</td><td>${esc(h.diagnosis)}</td></tr>`;
                });
                if(data.length === 0) tbody.innerHTML = '<tr><td colspan="4" class="text-center">No records.</td></tr>';
            });
    }

    document.getElementById('healthForm').addEventListener('submit', function(e) {
        e.preventDefault();
        fetch('save_health_record.php', { method: 'POST', body: new FormData(this) })
            .then(r => r.json())
            .then(res => { if(res.success) loadHealthHistory(document.getElementById('health_animal_id').value); else alert(res.message); });
    });
</script>
</body>
</html>