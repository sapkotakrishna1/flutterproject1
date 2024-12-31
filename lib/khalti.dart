import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String referenceId = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khalti Payment"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                payWithKhaltiInApp();
              },
              child: const Text("Pay with Khalti"),
            ),
            const SizedBox(height: 20),
            Text('Reference ID: $referenceId'),
          ],
        ),
      ),
    );
  }

  // Function to initiate Khalti payment
  payWithKhaltiInApp() {
    KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: 1000, // in paisa (1000 paisa = 10 NPR)
        productIdentity: 'ProductId12345', // Unique product identity
        productName: 'Test Product',
        mobileReadOnly: false, // Allow the user to edit their mobile number
      ),
      preferences: [
        PaymentPreference.khalti, // Use Khalti payment method
      ],
      onSuccess: onSuccess, // Handle success
      onFailure: onFailure, // Handle failure
      onCancel: onCancel, // Handle cancellation
    );
  }

  // Payment success handler
  void onSuccess(PaymentSuccessModel success) {
    setState(() {
      referenceId = success.idx; // Get the reference ID from the success model
    });

    // Show a success dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment Successful'),
          content: Text('Payment Reference ID: ${success.idx}'),
          actions: [
            SimpleDialogOption(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Payment failure handler
  void onFailure(PaymentFailureModel failure) {
    debugPrint('Payment failed: ${failure.toString()}');
    // Optionally, show an error dialog here
  }

  // Payment cancel handler
  void onCancel() {
    debugPrint('Payment cancelled');
    // Optionally, show a cancellation message
  }
}
