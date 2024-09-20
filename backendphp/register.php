<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'dbconnection.php'; // Ensure this file is correct
include 'send_email.php'; // Include the send_email.php file //xbam ehnv evox sscm

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Log the received POST request
    file_put_contents('php://stderr', "Received POST request\n");

    // Determine content type and get data
    $data = ($_SERVER['CONTENT_TYPE'] === 'application/json')
        ? json_decode(file_get_contents("php://input"), true)
        : $_POST;

    // Check for required fields
    if (!empty($data['username']) && !empty($data['email']) && !empty($data['faculty']) && !empty($data['gender']) && !empty($data['contact']) && !empty($data['password'])) {
        $username = $data['username'];
        $email = $data['email'];
        $faculty = $data['faculty'];
        $gender = $data['gender'];
        $contact = $data['contact'];
        $password = password_hash($data['password'], PASSWORD_BCRYPT);

        // Prepare and execute the SQL statement
        $stmt = $conn->prepare("INSERT INTO users (username, email, faculty, gender, contact, password) VALUES (?, ?, ?, ?, ?, ?)");
        if ($stmt) {
            $stmt->bind_param("ssssss", $username, $email, $faculty, $gender, $contact, $password);

            if ($stmt->execute()) {
                // Send confirmation email
                if (sendConfirmationEmail($email, $username)) {
                    echo json_encode(["message" => "User created", "id" => $stmt->insert_id]);
                } else {
                    echo json_encode(["message" => "User created, but email failed to send."]);
                }
            } else {
                echo json_encode(["message" => "User creation failed", "error" => $stmt->error]);
            }

            $stmt->close();
        } else {
            echo json_encode(["message" => "Failed to prepare statement", "error" => $conn->error]);
        }
    } else {
        echo json_encode(["message" => "Invalid input"]);
    }
} else {
    echo json_encode(["message" => "Method not allowed"]);
}

$conn->close();
?>
