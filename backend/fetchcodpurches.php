<?php
// Include the database connection
include 'dbconnection.php';

// Set content type to JSON
header('Content-Type: application/json');

// Allow all origins (use with caution, only for development)
// In production, consider restricting this to specific domains
header('Access-Control-Allow-Origin: *');

// Allow specific methods (GET, POST, etc.)
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');

// Allow specific headers (e.g., Content-Type, Authorization)
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Allow credentials (if needed for authentication/cookies)
header('Access-Control-Allow-Credentials: true');

// Check if the 'postid' is passed in the URL query parameters
if (isset($_GET['postid']) && is_numeric($_GET['postid'])) {
    $postid = $_GET['postid']; // Get the postid from query parameters

    // Sanitize the postid to prevent SQL injection
    $postid = $conn->real_escape_string($postid);

    // SQL query to fetch the full record based on the postid
    $sql = "SELECT id, postid, price, product_name, address, phone, status, created_at FROM codpurchases WHERE postid = '$postid'"; 

    // Execute the query
    $result = $conn->query($sql);

    // Check if the query was successful
    if ($result) {
        // Check if any data was returned
        if ($result->num_rows > 0) {
            // Fetch the first row of data
            $row = $result->fetch_assoc();
            
            // Return the full record as a JSON response
            echo json_encode([
                "status" => "success",
                "data" => $row // Send all columns in the record
            ]);
        } else {
            // If no data is found, return an error message
            echo json_encode(["status" => "error", "message" => "No purchase status found"]);
        }
    } else {
        // If the query fails, return an error message with query info
        echo json_encode(["status" => "error", "message" => "Query failed: " . $conn->error]);
    }
} else {
    // If 'postid' is not passed in the request, return an error message
    echo json_encode(["status" => "error", "message" => "'postid' parameter is missing or invalid"]);
}

// Close the database connection
$conn->close();
?>


