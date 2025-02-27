<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
// Allow specific headers (e.g., Content-Type, Authorization, etc.)
header("Access-Control-Allow-Headers: Content-Type, Authorization");

include 'dbconnection.php'; // Assuming this connects to the database

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Get data from the POST request
$data = json_decode(file_get_contents("php://input"), true);

// Validate data
if (isset($data['postid']) && isset($data['price']) && isset($data['product_name']) && isset($data['address']) && isset($data['phone'])) {
  
  // Prepare the SQL query to insert the purchase
  $stmt = $conn->prepare("INSERT INTO codpurchases (postid, price, product_name, address, phone, status) VALUES (?, ?, ?, ?, ?, ?)");

  $status = 'completed'; // Default status is 'pending', you can change it to 'completed' if needed
  $stmt->bind_param("sdssss", $data['postid'], $data['price'], $data['product_name'], $data['address'], $data['phone'], $status);

  // Execute the query and check if the insertion was successful
  if ($stmt->execute()) {
    // Return success response
    echo json_encode(["success" => true, "message" => "Purchase confirmed with Cash on Delivery!"]);
  } else {
    // Return failure response
    echo json_encode(["success" => false, "message" => "Failed to confirm purchase"]);
  }

  $stmt->close();
} else {
  // Return error response if data is missing
  echo json_encode(["success" => false, "message" => "Missing required data"]);
}

$conn->close();
?>
