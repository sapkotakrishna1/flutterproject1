<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Start output buffering
ob_start();

// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include database connection
include 'dbconnection.php';

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);

// Validate input
if (empty($data['email']) || empty($data['otp'])) {
    echo json_encode(["success" => false, "message" => "Email and OTP are required."]);
    exit();
}

$email = $data['email'];
$entered_otp = $data['otp'];

// Check user in the database
$stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();

    if (!empty($user['otp']) && $entered_otp == $user['otp']) {
        // Check if OTP is still valid
        $current_time = new DateTime();
        $otp_created_at = new DateTime($user['otp_created_at']);
        $interval = $current_time->diff($otp_created_at);
        $totalHours = ($interval->d * 24) + $interval->h;

        if ($totalHours < 24) {
            // OTP is valid
            echo json_encode([
                "success" => true,
                "message" => "OTP verified successfully. You are now logged in.",
                "redirect" => "home.php"
            ]);

            // Store the current timestamp and clear the OTP
            $stmt = $conn->prepare("UPDATE users SET otp = NULL, otp_created_at = NOW() WHERE email = ?");
            $stmt->bind_param("s", $email);
            $stmt->execute();

            // Optionally: Store the verification timestamp if needed
            // $stmt = $conn->prepare("UPDATE users SET otp_verified_at = NOW() WHERE email = ?");
            // $stmt->bind_param("s", $email);
            // $stmt->execute();

        } else {
            echo json_encode(["success" => false, "message" => "OTP has expired. Please request a new OTP."]);
        }
    } else {
        echo json_encode(["success" => false, "message" => "Invalid OTP."]);
    }
} else {
    echo json_encode(["success" => false, "message" => "User not found."]);
}

// Close the database connection
$conn->close();
?>
