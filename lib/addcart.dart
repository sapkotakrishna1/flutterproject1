import 'package:flutter/material.dart';

class AddCartPage extends StatelessWidget {
  const AddCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController itemNameController = TextEditingController();
    int quantity = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Cart'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<int>(
                  value: quantity,
                  items: List.generate(10, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      quantity = newValue;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle add to cart action
                final itemName = itemNameController.text;

                // For now, just print to console
                print('Item Added to Cart: $itemName, Quantity: $quantity');

                // Optionally, clear the fields
                itemNameController.clear();

                // Show a Snackbar for confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$itemName added to cart!')),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
