import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
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
  final _idController = TextEditingController();

  String? _selectedGender;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isPasswordFieldEmpty = true;

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
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

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('${Config.baseUrl}${Config.register}'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'username': _usernameController.text,
            'email': _emailController.text,
            'location': _locationController.text,
            'gender': _selectedGender ?? '',
            'contact': _contactController.text,
            'password': _passwordController.text,
          },
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);

          if (responseBody['message'] ==
              'This email is already associated with an account.') {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(responseBody['message'])));
          } else if (responseBody['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Please check your email for Verify OTP.')));
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpInputPage(
                  email: _emailController.text,
                  username: _usernameController.text,
                  password: _passwordController.text,
                  id: _idController.text,
                  location: _locationController.text,
                  gender: _selectedGender ?? '',
                  userId: '',
                  contact: _contactController.text,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Failed to register: ${responseBody['message']}')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Error: ${response.statusCode} - ${response.body}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error occurred: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
        title: const Text('Register'),
        centerTitle: true, // Centers the title
        backgroundColor:
            Colors.blue[50], // Match the background color of the app
        elevation: 0, // Optional: Remove the shadow for a seamless look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // This will pop the current page from the stack
          },
        ),
      ),
      backgroundColor:
          const Color.fromARGB(255, 147, 180, 204), // Light blue background
      body: Stack(
        children: [
          // Background image (ensure the image path is correct)
          Positioned.fill(
            child: Image.asset(
              'assets/image.jpg', // Ensure you add the image to your project assets
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Logo or Icon (Optional)
                  const Icon(
                    Icons.person,
                    size: 120,
                    color: Color.fromARGB(255, 157, 142, 185),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Register!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 153, 148, 199),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Card with the form
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
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            // Username Field
                            _buildTextField('Username', _usernameController,
                                Icons.person, _validateUsername),
                            const SizedBox(height: 20),

                            // Email Field
                            _buildTextField('Email', _emailController,
                                Icons.email, _validateEmail),
                            const SizedBox(height: 20),

                            // Location Field
                            _buildTextField('Location', _locationController,
                                Icons.location_on, (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your location';
                              }
                              return null;
                            }),
                            const SizedBox(height: 20),

                            // Gender Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                labelStyle:
                                    const TextStyle(color: Colors.blueAccent),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              items: genders.map((String gender) {
                                return DropdownMenuItem<String>(
                                    value: gender, child: Text(gender));
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Please select your gender'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Contact Number Field
                            _buildTextField(
                                'Contact Number',
                                _contactController,
                                Icons.phone,
                                _validateContact),
                            const SizedBox(height: 20),

                            // Password Field
                            _buildPasswordField(),
                            const SizedBox(height: 30),

                            // Register Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Register',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blueAccent),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.blueAccent),
        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: !_isPasswordFieldEmpty
            ? IconButton(
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      obscureText: !_isPasswordVisible,
      validator: _validatePassword,
    );
  }
}
