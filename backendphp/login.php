<?php
ob_start();
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

include 'dbconnection.php'; // Ensure this file correctly connects to your database
include_once 'otpemail.php';
 // Ensure this file contains the sendOtpEmail function

// Get POST data
$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['email']) || !isset($data['password'])) {
    echo json_encode(["message" => "Email and password are required."]);
    exit();
}

$email = $data['email'];
$password = $data['password'];

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(["message" => "Invalid email format."]);
    exit();
}

// Check user in the database
$stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        // Generate OTP
        $otp = rand(100000, 999999);

        // Update OTP in the database
        $stmt = $conn->prepare("UPDATE users SET otp = ?, otp_created_at = NOW() WHERE email = ?");
        $stmt->bind_param("is", $otp, $email);
        
        if ($stmt->execute()) {
            // Send the OTP email
            if (sendOtpEmail($email, $otp)) {
                echo json_encode(["message" => "OTP generated and sent successfully."]);
            } else {
                echo json_encode(["message" => "Failed to send OTP email."]);
            }
        } else {
            echo json_encode(["message" => "Failed to update OTP in the database."]);
        }
    } else {
        echo json_encode(["message" => "Invalid password."]);
    }
} else {
    echo json_encode(["message" => "User not found."]);
}

$stmt->close();
$conn->close();
ob_end_flush();
