<?php
require 'vendor/autoload.php'; // Ensure this path is correct

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Start the session
session_start();

// Function to send a confirmation email
function sendConfirmationEmail($email, $username) {
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
        $mail->setFrom('no-reply@yourdomain.com', 'Note Supplier'); // Set sender's address
        $mail->addAddress($email, $username); // Add a recipient

        // Content
        $mail->isHTML(true); // Set email format to HTML
        $mail->Subject = 'Registration Confirmation'; // Email subject
        $mail->Body = '
            <html>
            <body style="font-family: Arial, sans-serif; background-color: #f6f6f6; padding: 20px;">
                <div style="background-color: #ffffff; padding: 20px; border-radius: 5px;">
                    <h2 style="color: #333333;">Thank You for Connecting with Us!' . htmlspecialchars($username) . '!</h2>
                    <p style="color: #555555;">We appreciate your interest and are excited to have you with us.</p>
                    <p style="color: #777777;">Best regards,<br>Note Supplier</p>
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
