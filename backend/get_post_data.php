<?php
include 'dbconnection.php'; // Make sure to include your database connection file

// Set content type to JSON
header('Content-Type: application/json');

// Allow all origins (for development purposes)
header('Access-Control-Allow-Origin: *');

// Allow specific methods (GET, POST, etc.)
header('Access-Control-Allow-Methods: GET');

// Allow specific headers (e.g., Content-Type, Authorization)
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Allow credentials (if needed for authentication)
header('Access-Control-Allow-Credentials: true');

// If the 'username' parameter is NOT provided, fetch all posts
$sql = "SELECT id, name, description, price, age, username, images, created_at, email FROM objects";

// Prepare statement to prevent SQL injection
if ($stmt = $conn->prepare($sql)) {
    // Execute query
    $stmt->execute();

    // Store the result
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Initialize an array to hold all the post data
        $post_data = array();

        // Fetch the data and push it to the array
        while ($row = $result->fetch_assoc()) {
            $post_data[] = $row;
        }

        // Send the data as a JSON response
        echo json_encode($post_data);
    } else {
        // If no posts found
        echo json_encode(["error" => "No posts found"]);
    }

    // Close the statement
    $stmt->close();
} else {
    // Error preparing the SQL statement
    echo json_encode(["error" => "Failed to prepare SQL query"]);
}

// Close the database connection
$conn->close();
?>
