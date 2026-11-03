<?php
// API Historic helth JSON
require_once 'config.php';
require_login(true);
header('Content-Type: application/json');

if(isset($_GET['animal_id'])) {
    $id = intval($_GET['animal_id']);
    
    $stmt = $conn->prepare("SELECT h.*, m.item_name 
            FROM health_records h 
            LEFT JOIN medical_catalog m ON h.item_id = m.item_id 
            WHERE h.animal_id = ? 
            ORDER BY h.treatment_date DESC LIMIT 10");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $data = [];
    while($row = $result->fetch_assoc()) {
        // Formata data para ficar bonito
        $row['treatment_date'] = date('d/m/Y', strtotime($row['treatment_date']));
        $data[] = $row;
    }
    
    echo json_encode($data);
}
?>