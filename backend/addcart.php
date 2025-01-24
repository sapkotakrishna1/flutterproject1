<?php
// Include the database connection file
include 'dbconnection.php';

// Enable CORS for all origins
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');

// Assuming you are receiving POST data
$product_id = $_POST['product_id'];
$product_name = $_POST['product_name'];
$price = $_POST['price'];
$username = $_POST['username'];
$email = $_POST['email'];
$image = $_POST['image'];

// Check if the product already exists in the cart for this user
$sql_check = "SELECT * FROM cart WHERE  product_id='$product_id'";
$result = $conn->query($sql_check);

if ($result->num_rows > 0) {
    // If already in the cart, you might want to update the quantity instead
    echo json_encode(['status' => 'error', 'message' => 'Product already in cart']);
    exit();
}

// Insert the product into the cart table
$sql = "INSERT INTO cart (product_id, product_name, price, username, email,image) 
        VALUES ('$product_id', '$product_name', '$price', '$username', '$email', '$image')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(['status' => 'success', 'message' => 'Product added to cart']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to add product to cart']);
}

// Close the database connection
$conn->close();
?>
