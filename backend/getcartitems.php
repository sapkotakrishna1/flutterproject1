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

// Check if the 'email' parameter is provided in the URL
if (isset($_GET['email'])) {
    // Get the email from the query string
    $email = $_GET['email'];

    // Debugging: print the email to make sure it's correct
    error_log("Received email: " . $email);

    // Prepare the SQL query to fetch posts for the given email
    $sql = "SELECT id, product_id, product_name, price, username, image FROM cart WHERE email = ?";

    // Prepare the statement to prevent SQL injection
    if ($stmt = $conn->prepare($sql)) {
        // Bind the email parameter to the prepared statement
        $stmt->bind_param("s", $email); // "s" stands for string

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
            // If no posts found for the given email
            echo json_encode(["error" => "No posts found for this email"]);
        }

        // Close the statement
        $stmt->close();
    } else {
        // Error preparing the SQL statement
        error_log("Error preparing SQL statement: " . $conn->error);
        echo json_encode(["error" => "Failed to prepare SQL query"]);
    }
} else {
    // If no email provided, return an error
    echo json_encode(["error" => "Email parameter is missing"]);
}

// Close the database connection
$conn->close();
?>
