<?php
// Allow the request to come from any origin
header('Access-Control-Allow-Origin: *'); // Change * to a specific domain for production

// Set the response content type to JSON
header('Content-Type: application/json');

// Enable error reporting (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Include your database connection file
include 'dbconnection.php';

// Ensure both 'id' and 'username' are provided in the POST request
if (isset($_POST['id']) && isset($_POST['username'])) {
    $id = $_POST['id'];  // This is the unique ID of the post to be deleted
    $username = $_POST['username'];  // This is the username of the person trying to delete the post

    // Prepare the SQL query to check if the post exists and the username matches
    $sql = "SELECT * FROM objects WHERE id = ? AND username = ?";

    // Prepare the statement
    if ($stmt = $conn->prepare($sql)) {
        // Bind the parameters
        $stmt->bind_param("is", $id, $username); // 'i' for integer, 's' for string

        // Execute the statement
        $stmt->execute();
        $result = $stmt->get_result();

        // Check if the post exists and belongs to the user
        if ($result->num_rows > 0) {
            // The post exists and belongs to the user, now delete it
            $delete_sql = "DELETE FROM objects WHERE id = ? AND username = ?";
            
            if ($delete_stmt = $conn->prepare($delete_sql)) {
                // Bind the parameters for deletion
                $delete_stmt->bind_param("is", $id, $username);

                // Execute the delete statement
                if ($delete_stmt->execute()) {
                    // If the delete is successful, return a success message as JSON
                    echo json_encode(["status" => "success", "message" => "Post deleted successfully"]);
                } else {
                    // If there's an error during the deletion
                    echo json_encode(["status" => "error", "message" => "Error: " . $conn->error]);
                }
            } else {
                // If the delete SQL statement fails to prepare
                echo json_encode(["status" => "error", "message" => "Error: Failed to prepare delete query"]);
            }
        } else {
            // If the post doesn't exist or doesn't belong to the user
            echo json_encode(["status" => "error", "message" => "Error: Post not found or you don't have permission to delete this post"]);
        }
    } else {
        // If the select query fails to prepare
        echo json_encode(["status" => "error", "message" => "Error: Failed to prepare query"]);
    }

    // Close the statement
    $stmt->close();
} else {
    // If 'id' or 'username' is missing in the POST request
    echo json_encode(["status" => "error", "message" => "Error: Missing parameters (id or username)"]);
}

// Close the database connection
$conn->close();
?>
