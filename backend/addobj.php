<?php
// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Start the session
session_start();

// Set headers for JSON response
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Include database connection
include 'dbconnection.php';

// Function to get username from the session
function getUsername($conn) {
    if (isset($_SESSION['email'])) {
        $email = $_SESSION['email'];

        $stmt = $conn->prepare("SELECT username FROM users WHERE email = ?");
        if ($stmt) {
            $stmt->bind_param("s", $email);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result && $result->num_rows === 1) {
                $username = $result->fetch_assoc()['username'];
                $stmt->close();
                return $username;
            } else {
                error_log('No user found for email: ' . $email);
            }
            $stmt->close();
        } else {
            error_log('Prepared statement failed: ' . $conn->error);
        }
    } else {
        error_log('No email found in session.');
    }
    return null; // User not found
}

// Check request method
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check database connection
    if ($conn->connect_error) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Database connection failed.']);
        exit();
    }

    // Get the username
    $username = getUsername($conn);
    if (!$username) {
        http_response_code(401);
        echo json_encode(['status' => 'error', 'message' => 'Authentication required. Please log in to continue.']);
        exit();
    }

    // Check if files are uploaded
    if (!isset($_FILES['images']) || count($_FILES['images']['error']) === 0) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'No files uploaded.']);
        exit();
    }

    // Sanitize other form data
    $name = htmlspecialchars(trim($_POST['name'] ?? ''), ENT_QUOTES);
    $description = htmlspecialchars(trim($_POST['description'] ?? ''), ENT_QUOTES);
    $price = (float) ($_POST['price'] ?? 0);
    $age = (int) ($_POST['age'] ?? 0);

    // Define the upload directory
    $targetDirectory = 'uploads/';
    if (!is_dir($targetDirectory) && !mkdir($targetDirectory, 0755, true)) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to create upload directory.']);
        exit();
    }

    $responses = [];
    $stmt = $conn->prepare("INSERT INTO objects (image, name, description, price, age, username) VALUES (?, ?, ?, ?, ?, ?)");
    if (!$stmt) {
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Database statement preparation failed.']);
        exit();
    }

    // Loop through each uploaded file
    foreach ($_FILES['images']['name'] as $index => $filename) {
        if ($_FILES['images']['error'][$index] === UPLOAD_ERR_OK) {
            // Validate file type and size
            $fileExtension = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
            $allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
            if (!in_array($fileExtension, $allowedExtensions)) {
                $responses[] = ['status' => 'error', 'message' => 'Invalid file type for: ' . $filename];
                continue;
            }

            // Check file size (limit to 2MB)
            if ($_FILES['images']['size'][$index] > 2 * 1024 * 1024) {
                $responses[] = ['status' => 'error', 'message' => 'File too large: ' . $filename];
                continue;
            }

            // Set the target file path with a unique filename
            $targetFile = $targetDirectory . uniqid() . "_$index.$fileExtension";

            // Move the uploaded file to the target directory
            if (move_uploaded_file($_FILES['images']['tmp_name'][$index], $targetFile)) {
                // Bind parameters and execute
                $stmt->bind_param("ssdiss", $targetFile, $name, $description, $price, $age, $username);
                if ($stmt->execute()) {
                    $responses[] = ['status' => 'success', 'message' => 'Uploaded: ' . $filename];
                } else {
                    $responses[] = ['status' => 'error', 'message' => 'Database insert failed for: ' . $filename];
                    error_log('Database insert error: ' . $stmt->error);
                }
            } else {
                $responses[] = ['status' => 'error', 'message' => 'Failed to upload: ' . $filename];
            }
        } else {
            $responses[] = ['status' => 'error', 'message' => 'Error with file ' . $filename . ': ' . $_FILES['images']['error'][$index]];
        }
    }

    // Close the prepared statement and database connection
    $stmt->close();
    $conn->close();

    // Return all responses
    echo json_encode($responses);
} else {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method.']);
}
?>
