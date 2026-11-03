<?php
/* =========================================================
   ai_vision.php — AI Vision & Clinical Analysis
   Style: Premium Glass (Matching animal.php)
   ========================================================= */
require_once 'config.php';

// Security Check
require_login();

// Fetch active animals for the select dropdown
$animals = [];
$stmt = $conn->query("SELECT animal_id, tag_number, sex FROM animal WHERE status = 'active' ORDER BY animal_id DESC LIMIT 100");
if ($stmt) {
    while ($row = $stmt->fetch_assoc()) {
        $animals[] = $row;
    }
}

// --- AI INTEGRATION (Claude API, see vet_ai.php) ---
require_once 'vet_ai.php';
$ai_report = null;
$error_msg = null;

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $animal_id   = (int) ($_POST['animal_id'] ?? 0);
    $temperature = (isset($_POST['temperature']) && $_POST['temperature'] !== '') ? (float) $_POST['temperature'] : null;
    $symptoms    = is_array($_POST['symptoms'] ?? null) ? $_POST['symptoms'] : [];
    $observations = mb_substr(trim((string) ($_POST['observations'] ?? '')), 0, 2000);

    // Optional photo (validated: jpg/png/webp/gif, max 5 MB)
    $image_path = null;
    if (!empty($_FILES['animal_image']['name'])) {
        $image_path = safe_upload($_FILES['animal_image'], 'ai_vision', ['jpg', 'png', 'webp', 'gif']);
        if (!$image_path) { $error_msg = "The photo must be a JPG, PNG, WEBP or GIF image up to 5 MB."; }
    }

    if (!$error_msg) {
        if ($animal_id <= 0) {
            $error_msg = "Please select an animal.";
        } elseif ($temperature !== null && ($temperature < 30 || $temperature > 45)) {
            $error_msg = "Temperature looks wrong: enter it in °C (normal cattle range is about 38.0–39.5).";
        } else {
            $result = vet_ai_analyse($conn, $animal_id, $temperature, $symptoms, $observations, $image_path);
            if (isset($result['error'])) { $error_msg = $result['error']; }
            else { $ai_report = $result['report']; }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AI Vision Analysis | Farm Project</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        /* PREMIUM GLASS STYLES */
        :root { --brand: #4ade80; --bg-dark: #05070a; --panel: rgba(20, 26, 38, 0.85); --border: rgba(255, 255, 255, 0.15); --text: #eaf1ff; --muted: #9fb0d0; --input-bg: rgba(255, 255, 255, 0.07); --ai-color: #a855f7; }
        
        body { background-color: var(--bg-dark); background-image: url('assets/img/dowloag.png'); background-size: cover; background-position: center; background-attachment: fixed; color: var(--text); font-family: "Segoe UI", sans-serif; overflow-x: hidden; }
        body::before { content: ""; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(10, 15, 25, 0.8); z-index: -1; }
        
        .topbar { background: rgba(15, 23, 42, 0.95); padding: 0 40px; height: 64px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border); backdrop-filter: blur(15px); position: sticky; top: 0; z-index: 1000; }
        .brand { font-size: 22px; font-weight: 700; color: var(--brand); display:flex; gap:10px; align-items:center; text-decoration: none; }
        .menu { display:flex; gap:15px; align-items:center; height: 100%; }
        .menu a.nav-link { color: var(--muted); text-decoration:none; display:flex; gap:8px; align-items:center; font-size:14px; transition:.2s; height: 100%; padding: 0 10px; }
        .menu a.nav-link:hover, .menu a.nav-link.active { color: var(--brand); }
        
        .dropdown { position: relative; display: flex; align-items: center; height: 100%; }
        .dropbtn { background: transparent; color: var(--muted); font-size: 14px; border: none; cursor: pointer; display: flex; align-items: center; gap: 8px; font-family: inherit; transition: .2s; padding: 0 10px; height: 100%; }
        .dropdown:hover .dropbtn { color: var(--brand); }
        .dropdown-content { display: none; position: absolute; background-color: #1e293b; min-width: 230px; box-shadow: 0px 10px 30px rgba(0,0,0,0.8); border: 1px solid var(--border); border-radius: 12px; z-index: 1000; top: 100%; right: 0; padding: 8px 0; overflow: hidden; }
        .dropdown-content a { color: var(--text); padding: 12px 20px; text-decoration: none; display: flex; align-items: center; gap: 12px; font-size: 14px; transition: all 0.2s; }
        .dropdown-content a:hover { background-color: rgba(74, 222, 128, 0.1); color: var(--brand); padding-left: 25px; }
        .dropdown:hover .dropdown-content { display: block; }

        .main { padding: 40px; min-height: calc(100vh - 64px); max-width: 1400px; margin: 0 auto; }
        
        .form-control, .form-select { background: rgba(0, 0, 0, 0.3) !important; border: 1px solid rgba(255, 255, 255, 0.2) !important; color: #fff !important; border-radius: 8px; padding: 10px 12px; }
        .form-control:focus, .form-select:focus { background: rgba(0, 0, 0, 0.5) !important; border-color: var(--ai-color) !important; box-shadow: 0 0 0 3px rgba(168, 85, 247, 0.2); }
        .form-control::placeholder { color: rgba(255, 255, 255, 0.4); }
        label { font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; color: var(--muted); margin-bottom: 5px; font-weight: 600; }

        .custom-card { background: rgba(20, 26, 38, 0.6); backdrop-filter: blur(20px); border: 1px solid var(--border); border-radius: 20px; padding: 25px; }
        
        .btn-ai { background: var(--ai-color); color: #fff; border: none; border-radius: 8px; font-weight: 700; padding: 12px 24px; transition: .2s; }
        .btn-ai:hover { background: #9333ea; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(168, 85, 247, 0.4); color: white; }

        .ai-result-box { background: rgba(255,255,255,0.03); border-radius: 12px; padding: 15px; border: 1px solid rgba(255,255,255,0.05); }
        .ai-text-purple { color: #d8b4fe; }

        /* LOADING SCREEN STYLES (UX) */
        #loading-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(5, 7, 10, 0.9);
            backdrop-filter: blur(8px);
            z-index: 9999;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        
        .spinner-ai {
            width: 4rem; height: 4rem;
            border: 4px solid rgba(168, 85, 247, 0.2);
            border-top-color: var(--ai-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }

        .loading-text {
            color: white; font-size: 1.2rem; font-weight: 600;
            animation: pulse-text 1.5s infinite; text-align: center;
        }

        @keyframes spin { 100% { transform: rotate(360deg); } }
        @keyframes pulse-text { 0% { opacity: 0.7; } 50% { opacity: 1; } 100% { opacity: 0.7; } }
    </style>
</head>
<body>

<div id="loading-overlay">
    <div class="spinner-ai"></div>
    <div class="loading-text">
        <i class="fa-solid fa-brain" style="color: var(--ai-color);"></i> AI is analyzing clinical data...<br>
        <small style="color: var(--muted); font-size: 0.9rem; font-weight: normal;">Consulting PubMed and generating hypotheses</small>
    </div>
</div>

<header class="topbar">
    <a href="dashboard.php" class="brand"><i class="fa-solid fa-tractor"></i> Farm Project</a>
    
    <nav class="menu">
        <a href="dashboard.php" class="nav-link"><i class="fa-solid fa-house"></i> Overview</a>
        <a href="animal.php" class="nav-link"><i class="fa-solid fa-cow"></i> Animals</a>
        <a href="feeding.php" class="nav-link"><i class="fa-solid fa-bucket"></i> Feeding</a>
        <a href="weighing.php" class="nav-link"><i class="fa-solid fa-scale-balanced"></i> Weighing</a>
        <a href="financial_dashboard.php" class="nav-link"><i class="fa-solid fa-coins"></i> Financial</a>
        <a href="ai_vision.php" class="nav-link active" style="color: var(--ai-color);"><i class="fa-solid fa-brain"></i> AI Assistant</a>
        
        <div class="dropdown">
            <button class="dropbtn"><i class="fa-solid fa-chart-pie"></i> Reports <i class="fa-solid fa-caret-down"></i></button>
            <div class="dropdown-content">
                <a href="reports_animals.php"><i class="fa-solid fa-cow"></i> Animal Reports</a>
                <a href="reports_weight.php"><i class="fa-solid fa-weight-scale"></i> Weight Control</a>
                <a href="reports_health.php"><i class="fa-solid fa-heart-pulse"></i> Health & Medical</a>
            </div>
        </div>
    </nav>
</header>

<div class="main container-fluid">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2><i class="fa-solid fa-brain" style="color: var(--ai-color);"></i> AI Clinical Assistant</h2>
    </div>

    <?php if ($error_msg): ?>
        <div class="alert alert-danger" style="background: rgba(239, 68, 68, 0.2); border-color: rgba(239, 68, 68, 0.4); color: #fca5a5;">
            <i class="fas fa-exclamation-triangle"></i> <?= nl2br(htmlspecialchars($error_msg)) ?>
        </div>
    <?php endif; ?>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="custom-card h-100" style="border-top: 4px solid var(--ai-color);">
                <h5 class="mb-4 text-white"><i class="fas fa-edit"></i> Clinical Input</h5>
                
                <form id="ai-form" action="<?= htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" enctype="multipart/form-data">
                    <div class="mb-3">
                        <label>Select Animal</label>
                        <select name="animal_id" class="form-select" required>
                            <option value="">-- Choose an animal --</option>
                            <?php foreach ($animals as $a): ?>
                                <option value="<?= e($a['animal_id']) ?>">Tag: <?= htmlspecialchars($a['tag_number']) ?> (<?= e(ucfirst($a['sex'])) ?>)</option>
                            <?php endforeach; ?>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label>Body Temperature (°C)</label>
                        <input type="number" step="0.1" name="temperature" class="form-control" placeholder="e.g. 39.5" required>
                    </div>

                    <div class="mb-3">
                        <label>Observed Symptoms</label>
                        <div class="row g-2">
                            <div class="col-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="sym1" name="symptoms[]" value="lameness">
                                    <label class="form-check-label text-white text-lowercase" for="sym1">Lameness</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="sym2" name="symptoms[]" value="lethargy">
                                    <label class="form-check-label text-white text-lowercase" for="sym2">Lethargy</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="sym3" name="symptoms[]" value="coughing">
                                    <label class="form-check-label text-white text-lowercase" for="sym3">Coughing</label>
                                </div>
                            </div>
                            <div class="col-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="sym4" name="symptoms[]" value="diarrhea">
                                    <label class="form-check-label text-white text-lowercase" for="sym4">Diarrhea</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="sym5" name="symptoms[]" value="anorexia">
                                    <label class="form-check-label text-white text-lowercase" for="sym5">Anorexia</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="sym6" name="symptoms[]" value="swelling">
                                    <label class="form-check-label text-white text-lowercase" for="sym6">Swelling</label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label>Photo (optional)</label>
                        <input type="file" name="animal_image" class="form-control" accept="image/jpeg,image/png,image/webp,image/gif">
                    </div>

                    <div class="mb-3">
                        <label>Free Observations</label>
                        <textarea name="observations" class="form-control" rows="3" placeholder="Describe behavior, lesions, timeline..."></textarea>
                    </div>

                    <button type="submit" class="btn btn-ai w-100 mt-2">
                        <i class="fas fa-magic"></i> Generate AI Analysis
                    </button>
                </form>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="custom-card h-100">
                <?php if ($ai_report): ?>
                    
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h4 class="m-0" style="color: var(--ai-color);"><i class="fas fa-laptop-medical"></i> Diagnostic Report</h4>
                        <span class="badge" style="background: rgba(255,255,255,0.1); border: 1px solid var(--border); padding: 8px 12px;">
                            Confidence: <?= htmlspecialchars($ai_report['confidence'] ?? 'Unknown') ?>
                        </span>
                    </div>

                    <div class="ai-result-box mb-4">
                        <h6 class="ai-text-purple"><i class="fas fa-file-medical-alt"></i> Clinical Summary</h6>
                        <p class="mb-0 text-white" style="font-size: 15px;"><?= htmlspecialchars($ai_report['summary'] ?? '') ?></p>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-md-6">
                            <h6 class="ai-text-purple"><i class="fas fa-microscope"></i> Probable Hypotheses</h6>
                            <div class="ai-result-box">
                                <?php if(isset($ai_report['hypotheses']) && is_array($ai_report['hypotheses'])): ?>
                                    <?php foreach ($ai_report['hypotheses'] as $hyp): ?>
                                        <div class="mb-3 last-mb-0">
                                            <div class="d-flex justify-content-between mb-1">
                                                <span class="text-white text-sm fw-bold"><?= htmlspecialchars($hyp['name']) ?></span>
                                                <span class="text-white-50 text-sm"><?= e($hyp['prob']) ?>%</span>
                                            </div>
                                            <div class="progress" style="height: 6px; background: rgba(0,0,0,0.5);">
                                                <div class="progress-bar" style="width: <?= e($hyp['prob']) ?>%; background: var(--ai-color);"></div>
                                            </div>
                                        </div>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <h6 class="ai-text-purple"><i class="fas fa-project-diagram"></i> Physiological Justification</h6>
                            <div class="ai-result-box h-100 text-white-50" style="font-size: 14px;">
                                <?= htmlspecialchars($ai_report['justification'] ?? '') ?>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4 mb-4">
                        <div class="col-md-6">
                            <h6 class="text-success"><i class="fas fa-check-circle"></i> Safe Immediate Actions</h6>
                            <ul class="text-white-50 mt-2 ps-3">
                                <?php if(isset($ai_report['safe_actions'])): ?>
                                    <?php foreach ($ai_report['safe_actions'] as $action): ?>
                                        <li class="mb-1"><?= htmlspecialchars($action) ?></li>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </ul>
                        </div>
                        
                        <div class="col-md-6">
                            <h6 class="text-danger"><i class="fas fa-exclamation-triangle"></i> Severe Warning Signs</h6>
                            <ul class="text-white-50 mt-2 ps-3">
                                <?php if(isset($ai_report['warnings'])): ?>
                                    <?php foreach ($ai_report['warnings'] as $warning): ?>
                                        <li class="mb-1"><?= htmlspecialchars($warning) ?></li>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            </ul>
                        </div>
                    </div>

                    <hr style="border-color: rgba(255,255,255,0.1);">

                    <div class="mt-3">
                        <h6 class="ai-text-purple"><i class="fas fa-book-medical"></i> Scientific References & Questions</h6>
                        <ul class="text-white-50 text-sm ps-3 mb-3">
                            <?php if(isset($ai_report['references'])): ?>
                                <?php foreach ($ai_report['references'] as $ref): ?>
                                    <li><?= htmlspecialchars($ref) ?></li>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </ul>
                        
                        <h6 class="ai-text-purple"><i class="fas fa-question-circle"></i> Questions for User</h6>
                        <ul class="text-white-50 text-sm ps-3">
                            <?php if(isset($ai_report['questions'])): ?>
                                <?php foreach ($ai_report['questions'] as $q): ?>
                                    <li><em><?= htmlspecialchars($q) ?></em></li>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </ul>
                    </div>

                <?php else: ?>
                    <div class="d-flex flex-column align-items-center justify-content-center h-100 text-center" style="opacity: 0.5;">
                        <i class="fas fa-robot fa-4x mb-3" style="color: var(--ai-color);"></i>
                        <h4 class="text-white">Awaiting Input</h4>
                        <p class="text-white-50">Fill out the clinical input form and click generate to see the AI analysis here.</p>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('ai-form').addEventListener('submit', function() {
        // Show the overlay as soon as the user clicks submit
        document.getElementById('loading-overlay').style.display = 'flex';
    });
</script>
</body>
</html>