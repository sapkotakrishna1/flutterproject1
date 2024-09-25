import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Loading...';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.79/myapp_api/get_user_data.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            userName = data['username']; // Assuming the API returns 'username'
            isLoading = false;
          });
        } else {
          _handleError(data['message']);
        }
      } else {
        _handleError('Unable to fetch data');
      }
    } catch (e) {
      _handleError('Error: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      userName = 'Error: $message';
      isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://192.168.1.79/myapp_api/logout.php'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
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
    return CircleAvatar(
      radius: 60,
      backgroundImage: NetworkImage('https://yourprofileimageurl.com/image.jpg'), // Replace with your image URL
      child: const Text(
        'User',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildUserName() {
    return isLoading
        ? const CircularProgressIndicator()
        : Text(
            userName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          );
  }

  Widget _buildUserBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: Colors.black54),
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
      child: const Text('Logout'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
    );
  }
}
