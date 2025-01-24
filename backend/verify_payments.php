<?php
// verify_payment.php

// Enable CORS for all origins
header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');

// Function to verify the payment using Khalti's API
function verify_payment($token, $amount) {
    // Your Khalti secret key (replace with your actual key)
    $secret_key = "97eae73a88714ba0bf8e85c941606bb1";  // Replace this with your Khalti secret key

    // API endpoint for verifying payment
    $url = "https://khalti.com/api/v2/payment/verify/";

    // Prepare data for the API request (Khalti requires token and amount)
    $data = [
        'token' => $token,  // Payment token received from the client
        'amount' => $amount  // The expected amount in paisa (adjust as needed)
    ];

    // Initialize cURL session
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);  // Return response instead of outputting
    curl_setopt($ch, CURLOPT_POST, true);            // Set request type to POST
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($data));  // Send POST data
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Key $secret_key",  // Add the authorization header with your Khalti secret key
        "Content-Type: application/x-www-form-urlencoded"  // Ensure correct content type for POST data
    ]);

    // Execute the cURL request
    $response = curl_exec($ch);

    // Check for cURL errors
    if (curl_errno($ch)) {
        // If cURL fails, return null and output error message
        echo json_encode(['error' => 'Curl error: ' . curl_error($ch)]);
        curl_close($ch);
        return null;
    }

    // Check the HTTP response code
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    if ($http_code != 200) {
        // If the response code is not 200 (OK), return an error message
        echo json_encode(['error' => 'HTTP Error: ' . $http_code, 'response' => $response]);
        curl_close($ch);
        return null;
    }

    // Close the cURL session
    curl_close($ch);

    // Decode the JSON response from Khalti API
    $payment_data = json_decode($response, true);

    // Log the response for debugging purposes
    error_log("Payment Data: " . json_encode($payment_data));

    // Check if the response contains the expected 'idx' field (indicating success)
    if (isset($payment_data['idx'])) {
        echo json_encode(['success' => true, 'payment_data' => $payment_data]);
        return $payment_data;  // Return the payment data if successful
    } else {
        // Return null if payment verification failed, and log the response
        echo json_encode(['error' => 'Payment verification failed', 'details' => $payment_data]);
        return null;
    }
}
?>
