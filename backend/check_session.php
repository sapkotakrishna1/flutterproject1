<?php
session_start();
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');
include 'login.php';

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Function to send a JSON response
function sendResponse($success, $message = '', $data = []) {
    echo json_encode(array_merge(['success' => $success, 'message' => $message], $data));
    exit;
}

// Check if the session is active
if (session_status() !== PHP_SESSION_ACTIVE) {
    sendResponse(false, 'Session not active.');
}

// Debugging: Output current session variables
error_log('Current session variables: ' . print_r($_SESSION, true));

// Check if the user email is set in the session
if (!isset($_SESSION['email'])) {
    error_log('Email session variable is not set.'); // Log this for debugging
    sendResponse(false, 'User is not logged in.');
}

// Include your database connection file
require 'dbconnection.php'; 

if ($conn->connect_error) {
    sendResponse(false, 'Database connection failed: ' . $conn->connect_error);
}

// Prepare and execute the statement to check if the email exists
$email = $_SESSION['email'];
$stmt = $conn->prepare("SELECT username FROM users WHERE email = ?");
if (!$stmt) {
    sendResponse(false, 'Database statement preparation failed: ' . $conn->error);
}

$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result(); // Store the result to check the number of rows

// Check if the email exists
if ($stmt->num_rows === 0) {
    error_log("User with email $email not found in database."); // Log this for debugging
    sendResponse(false, 'User email not found in database.');
}

// Fetch user information
$stmt->bind_result($username); // Assuming you want the username
$stmt->fetch();
$stmt->close();

// If email is verified, return user info
sendResponse(true, '', [
    'user' => [
        'email' => $_SESSION['email'], // Include email
        'username' => $username, // Include username
    ],
]);

// Close the database connection
$conn->close();
?>
