<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'dbconnection.php'; // Your database connection

$data = json_decode(file_get_contents("php://input"), true);

// Check if email and OTP are provided
if (!isset($data['email']) || !isset($data['otp'])) {
    echo json_encode(["message" => "Email and OTP are required."]);
    exit();
}

$email = $data['email'];
$otp = $data['otp'];

// Prepare SQL statement to check OTP and timestamp
$stmt = $conn->prepare("SELECT otp, otp_created_at FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Check if OTP exists
    if ($user['otp'] !== null) {
        if ($user['otp'] == $otp) {
            // Check if OTP is within valid time frame (10 seconds)
            $otpCreatedAt = strtotime($user['otp_created_at']);
            $currentTime = time();

            // Debugging information
            error_log("OTP Created At: " . date('Y-m-d H:i:s', $otpCreatedAt));
            error_log("Current Time: " . date('Y-m-d H:i:s', $currentTime));
            error_log("Time Difference: " . ($currentTime - $otpCreatedAt));

            // Check for 10 seconds
            if (($currentTime - $otpCreatedAt) <= 10) { // 10 seconds
                // OTP verified successfully
                echo json_encode(["message" => "OTP verified successfully."]);
                
                // Optionally reset the OTP in the database
                $stmt = $conn->prepare("UPDATE users SET otp = NULL, otp_created_at = NULL WHERE email = ?");
                $stmt->bind_param("s", $email);
                $stmt->execute();
            } else {
                echo json_encode(["message" => "Expired OTP."]);
            }
        } else {
            echo json_encode(["message" => "Invalid OTP."]);
        }
    } else {
        echo json_encode(["message" => "No OTP generated for this email."]);
    }
} else {
    echo json_encode(["message" => "Email not found."]);
}

$stmt->close();
$conn->close();
