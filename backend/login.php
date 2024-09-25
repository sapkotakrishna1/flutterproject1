<?php
session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'dbconnection.php';
include 'otpemail.php'; // Include the OTP email sending functionality

$json_input = file_get_contents('php://input');
error_log("Incoming JSON: " . $json_input);

$data = json_decode($json_input);

if (json_last_error() !== JSON_ERROR_NONE) {
    error_log('JSON decode error: ' . json_last_error_msg());
    echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
    exit();
}

$email = $data->email ?? null;
$password = $data->password ?? null;

if (empty($email) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Email and password are required.']);
    exit();
}

$sql = "SELECT username, password, otp_created_at FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    error_log('SQL preparation failed: ' . $conn->error);
    echo json_encode(['success' => false, 'message' => 'SQL preparation failed.']);
    exit();
}

$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
    exit();
}

$user = $result->fetch_assoc();

if (password_verify($password, $user['password'])) {
    $_SESSION['email'] = $email;
    $username = $user['username'];

    // Check if OTP was created within the last 24 hours
    if (!empty($user['otp_created_at'])) {
        $otp_created_at = new DateTime($user['otp_created_at']);
        $current_time = new DateTime();
        $interval = $current_time->diff($otp_created_at);
        $totalHours = ($interval->d * 24) + $interval->h;

        error_log("Total hours since last OTP: " . $totalHours);

        if ($totalHours < 24) {
            // OTP exists and is within 24 hours, redirect to home
            echo json_encode(['success' => true, 'redirect' => 'home.php', 'username' => $user['username']]);
            exit();
        }
    }

    // Generate and send a new OTP
    $otp = rand(100000, 999999);
    if (sendOtpEmail($email, $otp)) {
        $_SESSION['otp'] = $otp;

        // Update the database with the new OTP and creation time
        $stmt = $conn->prepare("UPDATE users SET otp = ?, otp_created_at = NOW() WHERE email = ?");
        if ($stmt) {
            $stmt->bind_param("is", $otp, $email);
            if ($stmt->execute()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'OTP generated and sent successfully. Please enter the OTP.',
                    'otp_required' => true
                ]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Failed to update OTP in the database.']);
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Database query preparation failed.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to send OTP email.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
}

$stmt->close();
$conn->close();
?>
