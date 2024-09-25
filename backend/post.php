<?php
header('Content-Type: application/json'); // Set the content type to JSON
header('Access-Control-Allow-Origin: *'); // Allow all origins
header('Access-Control-Allow-Methods: GET, POST, OPTIONS'); // Allow specific methods
header('Access-Control-Allow-Headers: Content-Type'); // Allow specific headers

// Include your database connection file
include 'dbconnection.php'; // Ensure the path is correct

// Check if the connection was successful
if (!$conn) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

// Fetch objects
$sql = "SELECT username, name, description, image, price, age, created_at FROM objects";
$result = $conn->query($sql);

$objects = [];

if ($result) { // Check if the query was successful
    if ($result->num_rows > 0) {
        // Output data of each row
        while ($row = $result->fetch_assoc()) {
            $objects[] = $row;
        }
    } else {
        echo json_encode([]); // Return an empty array if no records found
        exit;
    }
} else {
    // Handle query error
    http_response_code(500); // Set response code to 500 (Internal Server Error)
    echo json_encode(['error' => 'Database query failed']);
    exit;
}

// Return JSON response
echo json_encode($objects);

// Close the connection
$conn->close();
?>
