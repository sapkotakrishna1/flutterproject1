// post_data.dart
import 'package:flutter/material.dart';

class PostDataPage extends StatelessWidget {
  final String username;

  const PostDataPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Data'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text(
          'Post Data for $username',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
