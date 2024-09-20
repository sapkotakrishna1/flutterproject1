<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");

// Example of logout logic
session_start();
if (session_destroy()) {
    echo json_encode(["success" => true, "message" => "Logged out successfully."]);
} else {
    echo json_encode(["success" => false, "message" => "Logout failed."]);
}
?>
