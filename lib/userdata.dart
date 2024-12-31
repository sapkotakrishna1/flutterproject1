// user_data.dart
import 'package:flutter/material.dart';

class UserDataPage extends StatelessWidget {
  final String username;

  const UserDataPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'User Data for $username',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
