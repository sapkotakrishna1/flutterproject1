import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart'; // Import Khalti SDK
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // Import the Config class

class UpdateBuyInfoPage extends StatefulWidget {
  final String productName;
  final double price;
  final String postid;
  final String username;

  const UpdateBuyInfoPage({
    Key? key,
    required this.productName,
    required this.price,
    required this.postid,
    required this.username,
  }) : super(key: key);

  @override
  _UpdateBuyInfoPageState createState() => _UpdateBuyInfoPageState();
}

class _UpdateBuyInfoPageState extends State<UpdateBuyInfoPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isKhaltiSelected = false;

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address cannot be empty';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (!RegExp(r'^[9][678][0-9]{8}$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  // Function to verify the payment with your backend
  void _verifyPayment(String idx) async {
    try {
      final url = Uri.parse('${Config.baseUrl}${Config.verify_payment}');
      final response = await http.post(
        url,
        body: {
          'token': idx, // pidx received from the Khalti payment callback
          'amount': (widget.price * 100).toString(), // Expected amount in paisa
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Verified!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Payment Verification Failed: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to verify payment')),
        );
      }
    } catch (error) {
      print('Error during payment verification: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error occurred during payment verification')),
      );
    }
  }

  void _initiateKhaltiPayment() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    KhaltiScope.of(context).pay(
      config: PaymentConfig(
        amount: (widget.price * 100).toInt(),
        productIdentity: widget.postid,
        productName: widget.productName,
      ),
      preferences: [PaymentPreference.khalti],
      onSuccess: (paymentData) {
        print('Payment Successful: ${paymentData.idx}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment Successful!')),
        );

        // Send the pidx to backend for verification
        _verifyPayment(paymentData.idx);
      },
      onFailure: (error) {
        print('Payment Failed: ${error.message}');
        String errorMessage = 'Payment Failed: Unknown Error';

        // Detailed error messages
        if (error.message.contains("MPIN")) {
          errorMessage = 'Invalid MPIN. Please check your MPIN and try again.';
        } else if (error.message.contains("Phone number")) {
          errorMessage = 'Phone number is incorrect. Please check your number.';
        } else if (error.message.contains("network")) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (error.message.contains("transaction")) {
          errorMessage = 'Transaction failed. Please try again later.';
        } else {
          errorMessage = 'Payment Failed: ${error.message}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Purchase Info'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post ID: ${widget.postid}',
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              Text(
                'Product: ${widget.productName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                'Price: NPR ${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 20),

              // Address field
              const Text(
                'Enter Your Address:',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Your Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
                maxLines: 3,
                validator: _validateAddress,
              ),
              const SizedBox(height: 20),

              // Phone number field
              const Text(
                'Enter Your Phone Number:',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
                maxLength: 15,
                validator: _validatePhone,
              ),
              const SizedBox(height: 20),

              // Khalti Image for payment with tick functionality
              const Text(
                'Choose Your Payment Method:',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isKhaltiSelected = !isKhaltiSelected;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: isKhaltiSelected
                        ? Border.all(color: Colors.deepPurple, width: 3)
                        : Border.all(color: Colors.grey, width: 2),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/khalti.png',
                          width: 200,
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (isKhaltiSelected)
                        const Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirm Purchase button
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (isKhaltiSelected) {
                      _initiateKhaltiPayment();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select Khalti')),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Confirm Purchase',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 190, 142, 142)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
