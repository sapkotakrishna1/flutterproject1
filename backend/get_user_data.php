<?php
include 'dbconnection.php';

// Set content type to JSON
header('Content-Type: application/json');

// Allow all origins (use with caution, only for development)
header('Access-Control-Allow-Origin: *');

// Allow specific methods (GET, POST, etc.)
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');

// Allow specific headers (e.g., Content-Type, Authorization)
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Allow credentials (if you need authentication/cookies, etc.)
header('Access-Control-Allow-Credentials: true');


// Fetch user data from the database
$sql = "SELECT id, username, email, location, gender, contact FROM verifyusers";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $user_data = array(); // Initialize an empty array to hold all user data
    while ($row = $result->fetch_assoc()) {
        $user_data[] = $row; // Add each row of data to the array
    }
    echo json_encode($user_data); // Return all user data as a JSON array
} else {
    echo json_encode(["error" => "User not found"]); // Return error if no data
}

$conn->close();
?>
