import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'profile.dart';
import 'reg.dart';
import 'config.dart';
import 'forgot_password.dart';
import 'admin.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Login function with async/await
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${Config.baseUrl}${Config.login}'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: jsonEncode({
            "email": _usernameController.text,
            "password": _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          _handleNavigation(responseData);
        } else {
          _showSnackBar('Error: ${response.body}');
        }
      } catch (error) {
        _showSnackBar('An error occurred: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Navigate based on response
  void _handleNavigation(Map<String, dynamic> responseData) {
    String username = responseData['username'] ?? '';
    String email = _usernameController.text;
    String userId = responseData['userId'] ?? '';
    String redirectTo = responseData['redirect'] ?? '';

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('email', email);
      prefs.setString('username', username);
      prefs.setString('userId', userId);
    });

    if (responseData['success'] == true) {
      if (redirectTo == 'home.php') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomePage(username: username, email: email, id: userId),
          ),
        );
      } else if (redirectTo == 'admin.php') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminPage(username: username, email: email),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(userName: username, email: email),
          ),
        );
      }
    } else {
      _showSnackBar('Error: ${responseData['message'] ?? 'Server error'}');
    }
  }

  // Show SnackBar for messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  // Navigate to Register Page
  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  // Navigate to Forgot Password Page
  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 164, 199, 224),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.person,
                size: 120,
                color: Color.fromARGB(255, 163, 159, 159),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 163, 159, 159),
                ),
              ),
              const SizedBox(height: 40),

              // Login Form Card
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // Email Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle:
                                const TextStyle(color: Colors.blueAccent),
                            prefixIcon: const Icon(Icons.email,
                                color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter an email'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle:
                                const TextStyle(color: Colors.blueAccent),
                            prefixIcon: const Icon(Icons.lock,
                                color: Colors.blueAccent),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter a password'
                              : null,
                        ),
                        const SizedBox(height: 30),

                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Login',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                        ),
                        const SizedBox(height: 20),

                        // Register and Forgot Password Links
                        TextButton(
                          onPressed: _navigateToRegister,
                          child: const Text('New here? Register',
                              style: TextStyle(color: Colors.blueAccent)),
                        ),
                        const SizedBox(height: 10),
                        //TextButton(
                        //  onPressed: _navigateToForgotPassword,
                        //  child: const Text('Forgot Password?',
                        //      style: TextStyle(color: Colors.blueAccent)),
                        //),
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
