import 'dart:convert';
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'otpinput.dart'; // Import OTP input page

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationController = TextEditingController();
  final _idController = TextEditingController(); // Define id controller

  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Loading state
  bool _isPasswordVisible = false; // Password visibility toggle
  bool _isPasswordFieldEmpty = true; // Track if password field is empty

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();

    // Add listener to check for changes in the password field
    _passwordController.addListener(() {
      setState(() {
        _isPasswordFieldEmpty = _passwordController.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(() {});
    super.dispose();
  }

  // Registration function
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Set loading to true
      });

      try {
        // Sending registration data to the server
        final response = await http.post(
          Uri.parse(
              '${Config.baseUrl}${Config.register}'), // Replace with your PHP logout API URL
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'username': _usernameController.text,
            'email': _emailController.text,
            'location': _locationController.text, // Send location value
            'gender': _selectedGender ?? '',
            'contact': _contactController.text,
            'password': _passwordController.text,
          },
        );

        // Log the full response to debug issues
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}'); // For debugging

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);

          // Check the response structure carefully
          if (responseBody['message'] ==
              'This email is already associated with an account.') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseBody['message'])),
            );
          } else if (responseBody['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please check your email for Verify OTP.')),
            );

            // After successful registration, navigate to OTP input page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpInputPage(
                  email: _emailController.text,
                  username: _usernameController.text,
                  password: _passwordController.text,
                  id: _idController
                      .text, // Assuming there's a controller for id
                  location: _locationController.text,
                  gender: _selectedGender ?? '',
                  userId: '',
                  contact: _contactController.text,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Failed to register: ${responseBody['message']}')),
            );
          }
        } else {
          // Handle unexpected status code
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Error: ${response.statusCode} - ${response.body}')),
          );
        }
      } catch (e) {
        // Catch network or unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Reset loading state after response
        });
      }
    }
  }

  // Validation functions for form fields
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Username must contain only letters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[^@]+@gmail\.com$').hasMatch(value)) {
      return 'Please enter a valid Gmail address';
    }
    return null;
  }

  String? _validateContact(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your contact number';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Contact number must be 10 digits';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\W).+$').hasMatch(value)) {
      return 'Password must contain at least one letter and one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 25), // Adjust top padding
          child: Text(
            'Register',
            style: TextStyle(fontSize: 24), // Adjust font size
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(35.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 223, 217, 217),
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Username field
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: _validateUsername,
                  ),
                  const SizedBox(height: 16),
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  // Location field
                  TextFormField(
                    controller: _locationController, // Location field
                    decoration: InputDecoration(
                      labelText: 'Location',
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Gender dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    items: genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Contact number field
                  TextFormField(
                    controller: _contactController,
                    decoration: InputDecoration(
                      labelText: 'Contact Number',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    validator: _validateContact,
                  ),
                  const SizedBox(height: 16),
                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: !_isPasswordFieldEmpty
                          ? IconButton(
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
                            )
                          : null, // Only show icon when password is not empty
                    ),
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24),
                  // Register button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Register'),
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
