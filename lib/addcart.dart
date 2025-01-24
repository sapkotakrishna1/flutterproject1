import 'dart:convert'; // For decoding Base64 images
//import 'dart:typed_data'; // Required for Image.memory()
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Assuming you have a config file for base URLs

class AddCartPage extends StatefulWidget {
  final String username;
  final String email;

  const AddCartPage({super.key, required this.username, required this.email});

  @override
  _AddCartPageState createState() => _AddCartPageState();
}

class _AddCartPageState extends State<AddCartPage> {
  List<Map<String, dynamic>>? posts; // List to store posts
  bool isLoading = true; // To handle loading state
  String errorMessage = ''; // To store error message

  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // Fetch cart items from the server on page load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fav Cart'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : posts == null || posts!.isEmpty
                  ? const Center(child: Text('No Cart Added'))
                  : ListView.builder(
                      itemCount: posts!.length,
                      itemBuilder: (context, index) {
                        final post = posts![index];

                        // // Decode the base64 image if present
                        // Uint8List? decodedImage;
                        // if (post['image'] != null) {
                        //   decodedImage = base64Decode(post['image']);
                        // }

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                    'Product Name: ${post['product_name'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Price: \$${post['price'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Username: ${post['username'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                post['image'] != null
                                    ? Image.memory(
                                        base64Decode(post['image']),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox.shrink(),
                                // Delete button (optional)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deletePost(post['id'], index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

// Fetch posts from the API based on the username (email)
  Future<void> _fetchCartItems() async {
    final url = Uri.parse(
        '${Config.baseUrl}${Config.getcartitems}?email=${widget.email}'); // Include username in the API request URL
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        var jsonData = json.decode(response.body);
        if (jsonData is List) {
          setState(() {
            posts = List<Map<String, dynamic>>.from(jsonData);
            isLoading = false;
          });
        } else if (jsonData is Map && jsonData.containsKey('error')) {
          setState(() {
            errorMessage = jsonData['error'];
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Failed to parse server response.';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage =
            'Failed to load data. Server returned status code ${response.statusCode}';
        isLoading = false;
      });
    }
  }

  // Delete post from the cart
  Future<void> _deletePost(int postId, int index) async {
    final url =
        Uri.parse('${Config.baseUrl}${Config.removecart}'); // Your API endpoint
    final response = await http.delete(url, body: {'id': postId.toString()});

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          posts!.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete post')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete. Status: ${response.statusCode}')));
    }
  }
}
