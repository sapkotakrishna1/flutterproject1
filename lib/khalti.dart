import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

class KhaltiPayment {
  static bool _isInitialized = false;

  // Initialize Khalti service
  static void initKhalti() {
    if (!_isInitialized) {
      Khalti.init(
        publicKey:
            'dcfc3c784c5b43dda1ed955e45d1fb2c', // Replace with your public key
        secretKey:
            '56242c87ba414312957a4be0b529f4c6', // Replace with your secret key
        environment:
            Environment.test, // Change to Environment.prod for production
      );
      _isInitialized = true;
    }
  }

  // Process the payment
  static Future<void> processPayment(BuildContext context, dynamic post) async {
    initKhalti(); // Ensure Khalti is initialized

    final amount = (post['price'] * 100).toInt(); // Convert to paisa

    try {
      KhaltiScope.of(context).pay(
        config: PaymentConfig(
          amount: amount,
          productIdentity: 'your_product_identity', // Set product identity
          productName: post['name'], // Product name
          productUrl: 'https://yourwebsite.com', // Product URL if applicable
        ),
        preferences: [PaymentPreference.khalti],
        onSuccess: (successModel) {
          _showPurchaseConfirmation(context);
        },
        onFailure: (failureModel) {
          _showErrorDialog(context, failureModel.message);
        },
      );
    } catch (e) {
      _showErrorDialog(
          context, 'Payment initialization failed: ${e.toString()}');
    }
  }

  // Show purchase confirmation dialog
  static void _showPurchaseConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Purchase Confirmation'),
          content: const Text('Thank you for your purchase!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog
  static void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Error'),
          content: Text(error),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
