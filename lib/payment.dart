import 'package:flutter/material.dart';
//This assumes Khalti SDK or a similar SDK is available
import 'package:http/http.dart'
    as http; // You may need this for network requests
import 'dart:convert';
import 'config.dart'; // Assume you have a config file for URLs and other settings

class PaymentPage extends StatefulWidget {
  final String productName;
  final double price; // price in paise (100 paise = 1 NPR)
  final String postId;
  final String username;

  const PaymentPage({
    super.key,
    required this.productName,
    required this.price,
    required this.postId,
    required this.username,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessingPayment = false;

  // Handle the Khalti payment initiation
  Future<void> _processPayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    // Use Khalti SDK or API to process the payment
    // Assume you have Khalti's public key and endpoint
    try {
      var response = await http.post(
        Uri.parse(
            '${Config.baseUrl}/payment/initialize'), // Replace with the actual payment endpoint
        body: jsonEncode({
          'product_name': widget.productName,
          'price': widget.price,
          'username': widget.username,
          'post_id': widget.postId,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'c27615abbf4d38852661e2ba62ca9b', // Use Khalti API Key here
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // On successful payment, navigate to a success page or show a confirmation
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment Successful!')));
          Navigator.pop(context); // Go back to the BuyPage
        } else {
          // Handle failure scenario
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment Failed: ${data['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to initiate payment.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing payment: $e')));
    } finally {
      setState(() {
        _isProcessingPayment = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display product details
            Text(
              'Product: ${widget.productName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Price: NPR ${widget.price / 100}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Username: ${widget.username}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),

            // Payment Button
            ElevatedButton(
              onPressed: _isProcessingPayment ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: _isProcessingPayment
                  ? CircularProgressIndicator() // Show a loader while processing
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
