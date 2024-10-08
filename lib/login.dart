import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'otpinput.dart';
import 'reg.dart';
import 'profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final response = await http.post(
          Uri.parse('http://localhost/myapp_api/login.php'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": _usernameController.text,
            "password": _passwordController.text,
          }),
        );

        final responseData = json.decode(response.body);
        print('Response: $responseData'); // Debug statement

        if (response.statusCode == 200) {
          String username = responseData['username'] ?? '';
          String email = _usernameController.text;
          String userId =
              responseData['userId'] ?? ''; // Capture user ID from response

          // Store in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);
          await prefs.setString('username', username);
          await prefs.setString('userId', userId); // Store user ID

          _showSnackBar(responseData['message'] ?? 'Success');

          // Navigate based on response
          _handleNavigation(responseData, username, email, userId);
        } else {
          _showSnackBar('Error: ${responseData['message'] ?? 'Server error'}');
        }
      } catch (error) {
        print('Error: $error'); // Log the error for debugging
        _showSnackBar('An error occurred: $error');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleNavigation(Map<String, dynamic> responseData, String username,
      String email, String userId) {
    if (responseData['success'] == true) {
      if (responseData['redirect'] == 'home.php') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                HomePage(username: username, email: email, userId: userId),
          ),
        );
      } else if (responseData['message'].contains('OTP generated') ||
          responseData['message'].contains('An OTP is already sent')) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpInputPage(
              email: email,
              username: username,
              userId: '',
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfilePage(userName: username, email: email),
          ),
        );
      }
    } else {
      _showSnackBar('Error: ${responseData['message'] ?? 'Server error'}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 50),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter an email'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter a password'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Login',
                                  style: TextStyle(fontSize: 16)),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _navigateToRegister,
                          child: const Text('New here? Register',
                              style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
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
