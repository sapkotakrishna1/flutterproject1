import 'package:flutter/material.dart';

class BuyPage extends StatelessWidget {
  final dynamic post;

  const BuyPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(); // Controller for user's name input

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Purchase'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Name
            Text(
              post['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Price and Age Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Price: ${post['price']} NPR'),
                Text('Age: ${post['age']} years'),
              ],
            ),
            const SizedBox(height: 16),
            // Item Description
            Text(
              'Description:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(post['description']),
            const SizedBox(height: 16),
            // User Name Input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Payment Options
            Text(
              'Choose Payment Method:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Payment Method Button
            GestureDetector(
              onTap: () {
                String userName = nameController.text;
                double price =
                    post['price']; // Assuming post['price'] is a double
                String productName = post['name']; // Get product name

                if (userName.isNotEmpty) {
                  // Implement your payment processing logic here
                  _processPayment(context, productName, price, userName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your name')),
                  );
                }
              },
              child: _buildPaymentMethod('assets/khalti.png', 'Khalti'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String iconPath, String label) {
    return Column(
      children: [
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
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  void _processPayment(
      BuildContext context, String productName, double price, String userName) {
    // Placeholder for your payment processing logic
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Purchase Confirmation'),
          content: Text(
              'Thank you, $userName, for your purchase of $productName at $price NPR!'),
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
}
