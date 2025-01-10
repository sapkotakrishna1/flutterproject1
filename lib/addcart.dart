import 'package:flutter/material.dart';

class AddCartPage extends StatefulWidget {
  const AddCartPage({super.key});

  @override
  _AddCartPageState createState() => _AddCartPageState();
}

class _AddCartPageState extends State<AddCartPage> {
  // List to store cart items
  List<Map<String, dynamic>> cartItems = [];

  // Controllers and variables for form inputs
  final TextEditingController itemNameController = TextEditingController();
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add to Cart'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Item Name Input Field
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Dropdown
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
                      setState(() {
                        quantity = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add to Cart Button
            ElevatedButton(
              onPressed: () {
                final itemName = itemNameController.text;

                // If item name is not empty, add to cart
                if (itemName.isNotEmpty) {
                  setState(() {
                    cartItems.add({
                      'name': itemName,
                      'quantity': quantity,
                    });
                  });

                  // Clear the text field for the next item
                  itemNameController.clear();

                  // Show a Snackbar for confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$itemName added to cart!')),
                  );
                }
              },
              child: const Text('Add to Cart'),
            ),
            const SizedBox(height: 20),

            // Display Cart Items
            if (cartItems.isNotEmpty) ...[
              const Text(
                'Cart Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // ListView to show cart items
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return ListTile(
                      title: Text(cartItem['name']),
                      subtitle: Text('Quantity: ${cartItem['quantity']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            cartItems.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
