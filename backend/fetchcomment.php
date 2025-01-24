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

    // SQL query to fetch comments where objects_id matches the provided postid
    $sql = "SELECT id, objects_id, username, comment, email, created_at FROM comments WHERE objects_id = '$postid'"; 

    // Execute the query
    $result = $conn->query($sql);

    // Check if the query was successful
    if ($result) {
        // Check if any data was returned
        if ($result->num_rows > 0) {
            $user_data = array(); // Initialize an empty array to hold all user data
            
            // Fetch and add each row of data to the array
            while ($row = $result->fetch_assoc()) {
                $user_data[] = $row; // Add each row of data (id, username, comment, email, created_at)
            }
            
            // Return all user data as a JSON array
            echo json_encode(["status" => "success", "comments" => $user_data]);
        } else {
            // If no data is found, return an error message
            echo json_encode(["status" => "error", "message" => "No comments found"]);
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
