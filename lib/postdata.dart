import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class PostDataPage extends StatefulWidget {
  final String username;

  const PostDataPage({super.key, required this.username});

  @override
  _PostDataPageState createState() => _PostDataPageState();
}

class _PostDataPageState extends State<PostDataPage> {
  List<Map<String, dynamic>>? posts; // List to hold posts
  bool isLoading = true; // To handle loading state
  String errorMessage = ''; // To store error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Data'),
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
                  ? const Center(child: Text('No posts available'))
                  : ListView.builder(
                      itemCount: posts!.length,
                      itemBuilder: (context, index) {
                        final post = posts![index];

                        // Print fields for debugging
                        print('Id: ${post['id']}');
                        print('Product Name: ${post['name']}');
                        print('Description: ${post['description']}');
                        print('Price: ${post['price']}');
                        print('Age: ${post['age']}');
                        print('Username: ${post['username']}');
                        print('Email: ${post['email']}');
                        print('Created At: ${post['created_at']}');

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Id: ${post['id'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Product Name: ${post['name'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text(
                                    'Description: ${post['description'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Price: \$${post['price'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Age: ${post['age'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Username: ${post['username'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Email: ${post['email'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text(
                                    'Created At: ${post['created_at'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                post['images'] != null
                                    ? Image.memory(
                                        base64Decode(post['images']),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox.shrink(),
                                // Delete button
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

  @override
  void initState() {
    super.initState();
    _fetchPostData();
  }

  // Function to fetch post data from the API
  Future<void> _fetchPostData() async {
    final url = Uri.parse('${Config.baseUrl}${Config.getpostdata}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        // Decode the JSON response
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
        } else {
          setState(() {
            errorMessage = 'Unexpected response format';
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

  // Function to delete post
  Future<void> _deletePost(int postId, int index) async {
    final url =
        Uri.parse('${Config.baseUrl}${Config.deletepostdata}?id=$postId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          setState(() {
            posts!.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete the post')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to delete. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
