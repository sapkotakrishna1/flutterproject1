import 'dart:async'; // Import for Timer functionality
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart'; // Import the Config class
import 'login.dart'; // Import the LoginPage here
import 'package:crypto/crypto.dart'; // Import crypto package for hashing

class OtpInputPage extends StatefulWidget {
  final String id;
  final String email;
  final String contact;
  final String username;
  final String gender;
  final String location;
  final String userId;
  final String password;

  const OtpInputPage({
    super.key,
    required this.id,
    required this.contact,
    required this.gender,
    required this.email,
    required this.location,
    required this.username,
    required this.userId,
    required this.password,
  });

  @override
  _OtpInputPageState createState() => _OtpInputPageState();
}

class _OtpInputPageState extends State<OtpInputPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  int _remainingTime = 300; // 5 minutes in seconds
  late Timer _timer; // Timer to count down

  // Function to handle OTP verification
  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Hash the password using SHA-256 before sending it
      String hashedPassword = _hashPassword(widget.password);

      final response = await http.post(
        Uri.parse(
            '${Config.baseUrl}${Config.verifyotpregister}'), // Replace with your PHP logout API URL
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id": widget.id,
          "email": widget.email,
          "username": widget.username,
          "location": widget.location,
          "contact": widget.contact,
          "userId": widget.userId,
          "gender": widget.gender,
          "password": hashedPassword, // Send hashed password
          "otp": _otpController.text, // OTP entered by user
        }),
      );

      final responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'])),
      );

      // Log the response for debugging
      print('Response Data: ${responseData.toString()}');

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Navigate to LoginPage after successful OTP verification
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LoginPage(), // Redirect to the Login Page
        ));
      } else {
        // Handle failure (e.g., show an error message)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed.')),
        );
      }
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Function to hash password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Generate SHA-256 hash
    return digest.toString(); // Return the hashed password as a string
  }

  // Function to start the countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        // Timer has finished, stop it and show message
        _timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer(); // Start the countdown timer as soon as the page is loaded
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  // Function to format the remaining time (minutes:seconds)
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 25),
          child: Text(
            'Enter OTP',
            style: TextStyle(fontSize: 24),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Please enter the OTP sent to your email.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Countdown timer display
                  Text(
                    'Time Remaining: ${_formatTime(_remainingTime)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'OTP',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        _isLoading || _remainingTime == 0 ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 158, 144, 184),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
