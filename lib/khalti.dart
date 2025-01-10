// khalti.dart
import 'package:flutter/material.dart';
import 'package:khalti/khalti.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

void openKhaltiPayment(BuildContext context, String productName, double price,
    String productId, String username) {
  // Initialize Khalti with your public key
  Khalti.init(publicKey: "97eae73a88714ba0bf8e85c941606bb1");

  // Create PaymentConfig for Khalti
  var paymentConfig = PaymentConfig(
    amount:
        (price * 100).toInt(), // Price in paise (Khalti expects price in paise)
    productIdentity: productId, // Unique product ID
    productName: productName, // Product name to display during payment
  );

  // Trigger the Khalti payment dialog
  KhaltiScope.of(context).pay(
    config: paymentConfig,
    preferences: [
      PaymentPreference.khalti, // Let the user choose Khalti for payment
    ],
    onSuccess: (value) {
      // Handle payment success (you can send a notification, update DB, etc.)
      _handlePaymentSuccess(context, value, productName, price, username);
    },
    onFailure: (error) {
      // Handle payment failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: $error')),
      );
    },
  );
}

void _handlePaymentSuccess(BuildContext context, dynamic value,
    String productName, double price, String username) {
  // Show a success dialog after successful payment
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Purchase Confirmation'),
        content:
            Text('Thank you for purchasing "$productName" for NPR $price!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              // Optionally navigate to another page
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
