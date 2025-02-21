import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart'; // Assuming you have your API endpoints in this file

class BuyDataPage extends StatefulWidget {
  final String username;

  const BuyDataPage({super.key, required this.username});

  @override
  _PaymentDataPageState createState() => _PaymentDataPageState();
}

class _PaymentDataPageState extends State<BuyDataPage> {
  List<Map<String, dynamic>>? paymentData; // List to hold fetched payment data
  bool isLoading = true; // To handle loading state
  String errorMessage = ''; // To store error message

  @override
  void initState() {
    super.initState();
    _fetchPaymentData(); // Fetch the payment data when the page is initialized
  }

  // Function to fetch payment data from the API
  Future<void> _fetchPaymentData() async {
    final url = Uri.parse(
        '${Config.baseUrl}${Config.getcodpurches}'); // Replace with your actual API endpoint
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        // Decode the JSON response
        var jsonData = json.decode(response.body);

        if (jsonData is List) {
          setState(() {
            paymentData = List<Map<String, dynamic>>.from(jsonData);
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

  // Function to determine the color based on the status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green; // Green for complete
      case 'pending':
        return Colors.yellow; // Yellow for pending
      case 'failed':
        return Colors.red; // Red for failed
      default:
        return Colors.grey; // Default color if status is unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Data'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : paymentData == null || paymentData!.isEmpty
                  ? const Center(child: Text('No payment data available'))
                  : ListView.builder(
                      itemCount: paymentData!.length,
                      itemBuilder: (context, index) {
                        final payment = paymentData![index];

                        // Get the color based on the status
                        Color statusColor =
                            _getStatusColor(payment['status'] ?? '');

                        // Print fields for debugging
                        print('PostId: ${payment['postid']}');
                        print('Product Name: ${payment['product_name']}');
                        print('Price: ${payment['price']}');
                        print('Address: ${payment['address']}');
                        print('Phone: ${payment['phone']}');
                        print('Status: ${payment['status']}');
                        print('Created At: ${payment['created_at']}');

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('PostId: ${payment['postid'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text(
                                    'Product Name: ${payment['product_name'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Price: \$${payment['price'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Address: ${payment['address'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Text('Phone: ${payment['phone'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  color:
                                      statusColor, // Use the determined color
                                  child: Text(
                                    'Status: ${payment['status'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .white, // White text on colored background
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                    'Created At: ${payment['created_at'] ?? 'N/A'}'),
                                const SizedBox(height: 10),
                                // Optional image field (if exists)
                                payment['images'] != null
                                    ? Image.memory(
                                        base64Decode(payment['images']),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : const SizedBox.shrink(),
                                // Delete button (if required)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
