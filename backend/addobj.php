<?php
// Allow the request to come from any origin
header('Access-Control-Allow-Origin: *'); // This allows cross-origin requests

// Set the response content type to JSON
header('Content-Type: application/json');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Include your database connection file
include 'dbconnection.php';

// Get form data from the POST request
$name = $_POST['name'];
$description = $_POST['description'];
$price = $_POST['price'];
$age = $_POST['age'];
$username = $_POST['username'];
$email = $_POST['email'];

// Prepare images array
$images = isset($_POST['images']) ? $_POST['images'] : [];

// Convert array of base64 images to a single string or store each one separately
$images_str = implode(",", $images); // Concatenate base64 strings into one (comma-separated)

// Prepare the SQL query to insert the data into the database
$sql = "INSERT INTO objects (name, description, price, age, username, images, email)
        VALUES ('$name', '$description', '$price', '$age','$username', '$images_str','$email')";

// Execute the query
if ($conn->query($sql) === TRUE) {
    // If the insert is successful, return a success message as JSON
    echo json_encode(["status" => "success", "message" => "Item added successfully"]);
} else {
    // If there's an error, return the error message as JSON
    echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
}

// Close the database connection
$conn->close();
?>
