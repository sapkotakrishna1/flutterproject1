<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'dbconnection.php'; // Include your DB connection file
include 'otpemail.php'; // Include the email sending script

// Enable error reporting for debugging
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Step 1: Handle the registration request (POST)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if the data is in JSON format or form-encoded
    $data = ($_SERVER['CONTENT_TYPE'] === 'application/json')
        ? json_decode(file_get_contents("php://input"), true)
        : $_POST;

    // Validate required fields
    if (!empty($data['username']) && !empty($data['email']) && !empty($data['location']) && !empty($data['gender']) && !empty($data['contact']) && !empty($data['password'])) {
        $username = $data['username'];
        $email = $data['email'];
        $location = $data['location'];  // Changed from 'faculty' to 'location'
        $gender = $data['gender'];
        $contact = $data['contact'];
        $password = password_hash($data['password'], PASSWORD_BCRYPT); // Secure password hash

        // Check if the email already exists
        $stmt = $conn->prepare("SELECT * FROM users WHERE email = ?");
        if (!$stmt) {
            echo json_encode(["message" => "Failed to prepare statement for email check", "error" => $conn->error]);
            exit();
        }

        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // Email already exists
            echo json_encode(["message" => "This email is already associated with an account."]);
        } else {
            // Step 2: Generate OTP first
            $otp = rand(100000, 999999); // Generate a 6-digit OTP

            // Insert user data into the database but don't activate them yet
            $stmt = $conn->prepare("INSERT INTO users (username, email, location, gender, contact, password, otp, otp_timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");
            if (!$stmt) {
                echo json_encode(["message" => "Failed to prepare statement for user creation", "error" => $conn->error]);
                exit();
            }

            // Bind user data to the prepared statement, including the OTP and timestamp
            $stmt->bind_param("sssssss", $username, $email, $location, $gender, $contact, $password, $otp);

            if ($stmt->execute()) {
                // Step 3: Send OTP to user's email
                $subject = "Your OTP for Registration";
                $message = "Your OTP for registration is: $otp. It will expire in 5 minutes.";

                // Use the sendOtpEmail function from otpemail.php to send the email
                if (sendOtpEmail($email, $otp)) {
                    echo json_encode([
                        "status" => "success", 
                        "message" => "User created successfully, OTP sent to email.",
                        "data" => [
                            "username" => $username,
                            "email" => $email,
                            "location" => $location,
                            "gender" => $gender,
                            "contact" => $contact
                        ]
                    ]);
                } else {
                    echo json_encode(["status" => "error", "message" => "User created, but failed to send OTP email."]);
                }
            } else {
                echo json_encode(["status" => "error", "message" => "User creation failed", "error" => $stmt->error]);
            }

            $stmt->close();
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Invalid input, all fields are required."]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Method not allowed"]);
}

$conn->close();
?>
