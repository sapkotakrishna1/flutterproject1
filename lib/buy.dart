import 'package:flutter/material.dart';
import 'package:khalti_flutter/khalti_flutter.dart';
import 'package:khalti/khalti.dart'; // Import Khalti package
import 'dart:convert'; // Import dart:convert for base64Decode
import 'package:http/http.dart'
    as http; // Import http package for making requests

class BuyPage extends StatefulWidget {
  final dynamic post; // Product information passed from the previous page
  final String
      username; // Automatically detected from Firebase or any auth service
  final String id; // Current logged-in user's ID

  const BuyPage({
    super.key,
    required this.post,
    required this.username,
    required this.id,
  });

  @override
  _BuyPageState createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current post data
    _priceController.text = widget.post['price'].toString();
    _descriptionController.text = widget.post['description'];
  }

  @override
  Widget build(BuildContext context) {
    // Check if the logged-in user matches the post owner's username
    bool isPostOwner = widget.username == widget.post['username'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (isPostOwner)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  // Handle delete post logic here
                  _deletePost();
                } else if (value == 'edit') {
                  // Navigate to edit post page
                  _editPost();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Edit Post'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete Post'),
                ),
              ],
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Product Image at the top
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.post['images'] != null &&
                      widget.post['images'].isNotEmpty
                  ? Image.memory(
                      base64Decode(_addBase64Padding(widget.post['images'][0])),
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, size: 100);
                      },
                    )
                  : const Icon(Icons.error, size: 100),
            ),
            const SizedBox(height: 16),

            // Item Name and Menu Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.post['name'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Price and Age Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: ${widget.post['price']} NPR',
                    style: TextStyle(fontSize: 18)),
                Text('Age: ${widget.post['age']} years',
                    style: TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 16),

            // Item Description
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(widget.post['description'], style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Payment Section
            const Text(
              'Choose Payment Method:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Khalti Payment Method Button
            GestureDetector(
              onTap: () {
                double price =
                    widget.post['price'] * 100; // Khalti expects price in paise
                String productName = widget.post['name'];

                // Call Khalti payment method
                _openKhaltiPayment(context, productName, price);
              },
              child: _buildPaymentMethod('assets/khalti.png', 'Khalti'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Function to build Khalti payment method button UI (only Khalti image on the left)
  Widget _buildPaymentMethod(String iconPath, String label) {
    return Row(
      children: [
        // Khalti Image on the left
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            iconPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Image not found'));
            },
          ),
        ),
        const SizedBox(width: 16), // Space between image and any other elements
      ],
    );
  }

  // Open Khalti payment page with product and price details
  void _openKhaltiPayment(
      BuildContext context, String productName, double price) {
    Khalti.init(publicKey: "your-khalti-public-key");

    var paymentConfig = PaymentConfig(
      amount: price.toInt(), // Price in paise (1 NPR = 100 paise)
      productIdentity: 'product-${widget.post['id']}',
      productName: productName,
      productUrl: 'https://yourproducturl.com', // Optional: Provide URL here
    );

    KhaltiScope.of(context).pay(
      config: paymentConfig,
      preferences: [
        PaymentPreference
            .khalti, // This will let the user choose Khalti payment
      ],
      onSuccess: (value) {
        _handlePaymentSuccess(context, value, productName, price);
      },
      onFailure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: $error')),
        );
      },
    );
  }

  // Handle payment success and show confirmation dialog
  void _handlePaymentSuccess(
      BuildContext context, dynamic value, String productName, double price) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Purchase Confirmation'),
          content: Text(
              'Thank you, ${widget.username}, for purchasing $productName for $price NPR!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
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

  // Handle Edit Post action (navigate to Edit Page)
  void _editPost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPostPage(post: widget.post),
      ),
    );
  }

  // Handle Delete Post action
  void _deletePost() async {
    // Define the API endpoint for deleting the post
    final url = Uri.parse('https://localhost/myapp_api/delete.php');

    try {
      // Send POST request to delete the post with 'id' and 'username'
      final response = await http.post(url, body: {
        'id': widget.post['id'].toString(),
        'username': widget.username, // Include the username of the current user
      });

      // Check if the response is successful
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // If the deletion is successful
        if (data['status'] == 'success') {
          // Show a success message and navigate to home page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post deleted successfully!')),
          );
          // Navigate to home page (or any page you want)
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // If there was an error with the deletion
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${data['message']}')),
          );
        }
      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server.')),
        );
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

// Edit Post Page (for editing product details)
class EditPostPage extends StatefulWidget {
  final dynamic post;

  const EditPostPage({Key? key, required this.post}) : super(key: key);

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

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
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (NPR)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updatePost,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePost() {
    // You can update the post with the new values
    widget.post['price'] = double.parse(_priceController.text);
    widget.post['description'] = _descriptionController.text;

    // After updating, navigate back to the previous page
    Navigator.pop(context);
  }
}
