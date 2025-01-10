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

// Read the incoming JSON data
$json_input = file_get_contents('php://input');
error_log("Incoming JSON: " . $json_input);

$data = json_decode($json_input);

// Check for JSON decode errors
if (json_last_error() !== JSON_ERROR_NONE) {
    error_log('JSON decode error: ' . json_last_error_msg());
    echo json_encode(['success' => false, 'message' => 'Invalid JSON']);
    exit();
}

// Extract email and password from incoming data
$email = $data->email ?? null;
$password = $data->password ?? null;

// Ensure email and password are provided
if (empty($email) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Email and password are required.']);
    exit();
}

// First, check in the `verifyusers` table (hashed password)
$sql_user = "SELECT username, password FROM verifyusers WHERE email = ?";
$stmt_user = $conn->prepare($sql_user);
if (!$stmt_user) {
    error_log('SQL preparation failed for user table: ' . $conn->error);
    echo json_encode(['success' => false, 'message' => 'SQL preparation failed for user table.']);
    exit();
}

$stmt_user->bind_param('s', $email);
$stmt_user->execute();
$result_user = $stmt_user->get_result();

// If user found in `verifyusers`, check password
if ($result_user->num_rows > 0) {
    $user = $result_user->fetch_assoc();
    if (password_verify($password, $user['password'])) {
        $_SESSION['email'] = $email;
        $username = $user['username'];

        // Redirect to home.php for regular users
        echo json_encode([
            'success' => true,
            'message' => 'Login successful',
            'username' => $username,
            'redirect' => 'home.php' // Regular user redirect
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
    }
    $stmt_user->close();
} else {
    // If not found in `verifyusers`, check in `admindata` table (plain password)
    $sql_admin = "SELECT username, password FROM admindata WHERE email = ?";
    $stmt_admin = $conn->prepare($sql_admin);
    if (!$stmt_admin) {
        error_log('SQL preparation failed for admin table: ' . $conn->error);
        echo json_encode(['success' => false, 'message' => 'SQL preparation failed for admin table.']);
        exit();
    }

    $stmt_admin->bind_param('s', $email);
    $stmt_admin->execute();
    $result_admin = $stmt_admin->get_result();

    // If email is found in `admindata`, check the plain password
    if ($result_admin->num_rows > 0) {
        $admin = $result_admin->fetch_assoc();
        if ($password === $admin['password']) {
            $_SESSION['email'] = $email;
            $username = $admin['username'];

            // Redirect to admin.php for admin users
            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'username' => $username,
                'redirect' => 'admin.php' // Admin user redirect
            ]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
        }
        $stmt_admin->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid credentials']);
    }
}

// Close database connection
$conn->close();
?>
