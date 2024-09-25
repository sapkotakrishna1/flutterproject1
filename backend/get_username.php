<?php
session_start();
include 'dbconnection.php';

// Check if the user is logged in
if (isset($_SESSION['email'])) {
    $email = $_SESSION['email'];
    $stmt = $conn->prepare("SELECT username FROM users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $user = $result->fetch_assoc();
        echo json_encode(['username' => $user['username']]);
    } else {
        echo json_encode(['username' => null]);
    }
} else {
    echo json_encode(['username' => null]);
}

$stmt->close();
$conn->close();
?>
