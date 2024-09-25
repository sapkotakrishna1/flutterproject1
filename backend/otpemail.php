<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php'; // Adjust the path as necessary
require 'dbconnection.php'; // Include your database connection

function sendOtpEmail($email, $otp) {
    // Send OTP via email
    $mail = new PHPMailer(true);
    try {
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'sapkotakrishna110@gmail.com'; // Your SMTP username
        $mail->Password = 'xbam ehnv evox sscm'; // Your SMTP password
        $mail->SMTPSecure = 'tls';
        $mail->Port = 587;

        $mail->setFrom('from@example.com', 'Your Name');
        $mail->addAddress($email);

        $mail->isHTML(true);
        $mail->Subject = 'Your OTP Code';
        $mail->isHTML(true);
        $mail->Subject = 'Your OTP Code';

        // Improved HTML email body
        $mail->Body = '
        <!DOCTYPE html>
        <html>
        <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                 body { font-family: Arial, sans-serif; margin: 0; padding: 0; }
                 .container { max-width: 600px; margin: 20px auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 5px; }
                 h1 { color: #333; }
                 p { color: #555; }
                 .otp { font-size: 24px; font-weight: bold; color: #007bff; }
                 .footer { margin-top: 20px; font-size: 12px; color: #aaa; }
            </style>
        </head>
    <body>
       <div class="container">
          <h1>Your OTP Code</h1>
          <p>Dear User,</p>
          <p>Your OTP code is: <span class="otp">' . htmlspecialchars($otp) . '</span></p>
          <p>Please enter this code to complete your verification.</p>
          <p>Thank you!</p>
          <div class="footer">
            <p>This email was sent from your application.</p>
          </div>
      </div>
    </body>
</html>';


        $mail->send();
        return true;
    } catch (Exception $e) {
        echo json_encode(["message" => "Email could not be sent. Mailer Error: {$mail->ErrorInfo}"]);
        return false; // Indicate failure
    }
}
