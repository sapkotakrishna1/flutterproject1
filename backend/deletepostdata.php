<?php
include 'dbconnection.php';

// Ensure 'id' is passed in the URL
if (isset($_GET['id']) && is_numeric($_GET['id'])) {
    $postId = $_GET['id'];

    // Prepare DELETE statement
    $sql = "DELETE FROM objects WHERE id = ?";

    if ($stmt = $conn->prepare($sql)) {
        $stmt->bind_param("i", $postId);

        if ($stmt->execute()) {
            echo json_encode(['status' => 'success']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Failed to delete post']);
        }

        $stmt->close();
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Failed to prepare SQL query']);
    }
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid post ID']);
}

$conn->close();
?>
