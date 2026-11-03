<?php
// save_health_record.php - Backend API to save health data via AJAX
require_once 'config.php';

header('Content-Type: application/json');

// Security Check
require_login(true);

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $animal_id = !empty($_POST['animal_id']) ? (int) $_POST['animal_id'] : null;
    $item_id   = !empty($_POST['item_id']) ? (int) $_POST['item_id'] : NULL;
    $date      = $_POST['treatment_date'] ?? date('Y-m-d');
    $vet       = $_POST['vet_name'] ?? '';
    $notes     = $_POST['diagnosis'] ?? '';

    if (!$animal_id) {
        echo json_encode(['success' => false, 'message' => 'Animal ID is required']);
        exit;
    }

    // 1. Get Cost and Manage Stock
    $cost = 0;
    if ($item_id) {
        $q = $conn->prepare("SELECT cost_price, stock_quantity, type FROM medical_catalog WHERE item_id = ?");
        $q->bind_param("i", $item_id);
        $q->execute();
        $query = $q->get_result();
        if ($query && $row = $query->fetch_assoc()) {
            $cost = $row['cost_price'];
            
            // Deduct stock if it's a physical product (not a service)
            if ($row['type'] != 'service' && $row['stock_quantity'] > 0) {
                $u = $conn->prepare("UPDATE medical_catalog SET stock_quantity = stock_quantity - 1 WHERE item_id = ?");
                $u->bind_param("i", $item_id);
                $u->execute();
            }
        }
    }

    // 2. Insert Record
    $stmt = $conn->prepare("INSERT INTO health_records (animal_id, item_id, treatment_date, vet_name, diagnosis, cost) VALUES (?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("iisssd", $animal_id, $item_id, $date, $vet, $notes, $cost);

    if ($stmt->execute()) {
        echo json_encode(['success' => true, 'message' => 'Record saved successfully']);
    } else {
        error_log('[AgroFarm] save_health_record: ' . $conn->error);
        echo json_encode(['success' => false, 'message' => 'Could not save the record.']);
    }
    $stmt->close();
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
}
?>