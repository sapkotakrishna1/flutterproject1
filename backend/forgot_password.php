<?php
session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'dbconnection.php'; // Assuming this connects to the database

// Retrieve JSON input
$json_input = file_get_contents('php://input');
$data = json_decode($json_input);

// Validate JSON input
if (json_last_error() !== JSON_ERROR_NONE) {
    echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
    exit();
}

// Check if email is provided
$email = $data->email ?? null;
if (empty($email)) {
    echo json_encode(['success' => false, 'message' => 'Email is required']);
    exit();
}

// Check if the email exists in the database
$sql = "SELECT id, email FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(['success' => false, 'message' => 'SQL preparation failed.']);
    exit();
}
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // Email exists, generate a reset token
    $user = $result->fetch_assoc();
    $userId = $user['id'];

    // Generate a unique token and expiration time (e.g., 1 hour from now)
    $token = bin2hex(random_bytes(32)); // Generate a secure random token
    $expires = date("Y-m-d H:i:s", strtotime("+1 hour"));

    // Store the token and expiration time in the database
    $sql = "INSERT INTO password_resets (user_id, token, expires) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(['success' => false, 'message' => 'SQL preparation failed.']);
        exit();
    }
    $stmt->bind_param('iss', $userId, $token, $expires);
    $stmt->execute();

    // Send email with the password reset link
    $resetLink = "http://yourdomain.com/reset_password.php?token=" . $token;

    // Prepare the email
    $subject = "Password Reset Request";
    $message = "Hello, \n\nWe received a request to reset your password. Please click the link below to reset your password: \n\n" . $resetLink;
    $headers = "From: no-reply@yourdomain.com\r\n";
    
    if (mail($email, $subject, $message, $headers)) {
        echo json_encode(['success' => true, 'message' => 'Password reset link sent to your email']);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to send email']);
    }
} else {
    // Email does not exist
    echo json_encode(['success' => false, 'message' => 'Email not found']);
}

// Close the statement and connection
$stmt->close();
$conn->close();
?>
