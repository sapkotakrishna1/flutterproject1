<?php
// Include the database connection file
include 'dbconnection.php';
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);


// Enable CORS for all origins
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');


// Enable MySQLi error reporting
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

// Check the connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Read the raw JSON data from the request body
$data = json_decode(file_get_contents('php://input'), true);

// Check if the required fields are provided
if (isset($data['comment']) && isset($data['username']) && isset($data['email']) && isset($data['objects_id'])) {
    $comment = $data['comment'];
    $username = $data['username'];
    $email = $data['email'];
    $objects_id = (int) $data['objects_id']; // Ensure objects_id is an integer

    // Validate objects_id (ensure it's positive)
    if ($objects_id <= 0) {
        echo json_encode(["status" => "error", "message" => "Invalid objects_id"]);
        exit;
    }

    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(["status" => "error", "message" => "Invalid email format"]);
        exit;
    }

    // Prepare and execute the SQL query using prepared statements
    $stmt = $conn->prepare("INSERT INTO comments (objects_id, comment, username, email) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("isss", $objects_id, $comment, $username, $email);

    // Execute the query and check if it was successful
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Comment added successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error: " . $stmt->error]);
    }

    // Close the prepared statement and the connection
    $stmt->close();
    $conn->close();
} else {
    // Missing input data
    echo json_encode(["status" => "error", "message" => "Invalid input data"]);
}
?>
