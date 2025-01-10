<?php
require 'vendor/autoload.php'; // Ensure this path is correct

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Start the session
session_start();

// Function to send password reset email
function sendPasswordResetEmail($email, $username, $resetToken) {
    $mail = new PHPMailer(true);

    try {
        // Server settings
        $mail->isSMTP(); // Use SMTP
        $mail->Host = 'smtp.gmail.com'; // Use Gmail's SMTP server
        $mail->SMTPAuth = true; // Enable SMTP authentication
        $mail->Username = 'sapkotakrishna110@gmail.com'; // Your Gmail address
        $mail->Password = 'xbam ehnv evox sscm'; // Your App Password or Gmail password
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS; // Use TLS encryption
        $mail->Port = 587; // TCP port for TLS

        // Recipients
        $mail->setFrom('no-reply@yourdomain.com', 'Restore APP'); // Set sender's address
        $mail->addAddress($email, $username); // Add recipient's email and name

        // Content
        $mail->isHTML(true); // Set email format to HTML
        $mail->Subject = 'Password Reset Request'; // Email subject
        $resetLink = "http://yourdomain.com/reset_password.php?token=" . $resetToken; // Replace with your actual domain and reset script
        $mail->Body = '
            <html>
            <body style="font-family: Arial, sans-serif; background-color: #f6f6f6; padding: 20px;">
                <div style="background-color: #ffffff; padding: 20px; border-radius: 5px;">
                    <h2 style="color: #333333;">Password Reset Request</h2>
                    <p style="color: #555555;">Hello ' . htmlspecialchars($username) . ',</p>
                    <p style="color: #555555;">We received a request to reset your password. Please click the link below to reset your password:</p>
                    <p><a href="' . $resetLink . '" style="background-color: #4CAF50; color: white; padding: 12px 20px; text-decoration: none; border-radius: 5px;">Reset Your Password</a></p>
                    <p style="color: #777777;">If you did not request a password reset, please ignore this email.</p>
                    <p style="color: #777777;">Best regards,<br>ReStore</p>
                </div>
            </body>
            </html>
        '; // Email body

        // Send the email
        $mail->send();
        return true;
    } catch (Exception $e) {
        echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
        return false;
    }
}
?>
