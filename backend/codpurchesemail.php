<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require 'vendor/autoload.php'; // Make sure PHPMailer is installed via Composer

// This function will send the confirmation email to the post owner
function sendConfirmationEmail($email, $productName, $price, $address, $phone) {
    $mail = new PHPMailer(true);
    try {
        // Server settings
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com'; // Use Gmail's SMTP server (or any other SMTP server)
        $mail->SMTPAuth = true;
        $mail->Username = 'sapkotakrishna110@gmail.com'; // Your Gmail address
        $mail->Password = 'xbam ehnv evox sscm'; // Your App Password or Gmail password
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;

        // Recipients
        $mail->setFrom('no-reply@yourdomain.com', 'ReStore');
        $mail->addAddress($email); // The post owner's email

        // Content
        $mail->isHTML(true);
        $mail->Subject = 'Your Product Has Been Sold!';
        $mail->Body = "
            <html>
            <body style='font-family: Arial, sans-serif; background-color: #f6f6f6; padding: 20px;'>
                <div style='background-color: #ffffff; padding: 20px; border-radius: 5px;'>
                    <h2 style='color: #333333;'>Your Product Has Been Sold!</h2>
                    <p style='color: #555555;'>The following product has been sold:</p>
                    <p style='color: #333333;'>Product: $productName</p>
                    <p style='color: #333333;'>Price: NPR $price</p>
                    <p style='color: #333333;'>Buyer Address: $address</p>
                    <p style='color: #333333;'>Buyer Phone: $phone</p>
                    <p style='color: #777777;'>Please contact the buyer at the provided address and phone number for delivery arrangements.</p>
                    <p style='color: #777777;'>Best regards,<br>Restore</p>
                </div>
            </body>
            </html>
        ";

        // Send the email
        $mail->send();
        return true;
    } catch (Exception $e) {
        return false;
    }
}

// Handle the request from the Flutter app
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get data from POST request
    $data = json_decode(file_get_contents('php://input'), true);

    if (isset($data['postid'], $data['product_name'], $data['price'], $data['address'], $data['phone'], $data['email'])) {
        $postid = $data['postid'];
        $product_name = $data['product_name'];
        $price = $data['price'];
        $address = $data['address'];
        $phone = $data['phone'];
        $email = $data['email']; // Post owner's email

        // Send the confirmation email
        $result = sendConfirmationEmail($email, $product_name, $price, $address, $phone);

        if ($result) {
            echo json_encode(['success' => true, 'message' => 'Email sent successfully!']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Error sending email.']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid data received.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Invalid request method.']);
}
?>
