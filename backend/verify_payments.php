<?php

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST GET');
// Allow specific headers (e.g., Content-Type, Authorization, etc.)
header("Access-Control-Allow-Headers: Content-Type, Authorization");

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

include 'dbconnection.php'; // Ensure your database connection is included

if ($_SERVER["REQUEST_METHOD"] == "GET" && isset($_GET['pidx']) && isset($_GET['purchase_order_id'])) {
    $pidx = $_GET['pidx']; // Khalti Payment ID (pidx)
    $purchase_order_id = $_GET['purchase_order_id']; // The purchase_order_id passed from Khalti

    // Step 1: Update purchase_order_id in the database (marking it pending)
    $stmt = $conn->prepare("UPDATE orders SET purchase_order_id = ? WHERE payment_status = 'Pending' LIMIT 1");
    $stmt->bind_param("s", $purchase_order_id);
    if (!$stmt->execute()) {
        echo "Error updating purchase_order_id in the database: " . $stmt->error;
        exit();
    }
    $stmt->close();

    // Step 2: Verify payment with Khalti API
    $khalti_secret_key = "c54d590299d843a788b6bd49ff6da91d"; // Replace with your Khalti secret key
    $data = ["pidx" => $pidx]; // Send pidx for payment verification
    $headers = [
        "Authorization: Key $khalti_secret_key",
        "Content-Type: application/json"
    ];

    $ch = curl_init("https://a.khalti.com/api/v2/epayment/lookup/"); // Khalti API URL for payment verification
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data)); // Send data as JSON
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers); // Set headers with the secret key

    $response = curl_exec($ch);
    curl_close($ch);

    // Decode the response
    $decoded_response = json_decode($response, true);

    if (isset($decoded_response['status']) && $decoded_response['status'] == 'Completed') {
        // Payment is successful, extract details
        $transaction_id = $decoded_response['transaction_id'];
        $amount = $decoded_response['total_amount'] / 100; // Convert from paisa to NPR

        // Step 3: Update payment status in the database (mark as 'Paid')
        $stmt = $conn->prepare("UPDATE orders SET payment_status = 'Paid', transaction_id = ? WHERE purchase_order_id = ?");
        $stmt->bind_param("ss", $transaction_id, $purchase_order_id);
        if ($stmt->execute()) {
            // Redirect to a success page after successful payment
            header("Location: success.php?purchase_order_id=" . urlencode($purchase_order_id));
            exit();
        } else {
            // Error updating payment status
            echo "Error updating payment status in the database: " . $stmt->error;
        }
        $stmt->close();
    } else {
        // If payment verification fails
        echo "Payment Verification Failed! Please try again.";
    }
} else {
    // If required parameters are missing
    echo "Invalid Request! Ensure parameters (pidx and purchase_order_id) are passed correctly.";
}
?>
