<?php
// Include the database connection
include 'dbconnection.php';

// Set content type to JSON
header('Content-Type: application/json');

// Allow all origins (use with caution, only for development)
// In production, consider restricting this to specific domains
header('Access-Control-Allow-Origin: *');

// Allow specific methods (GET, POST, etc.)
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');

// Allow specific headers (e.g., Content-Type, Authorization)
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Allow credentials (if needed for authentication/cookies)
header('Access-Control-Allow-Credentials: true');

// Check if the 'postid' is passed in the URL query parameters
if (isset($_GET['postid']) && is_numeric($_GET['postid'])) {
    $postid = $_GET['postid']; // Get the postid from query parameters

    // Sanitize the postid to prevent SQL injection
    $postid = $conn->real_escape_string($postid);

    // SQL query to fetch comments for the given postid
    $sql = "SELECT id, objects_id, comment, username, email, created_at FROM comments WHERE objects_id = '$postid'"; 

    // Execute the query to get comments
    $result = $conn->query($sql);

    // Check if the query was successful
    if ($result) {
        // Check if any data was returned
        if ($result->num_rows > 0) {
            $comments_data = array(); // Initialize an empty array to hold all comments data

            // Fetch and add each comment to the array
            while ($comment = $result->fetch_assoc()) {
                // Fetch the replies for each comment
                $comment_id = $comment['id'];
                $replies_sql = "SELECT id, comment_id, replycomment, replyusername, replyemail, created_at FROM replycomments WHERE comment_id = '$comment_id'";

                // Execute the query to get replies for the comment
                $replies_result = $conn->query($replies_sql);
                $replies_data = array(); // Initialize an empty array to hold the replies

                // Check if replies are found
                if ($replies_result && $replies_result->num_rows > 0) {
                    while ($reply = $replies_result->fetch_assoc()) {
                        $replies_data[] = $reply; // Add each reply to the replies array
                    }
                }

                // Add the comment data along with its replies
                $comment['replies'] = $replies_data;
                $comments_data[] = $comment; // Add the comment to the comments data array
            }

            // Return the comments data as a JSON response
            echo json_encode(["status" => "success", "comments" => $comments_data]);
        } else {
            // If no comments are found, return an error message
            echo json_encode(["status" => "error", "message" => "No comments found"]);
        }
    } else {
        // If the query to fetch comments fails, return an error message
        echo json_encode(["status" => "error", "message" => "Failed to fetch comments: " . $conn->error]);
    }
} else {
    // If 'postid' is not passed in the request or is invalid, return an error message
    echo json_encode(["status" => "error", "message" => "'postid' parameter is missing or invalid"]);
}

// Close the database connection
$conn->close();
?>
