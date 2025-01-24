<?php
// Allow the request to come from any origin
header('Access-Control-Allow-Origin: *'); // This allows cross-origin requests

// Set the response content type to JSON
header('Content-Type: application/json');

// Include your database connection file
include 'dbconnection.php';

// Prepare the SQL query to fetch data from the database
$sql = "SELECT id, name, description, price, age, username, images, created_at , email FROM objects";
$result = $conn->query($sql);

$objects = [];

// If the query is successful, fetch the data
if ($result && $result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        // Directly use the 'images' field without changing its content
        $images = $row['images'] ? explode(",", $row['images']) : []; // Split the Base64 string into an array

        // Assign the images array back to the row
        $row['images'] = $images;

        // Add the row to the objects array
        $objects[] = $row;
    }

    // Return the objects data as JSON
    echo json_encode($objects);
} else {
    // If no records are found, return an empty array
    echo json_encode([]);
}

// Close the database connection
$conn->close();
?>
