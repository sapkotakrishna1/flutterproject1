import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart'; // Ensure this file exists and is properly set up

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
    userName = widget.userName;
    email = widget.email;
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final response = await http.post(
      Uri.parse('http://192.168.1.79/myapp_api/logout.php'),
    );

    setState(() {
      isLoading = false; // Hide loading indicator
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        _showSnackBar(data['message'] ?? 'Logout failed');
      }
    } else {
      _showSnackBar('Server error, try again later');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProfilePicture(),
            const SizedBox(height: 20),
            _buildUserName(),
            const SizedBox(height: 10),
            _buildUserBio(),
            const SizedBox(height: 20),
            _buildEditProfileButton(),
            const SizedBox(height: 10),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: () {
        // Handle image selection
        print("Change Profile Picture tapped!");
      },
      child: CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(
            'https://yourprofileimageurl.com/image.jpg'), // Replace with your image URL
        child: Text(
          'User',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      userName,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserBio() {
    // Placeholder for user bio
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton(
      onPressed: () {
        // Handle edit profile action
        print("Edit Profile tapped!");
      },
      child: const Text('Edit Profile'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 198, 192, 209),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlinedButton(
      onPressed: () => _logout(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: isLoading
          ? const CircularProgressIndicator() // Show loading indicator
          : const Text('Logout'),
    );
  }
}
