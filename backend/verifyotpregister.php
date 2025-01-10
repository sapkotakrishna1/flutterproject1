<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Content-Type: application/json; charset=UTF-8");

include 'dbconnection.php'; // Include your DB connection file
include 'send_email.php'; // Include send_email.php which contains sendConfirmationEmail function

ini_set('display_errors', 1); 
error_reporting(E_ALL);

// Handle OTP verification (POST)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $rawInput = file_get_contents("php://input");
    error_log("Raw Input: " . $rawInput);  // Log the raw input

    // Decode the JSON
    $data = json_decode($rawInput, true);

    if (!$data) {
        error_log("JSON Decode Error: " . json_last_error_msg());  // Log the specific error
        echo json_encode(['success' => false, 'message' => 'Invalid JSON input.']);
        exit;
    }

    // Validate that email, otp, username, location, password, gender, and contact fields are provided
    if (empty($data['email']) || empty($data['otp']) || empty($data['username']) || empty($data['location']) || empty($data['password']) || empty($data['gender']) || empty($data['contact'])) {
        echo json_encode(['success' => false, 'message' => 'Missing email, OTP, username, location, password, gender, or contact']);
        exit;
    }

    // Assign email, otp, username, location, password, gender, and contact from POST data
    $email = $data['email'];
    $otp = $data['otp'];
    $username = $data['username'];
    $location = $data['location'];
    $password = $data['password'];
    $gender = $data['gender'];  // New gender field
    $contact = $data['contact']; // New contact field
    $currentTime = date("Y-m-d H:i:s");

    // Query to get user data based on email, OTP, username, location from the users table
    $query = "SELECT id, email, otp, otp_timestamp, username, location, password, gender, contact FROM users WHERE email = ? AND otp = ? AND username = ? AND location = ?";

    if ($stmt = $conn->prepare($query)) {
        $stmt->bind_param("ssss", $email, $otp, $username, $location);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // Fetch user data from the result
            $user = $result->fetch_assoc();
            $otpTimestamp = $user['otp_timestamp'];

            // Check OTP expiration (valid for 10 minutes)
            $otpTimestamp = strtotime($otpTimestamp); // Convert OTP timestamp to Unix timestamp
            $currentTimestamp = strtotime($currentTime); // Convert current time to Unix timestamp
            $otpExpirationLimit = $otpTimestamp + 10 * 60; // Add 10 minutes in seconds

            if ($currentTimestamp > $otpExpirationLimit) {
                echo json_encode(['success' => false, 'message' => 'OTP has expired. Please request a new OTP.']);
                exit;
            }

            // OTP is valid, now insert data into the verifyusers table, including the password, gender, and contact
            $insertQuery = "INSERT INTO verifyusers (email, otp, otp_timestamp, username, location, password, gender, contact, is_verified) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)";
            if ($insertStmt = $conn->prepare($insertQuery)) {
                // Use the password directly as it is from the users table
                $userPassword = $user['password'];  // Directly use the password from the users table
                $insertStmt->bind_param("ssssssss", $email, $otp, $otpTimestamp, $username, $location, $userPassword, $gender, $contact);

                if ($insertStmt->execute()) {
                    // Send confirmation email after successful OTP verification
                    if (sendConfirmationEmail($email, $username)) {
                        // After successful insertion and email, delete the data from users table
                        $deleteQuery = "DELETE FROM users WHERE email = ? AND otp = ? AND username = ? AND location = ?";
                        if ($deleteStmt = $conn->prepare($deleteQuery)) {
                            $deleteStmt->bind_param("ssss", $email, $otp, $username, $location);
                            if (!$deleteStmt->execute()) {
                                error_log("Error deleting from users table: " . $conn->error);
                                echo json_encode(['success' => false, 'message' => 'OTP verified, but failed to delete from users table.']);
                                exit;
                            }
                        }

                        echo json_encode(['success' => true, 'message' => 'OTP verified successfully, confirmation email sent, and user record removed.']);
                    } else {
                        echo json_encode(['success' => false, 'message' => 'OTP verified successfully, but failed to send confirmation email.']);
                    }
                } else {
                    error_log("Error executing insert query: " . $conn->error);
                    echo json_encode(['success' => false, 'message' => 'Error executing insert query.']);
                }
            }
        } else {
            echo json_encode(['success' => false, 'message' => 'Invalid OTP or OTP already verified.']);
        }
    } else {
        error_log("Error preparing query: " . $conn->error);
        echo json_encode(['success' => false, 'message' => 'Error preparing query.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
}

$conn->close();
?>
