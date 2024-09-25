<?php
// Set headers for JSON response
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

// Start the session
session_start();

// Clear all session variables
$_SESSION = [];

// If you want to delete the session cookie as well
if (ini_get("session.use_cookies")) {
    $params = session_get_cookie_params();
    setcookie(session_name(), '', time() - 42000,
        $params["path"], $params["domain"],
        $params["secure"], $params["httponly"]
    );
}

// Destroy the session
session_destroy();

// Return a JSON response indicating success
echo json_encode([
    "success" => true,
    "message" => "Logged out successfully."
]);

// Always exit the script to prevent further output
exit();
?>
