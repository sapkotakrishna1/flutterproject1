import 'package:flutter/material.dart';
import 'dart:convert'; // For base64Decode
import 'package:http/http.dart' as http;
//import 'package:myapp/payment.dart'; // Import the PaymentPage (for payment)
import 'package:myapp/updatebuyinfo.dart';
import 'config.dart'; // Your configuration file with base URL (for API endpoint)

class BuyPage extends StatefulWidget {
  final dynamic post; // Product information passed from the previous page
  final String
      username; // Automatically detected from Firebase or any auth service
  final String email; // Current logged-in user's email
  final String id; // Current logged-in user's ID
  final String
      postid; // Current logged-in user's name (if you have a user profile)

  const BuyPage({
    super.key,
    required this.postid,
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

  List<Map<String, dynamic>> comments =
      []; // List to store comments fetched from the database
  final Map<int, TextEditingController> _replyControllers =
      {}; // Map to handle replies
  bool _isSoldOut = false;

  @override
  void initState() {
    super.initState();
    // Fetch the comments when the page loads
    _fetchComments();
    _fetchPurchaseStatus(); // Fetch purchase status when the page loads
  }

  @override
  Widget build(BuildContext context) {
    String postEmail =
        widget.post['email'] ?? ''; // Safely handle null post email
    bool isPostOwner = widget.email ==
        postEmail; // Check if the logged-in user is the post owner

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deletePost(); // Call delete post functionality
              } else if (value == 'edit') {
                _editPost(); // Call edit post functionality
              } else if (value == 'addToCart') {
                _addToCart(); // Call add to cart functionality
              }
            },
            itemBuilder: (BuildContext context) {
              if (isPostOwner) {
                return const [
                  PopupMenuItem<String>(
                      value: 'edit', child: Text('Edit Post')),
                  PopupMenuItem<String>(
                      value: 'delete', child: Text('Delete Post')),
                  PopupMenuItem<String>(
                      value: 'addToCart', child: Text('Add to Cart')),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.post['images'] != null &&
                        widget.post['images'].isNotEmpty
                    ? Image.memory(
                        base64Decode(
                            _addBase64Padding(widget.post['images'][0])),
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity)
                    : const Icon(Icons.error, size: 100),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.post['name'],
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple)),
                  if (_isSoldOut)
                    ElevatedButton(
                      onPressed:
                          null, // Disable the button if the item is sold out
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      child: const Text('Sold Out',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 233, 6, 6),
                            fontWeight: FontWeight.bold,
                          )),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        String productName =
                            widget.post['name']; // Get product name
                        double price =
                            double.tryParse(widget.post['price'].toString()) ??
                                0.0; // Parse price
                        String postid =
                            widget.post['id'].toString(); // Get post ID
                        String username =
                            widget.username; // Get the logged-in username

                        _navigateToUpdateInfoPage(
                            context, username, productName, price, postid);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple),
                      child: const Text('Buy Now',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    )
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('NPR ${widget.post['price']}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Description:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.post['description'],
                  style: const TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 24),
              const Text('Add a Comment:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                          hintText: 'Type your comment...',
                          border: OutlineInputBorder()),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      _addComment(); // Call the add comment function
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Comments:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              comments.isEmpty
                  ? const Text("No comments yet.",
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic))
                  : Column(
                      children: comments.map((comment) {
                        int commentIndex = comments.indexOf(comment);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(comment['username'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(comment['comment'],
                                    style: const TextStyle(fontSize: 16)),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.reply),
                                    onPressed: () {
                                      setState(() {
                                        _replyControllers[commentIndex] =
                                            TextEditingController();
                                      });
                                    },
                                  ),
                                  if (_replyControllers
                                      .containsKey(commentIndex))
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _replyControllers[commentIndex],
                                        decoration: const InputDecoration(
                                            hintText: 'Type your reply...',
                                            border: OutlineInputBorder()),
                                      ),
                                    ),
                                  if (_replyControllers
                                      .containsKey(commentIndex))
                                    IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () {
                                        _replyToComment(commentIndex);
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _addBase64Padding(String base64String) {
    base64String = base64String.trim();
    int paddingLength = base64String.length % 4;
    if (paddingLength > 0) {
      base64String += '=' * (4 - paddingLength); // Add required padding
    }
    return base64String;
  }

  void _editPost() {
    print('Edit Post triggered');
  }

  void _deletePost() async {
    final url = Uri.parse('${Config.baseUrl}${Config.userdeletedata}');
    try {
      final response = await http.post(url, body: {
        'id': widget.post['id'].toString(),
        'username': widget.username
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post deleted successfully!')));
          Navigator.pop(context); // Pop to the previous page
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

  void _addToCart() async {
    // Retrieve the necessary data for the cart
    String productId = widget.post['id'].toString(); // Get the product ID
    String productName = widget.post['name']; // Get the product name
    double price = double.tryParse(widget.post['price'].toString()) ??
        0.0; // Get the price
    String userId = widget.id; // Get the user ID (logged-in user)
    String username = widget.username; // Get the logged-in user's username
    String email = widget.email; // Get the user's email

    // Prepare the data to send in the request body
    Map<String, String> data = {
      'product_id': productId,
      'product_name': productName,
      'price': price.toString(),
      'user_id': userId,
      'username': username,
      'image': widget.post['images'][0],
      'email': email,
    };

    final url = Uri.parse(
        '${Config.baseUrl}${Config.addcart}'); // Replace with your actual endpoint

    try {
      // Send POST request to add the item to the cart
      final response = await http.post(
        url,
        body: data,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Successfully added to the cart
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart successfully!')));
        } else {
          // Error while adding to the cart
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${data['message']}')));
        }
      } else {
        // Server error
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to the server.')));
      }
    } catch (e) {
      // Catch any errors during the network call
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _fetchComments() async {
    final url = Uri.parse('${Config.baseUrl}${Config.fetchcomment}');

    // Pass the post id as 'postid' in the query parameters
    final response = await http.get(
      url.replace(
        queryParameters: {
          'postid':
              widget.post['id'].toString(), // Ensure correct post id is passed
        },
      ),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    try {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Check if the response is successful
        if (data['status'] == 'success') {
          // Ensure the comments array exists and is not empty
          if (data['comments'] != null && data['comments'] is List) {
            List<Map<String, dynamic>> fetchedComments = [];

            for (var comment in data['comments']) {
              // Debugging: print the type and value of 'id'
              print(
                  'Comment ID: ${comment['id']} (Type: ${comment['id'].runtimeType})');

              // Check if 'id' is valid: ensure it's either an integer or a valid numeric string
              if (comment['id'] != null &&
                  (comment['id'] is int || comment['id'] is String)) {
                // Check if the string can be parsed into an integer if it's a string
                int commentId = (comment['id'] is String)
                    ? int.tryParse(comment['id'].toString())
                    : comment['id'];

                // If we have a valid commentId, add it to the list
                fetchedComments.add({
                  ...comment,
                  'id': commentId,
                });
              } else {
                print('Invalid comment ID found: $comment');
              }
            }

            // If valid comments are found, update the state
            setState(() {
              comments = fetchedComments;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No comments found.')),
            );
          }
        } else {
          //ScaffoldMessenger.of(context).showSnackBar(
          //  SnackBar(content: Text('Error: ${data['message']}')),
          //);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to the server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _fetchPurchaseStatus() async {
    final url = Uri.parse('${Config.baseUrl}${Config.fetchcodpurches}');

    // Send request to fetch the purchase details for the given post ID
    final response = await http.get(
      url.replace(
        queryParameters: {
          'postid':
              widget.post['id'].toString(), // Ensure correct post id is passed
        },
      ),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    );

    try {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          var purchaseData = data['data']; // Fetch the full record

          // Extract relevant information from the response
          String purchaseStatus =
              purchaseData['status'] ?? 'unknown'; // Default value if null
          String productName = purchaseData['product_name'] ??
              'Unknown Product'; // Default value if null
          String price =
              purchaseData['price'] ?? '0.00'; // Default value if null
          String address = purchaseData['address'] ??
              'No address provided'; // Default value if null
          String phone = purchaseData['phone'] ??
              'No phone provided'; // Default value if null
          String createdAt = purchaseData['created_at'] ??
              'Unknown Date'; // Default value if null

          // If purchase status is 'completed', disable the 'Buy Now' button and show 'Sold Out'
          setState(() {
            if (purchaseStatus == 'completed') {
              _isSoldOut = true;
            }
          });

          // You can use this data to update the UI, display the information, etc.
          print('Product Name: $productName');
          print('Price: $price');
          print('Status: $purchaseStatus');
          print('Address: $address');
          print('Phone: $phone');
          print('Created At: $createdAt');
        } else {
          //ScaffoldMessenger.of(context).showSnackBar(
          //  SnackBar(content: Text('Error: ${data['message']}')),
          //);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to the server.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _replyToComment(int commentIndex) async {
    String replyText = _replyControllers[commentIndex]?.text ?? '';

    // Validate the input
    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a reply')));
      return;
    }

    int commentId = comments[commentIndex]['id'];
    final url = Uri.parse('${Config.baseUrl}${Config.replycomment}');

    // Prepare the data for the request
    final replyData = {
      'objects_id': widget.post['id'].toString(),
      'comments_id': commentId.toString(),
      'replyusername': widget.username,
      'replycomment': replyText,
      'replyemail': widget.email,
    };

    try {
      // Send the request with JSON data in the body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(replyData), // Ensure JSON encoding
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _replyControllers[commentIndex]?.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reply added successfully!')));
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

  void _addComment() async {
    String commentText = _commentController.text;
    if (commentText.isEmpty) {
      return;
    }

    final url = Uri.parse('${Config.baseUrl}${Config.addcomment}');

    // Prepare the data for the request (JSON format)
    final commentData = {
      'username': widget.username,
      'comment': commentText,
      'email': widget.email,
      'objects_id': widget.post['id'].toString(), // Pass the post id
    };

    try {
      // Send the request with JSON data in the body
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(commentData), // Ensure JSON encoding
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            comments.add({
              'username': widget.username,
              'comment': commentText,
            });
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

  void _navigateToUpdateInfoPage(BuildContext context, String username,
      String productName, double price, String postid) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UpdateBuyInfoPage(
          productName: productName,
          price: price,
          postid: postid,
          username: username,
          email: widget.email,
          post: widget.post,
        ),
      ),
    );
  }
}
