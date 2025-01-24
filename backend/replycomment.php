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



// Check database connection
if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]));
}

// Handle preflight requests for CORS (OPTIONS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);  // Respond OK for preflight
}

// Read the raw POST data (form data)
$data = json_decode(file_get_contents('php://input'), true); // Using JSON for better data structure

if (!empty($data['objects_id']) && !empty($data['comments_id']) && !empty($data['replyusername']) && !empty($data['replycomment']) && !empty($data['replyemail'])) {
    // Sanitize user inputs to prevent SQL injection and XSS
    $objectid = intval($data['objects_id']);  // Ensure it's an integer
    $commentid = intval($data['comments_id']);  // Ensure it's an integer
    $replyusername = htmlspecialchars($data['replyusername'], ENT_QUOTES, 'UTF-8'); // Sanitize string inputs
    $replycomment = htmlspecialchars($data['replycomment'], ENT_QUOTES, 'UTF-8'); // Sanitize string inputs
    $replyemail = htmlspecialchars($data['replyemail'], ENT_QUOTES, 'UTF-8'); // Sanitize string inputs

    // Validate the email format
    if (!filter_var($replyemail, FILTER_VALIDATE_EMAIL)) {
        echo json_encode(["status" => "error", "message" => "Invalid email format"]);
        exit();
    }

    // Prepare and execute the SQL query using prepared statements
    $stmt = $conn->prepare("INSERT INTO replycomments (objects_id, comments_id, replyusername, replycomment, replyemail) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("iisss", $objectid, $commentid, $replyusername, $replycomment, $replyemail); // "i" for integer, "s" for string

    // Execute the query and check if it was successful
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Reply added successfully"]);
    } else {
        // Log the SQL error and return a generic message
        error_log("SQL Error: " . $stmt->error);
        echo json_encode(["status" => "error", "message" => "Error: Unable to add reply."]);
    }

    // Close the prepared statement and the connection
    $stmt->close();
    $conn->close();
} else {
    // Return an error message if input is missing or invalid
    echo json_encode(["status" => "error", "message" => "Invalid or missing input data"]);
}
?>
