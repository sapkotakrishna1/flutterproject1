<?php
// connection.php
$host = 'localhost'; // Database host
$user = 'root'; // Database username
$pass = ''; // Database password
$dbname = 'newfluter'; // Database name

// Create connection
$conn = new mysqli($host, $user, $pass, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(["message" => "Connection failed: " . $conn->connect_error]));
}
?>
