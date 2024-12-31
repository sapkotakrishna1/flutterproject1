import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart'; // Ensure this file exists and is properly set up
import 'about.dart'; // Import About page
import 'terms_conditions.dart'; // Import Terms & Conditions page
import 'change_profile_picture.dart'; // Import Change Profile Picture page

class ProfilePage extends StatefulWidget {
  final String userName;
  final String email; // Add email parameter

  const ProfilePage({super.key, required this.userName, required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String userName;
  late String email;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    userName = widget.userName; // Initialize the username
    email = widget.email; // Initialize the email
  }

  // Logout function to handle user logout
  Future<void> _logout(BuildContext context) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final response = await http.post(
      Uri.parse('http://localhost/myapp_api/logout.php'), // Logout API endpoint
    );

    setState(() {
      isLoading = false; // Hide loading indicator after response
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) =>
                  const LoginPage()), // Navigate to Login Page
        );
      } else {
        _showSnackBar(data['message'] ?? 'Logout failed'); // Show error message
      }
    } else {
      _showSnackBar('Server error, try again later'); // Handle server error
    }
  }

  // Display a SnackBar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)), // Display the message in SnackBar
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // AppBar with title
        backgroundColor: Colors.deepPurple, // AppBar background color
      ),
      body: Column(
        children: [
          // Profile Section (Centered with a smaller radius)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
                16.0), // Padding inside the profile section
            decoration: const BoxDecoration(
              color: Colors.white, // Set the color directly in the decoration
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8), // Smaller 20% radius
                bottomRight: Radius.circular(8), // Smaller 20% radius
              ),
            ),
            child: Column(
              children: [
                _buildProfilePicture(), // Profile picture widget
                const SizedBox(height: 10),
                _buildUserName(), // Username widget
                const SizedBox(height: 5),
                _buildUserEmail(), // User email widget
              ],
            ),
          ),

          // Remaining Options Section (Black background with a smaller 20% radius)
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(
                    255, 36, 35, 35), // Black background within decoration
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), // Smaller 20% radius
                  topRight: Radius.circular(8), // Smaller 20% radius
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(
                    16), // Padding inside the options section
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align left
                  children: [
                    _buildIconTextButton(Icons.edit, 'Edit Profile', () {
                      print(
                          "Edit Profile tapped!"); // Handle edit profile button tap
                    }),
                    const SizedBox(height: 10),
                    _buildIconTextButton(Icons.logout, 'Logout', () {
                      _logout(context); // Call logout function
                    }),
                    const SizedBox(height: 10),
                    _buildIconTextButton(Icons.info, 'About Us', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AboutPage()), // Navigate to About Page
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildIconTextButton(
                        Icons.description, 'Terms and Conditions', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TermsConditionsPage()), // Navigate to Terms and Conditions Page
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build profile picture (with GestureDetector for changing)
  Widget _buildProfilePicture() {
    String firstLetter = userName.isNotEmpty
        ? userName[0].toUpperCase()
        : ''; // Extract the first letter of the user's name

    return GestureDetector(
      onTap: () {
        print("Change Profile Picture tapped!");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChangeProfilePicturePage(), // Navigate to ChangeProfilePicturePage
          ),
        );
      },
      child: Hero(
        tag: 'profilePicture', // Used for Hero animation
        child: CircleAvatar(
          radius: 50, // Profile picture size
          backgroundColor: Colors.deepPurple, // Background color of the avatar
          child: Text(
            firstLetter, // Display the first letter of the user's name
            style: const TextStyle(
              fontSize: 30, // Font size of the letter
              fontWeight: FontWeight.bold, // Bold text for the letter
              color: Colors.white, // Color of the letter
            ),
          ),
        ),
      ),
    );
  }

  // Widget to display user's first name
  Widget _buildUserName() {
    String firstName = userName.split(" ")[0]; // Extract the first name
    return Text(
      firstName,
      style: const TextStyle(
        fontSize: 24, // Adjusted font size
        color: Color.fromARGB(255, 0, 0, 0), // Changed text color to black
        overflow: TextOverflow.ellipsis, // Avoid overflow of long names
      ),
      maxLines: 1, // Ensure that name fits within the space
      softWrap: false,
    );
  }

  // Widget to display user's email
  Widget _buildUserEmail() {
    return Text(
      email,
      style: const TextStyle(
        fontSize: 14, // Adjusted font size
        color: Color.fromARGB(255, 39, 38, 38), // Changed text color to black
        overflow: TextOverflow.ellipsis, // Avoid overflow of long emails
      ),
      maxLines: 1, // Ensure that email fits within the space
      softWrap: false,
    );
  }

  // Widget to create a button with icon and label
  Widget _buildIconTextButton(
      IconData icon, String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed, // Action when button is pressed
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, // White icon and text color for contrast
        padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10), // Adjusted padding to make button start from left
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24, // Icon size
          ),
          const SizedBox(width: 10), // Space between icon and text
          Text(
            label,
            style: const TextStyle(fontSize: 18), // Text font size
          ),
        ],
      ),
    );
  }
}
