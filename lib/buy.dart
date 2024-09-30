import 'package:flutter/material.dart';
import 'khalti.dart'; // Import the Khalti payment file
// Import your Esewa payment file if you have one

class BuyPage extends StatelessWidget {
  final dynamic post;

  const BuyPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            // Payment Options
            Text(
              'Choose Payment Method:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Payment Method Buttons with Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Khalti Button
                GestureDetector(
                  onTap: () {
                    KhaltiPayment.processPayment(context, post);
                  },
                  child: _buildPaymentMethod('assets/khalti.png', 'Khalti'),
                ),
                // Esewa Button
                GestureDetector(
                  onTap: () {
                    // Call your Esewa payment method here
                    //EsewaPayment.processPayment(context, post);
                  },
                  child: _buildPaymentMethod('assets/esewa.png', 'Esewa'),
                ),
              ],
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
}
