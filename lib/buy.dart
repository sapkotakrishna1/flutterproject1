import 'package:flutter/material.dart';
import 'dart:convert'; // For base64Decode
import 'package:http/http.dart' as http;
import 'package:myapp/payment.dart';
import 'config.dart'; // Your configuration file with base URL

class BuyPage extends StatefulWidget {
  final dynamic post; // Product information passed from the previous page
  final String
      username; // Automatically detected from Firebase or any auth service
  final String email; // Current logged-in user's email
  final String id; // Current logged-in user's ID

  const BuyPage({
    super.key,
    required this.email,
    required this.post,
    required this.username,
    required this.id,
  });

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = [];
  int _currentIndex = 0; // To track the selected BottomNavigationBar item

  @override
  void initState() {
    super.initState();
    comments = widget.post['comments'] != null
        ? List<String>.from(widget.post['comments'])
        : [];
  }

  @override
  Widget build(BuildContext context) {
    String postEmail = widget.post['email'] ?? widget.email;
    bool isPostOwner = widget.email == postEmail;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deletePost();
              } else if (value == 'edit') {
                _editPost();
              } else if (value == 'addToCart') {
                _addToCart(); // Add to cart logic here
              }
            },
            itemBuilder: (BuildContext context) {
              if (isPostOwner) {
                return const [
                  PopupMenuItem<String>(
                      value: 'edit', child: Text('Edit Post')),
                  PopupMenuItem<String>(
                      value: 'delete', child: Text('Delete Post')),
                ];
              } else {
                return const [
                  PopupMenuItem<String>(
                      value: 'addToCart', child: Text('Add to Cart')),
                ];
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image at the top
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.post['images'] != null &&
                        widget.post['images'].isNotEmpty
                    ? Image.memory(
                        base64Decode(
                            _addBase64Padding(widget.post['images'][0])),
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                      )
                    : const Icon(Icons.error, size: 100),
              ),
              const SizedBox(height: 16),

              // Item Name and Menu Icon
              Text(
                widget.post['name'],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),

              // Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NPR ${widget.post['price']}',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Item Description
              const Text(
                'Description:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                widget.post['description'],
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),

              // Add a Comment Section
              const Text(
                'Add a Comment:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Type your comment...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // Display Comments as Simple Text (without boxes)
              const Text(
                'Comments:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              comments.isEmpty
                  ? const Text(
                      "No comments yet.",
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    )
                  : Column(
                      children: comments.map((comment) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            comment,
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _addComment(); // Add comment functionality
          } else if (index == 1) {
            _buyPost(); // Navigate to PaymentPage
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Add Comment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Buy Now',
          ),
        ],
      ),
    );
  }

  // Helper function to ensure base64 string has the correct padding
  String _addBase64Padding(String base64String) {
    base64String = base64String.trim();
    int paddingLength = base64String.length % 4;
    if (paddingLength > 0) {
      base64String += '=' * (4 - paddingLength); // Add required padding
    }
    return base64String;
  }

  // Handle Edit Post action
  void _editPost() {
    // Navigate to Edit Post page
  }

  // Handle Delete Post action
  void _deletePost() async {
    final url = Uri.parse('${Config.baseUrl}${Config.logoutEndpoint}');
    try {
      final response = await http.post(url, body: {
        'id': widget.post['id'].toString(),
        'username': widget.username,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post deleted successfully!')));
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${data['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to the server.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Handle Add to Cart action
  void _addToCart() {
    // Add your add to cart logic here
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart successfully!')));
  }

  // Handle Buy action (Navigate to PaymentPage)
  void _buyPost() {
    double price = widget.post['price'] * 100; // Khalti expects price in paise
    String productName = widget.post['name'];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          productName: productName,
          price: price,
          postId: widget.post['id'],
          username: widget.username,
        ),
      ),
    );
  }

  // Add comment to the list and update UI
  void _addComment() async {
    String commentText = _commentController.text;

    if (commentText.isEmpty) {
      return;
    }

    // Prepare the data for API request
    final commentData = {
      'username': widget.username,
      'comment': commentText,
    };

    final url = Uri.parse(
        '${Config.baseUrl}${Config.addcomment}'); // Replace with your PHP logout API URL

    try {
      final response = await http.post(
        url,
        body: jsonEncode(commentData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            comments.add(commentText);
            _commentController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Comment added successfully!')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${data['message']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to the server.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
