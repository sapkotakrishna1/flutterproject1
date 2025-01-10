import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPostPage extends StatefulWidget {
  final dynamic post; // Post data passed from the previous screen

  const EditPostPage({super.key, required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.post['price'].toString();
    _descriptionController.text = widget.post['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Price Input Field
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (NPR)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Description Input Field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Save Button to update the post details
            ElevatedButton(
              onPressed: _updatePost,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to update post details
  void _updatePost() async {
    // Validate input
    if (_priceController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // Update the post with new values
    widget.post['price'] = double.parse(_priceController.text);
    widget.post['description'] = _descriptionController.text;

    // API URL to update the post on the backend (you need to replace this with your actual API URL)
    final url = Uri.parse(
        '${Config.baseUrl}${Config.updatepost}'); // Replace with your PHP logout API URL

    try {
      // Send POST request to update the post with new data
      final response = await http.post(url, body: {
        'id': widget.post['id'].toString(),
        'price': widget.post['price'].toString(),
        'description': widget.post['description'],
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Check if update was successful
        if (data['status'] == 'success') {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post updated successfully!')),
          );
          // Go back to the previous page
          Navigator.pop(context);
        } else {
          // If the update fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to the server.')),
        );
      }
    } catch (e) {
      // Handle any other exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
