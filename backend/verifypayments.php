<?php
// Include the database connection file
include 'dbconnection.php';


header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type, Authorization');  


// Include the function to verify payment
include 'verify_payment.php';

// Check if the necessary data is available in the POST request
if (isset($_POST['pidx'], $_POST['postid'], $_POST['username'], $_POST['address'], $_POST['phone'])) {
    $pidx = $_POST['pidx'];
    $postid = $_POST['postid'];
    $username = $_POST['username'];
    $address = $_POST['address'];
    $phone = $_POST['phone'];

    // Call the function to verify the payment
    $payment_data = verify_payment($pidx);

    if ($payment_data) {
        // Prepare the data to store in the database
        $amount = $payment_data['amount'] / 100;  // Convert amount from paisa to rupees
        $payment_token = $payment_data['token'];
        $payment_status = 'Completed';
        $product_name = $payment_data['product_name'];  // Assuming you have product name in the response

        // Prepare and execute the SQL query to store the payment information
        $stmt = $conn->prepare("INSERT INTO payments (post_id, product_name, amount, phone_number, address, payment_token, payment_status, username) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
        $stmt->bind_param("ssdsdsss", $postid, $product_name, $amount, $phone, $address, $payment_token, $payment_status, $username);

        if ($stmt->execute()) {
            echo 'Payment successful. Thank you for your purchase!';
        } else {
            echo 'Error: ' . $stmt->error;
        }

        // Close the prepared statement
        $stmt->close();
    } else {
        echo 'Payment verification failed. Please try again.';
    }

    // Close the database connection
    $conn->close();
}
?>
