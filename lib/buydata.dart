import 'package:flutter/material.dart';

class BuyDataPage extends StatelessWidget {
  final String username;

  BuyDataPage({super.key, required this.username});

  // Dummy list of data items available for purchase
  final List<Map<String, String>> dataItems = [
    {'name': 'Data Package 1', 'price': '10 USD'},
    {'name': 'Data Package 2', 'price': '20 USD'},
    {'name': 'Data Package 3', 'price': '30 USD'},
  ];

  // Handle item purchase (for now, just print the purchase)
  void _buyItem(BuildContext context, String itemName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Successful'),
        content: Text('You have purchased $itemName.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Data - $username'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: dataItems.length,
          itemBuilder: (context, index) {
            final item = dataItems[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(item['name']!),
                subtitle: Text(item['price']!),
                trailing: ElevatedButton(
                  onPressed: () => _buyItem(context, item['name']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Buy'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
