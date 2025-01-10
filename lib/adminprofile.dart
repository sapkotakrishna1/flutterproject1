import 'dart:convert';
import 'login.dart'; // Assuming you have a LoginPage widget
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Import the config.dart file for dynamic base URL
import 'package:shared_preferences/shared_preferences.dart'; // For storing preferences (authentication)

class AdminProfilePage extends StatelessWidget {
  final String username;
  final String email;

  const AdminProfilePage(
      {super.key, required this.username, required this.email});

  // Function to handle the logout API call
  Future<void> _logout(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(
            '${Config.baseUrl}${Config.logoutEndpoint}'), // Replace with your PHP logout API URL
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username
        }, // Send username or any other required data
      );

      // Check if the response is a success
      if (response.statusCode == 200) {
        final responseBody = response.body;
        final Map<String, dynamic> jsonResponse = responseBody.isNotEmpty
            ? jsonDecode(responseBody)
            : {}; // Decode the response body as JSON

        if (jsonResponse['success'] == true) {
          // Logout was successful
          _clearUserData(); // Clear local authentication data

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout successful!')),
          );

          // Redirect to login screen directly after successful logout
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const LoginPage()), // Replace current screen with LoginPage
          );
        } else {
          // Handle failed logout (e.g., if the PHP script did not return success)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logout failed. Please try again.')),
          );
        }
      } else {
        // Handle non-200 response (e.g., network error)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while logging out.')),
        );
      }
    } catch (e) {
      // Handle network error if there's an issue with the request
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again later.')),
      );
    }
  }

  // Clear user data from shared preferences or any secure storage
  Future<void> _clearUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token'); // Remove stored auth token or session data
    prefs.remove(
        'username'); // Optionally, remove the username or any other data
  }

  @override
  Widget build(BuildContext context) {
    // Get the first letter of the username
    String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : "";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 30% container with image, username, and email
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Apply rounded corners
              child: Container(
                width: double.infinity, // Full width
                height: MediaQuery.of(context).size.height * 0.3, // 30% height
                color: Colors.blue.shade50, // Light background color
                alignment: Alignment.center,
                child: Column(
                  children: [
                    // CircleAvatar with the first letter of the username
                    CircleAvatar(
                      radius: 50, // Size of the circle
                      backgroundColor: Colors.blue, // Circle background color
                      child: Text(
                        firstLetter, // First letter of the username
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Username
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Email
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16), // Space between containers

            // 70% container with "Edit Profile" and "Logout" buttons (Scrollable)
            Flexible(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8), // Apply rounded corners
                child: Container(
                  width: double.infinity, // Full width
                  color: Colors.blue.shade100, // Light background color
                  child: SingleChildScrollView(
                    // Make this container scrollable
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile Information',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 20),

                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () {
                            // Edit Profile functionality
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Edit Profile'),
                                  content: const Text(
                                      'This is where you can edit the profile details.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                          ),
                          child: const Text('Edit Profile'),
                        ),
                        const SizedBox(height: 20),

                        // Logout Button
                        ElevatedButton(
                          onPressed: () {
                            _logout(context); // Call the logout function
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red color for logout
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
