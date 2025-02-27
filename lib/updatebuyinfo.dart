import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Google Maps package
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:http/http.dart' as http; // Import HTTP package
import 'package:myapp/config.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class UpdateBuyInfoPage extends StatefulWidget {
  final String productName;
  final double price;
  final String postid;
  final String username;
  final String email;
  final dynamic post;

  const UpdateBuyInfoPage({
    Key? key,
    required this.productName,
    required this.price,
    required this.postid,
    required this.username,
    required this.email,
    required this.post,
  }) : super(key: key);

  @override
  _UpdateBuyInfoPageState createState() => _UpdateBuyInfoPageState();
}

class _UpdateBuyInfoPageState extends State<UpdateBuyInfoPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isKhaltiSelected = false;
  bool isMapSelected = false; // Flag to track if map is selected for address
  bool isCodSelected = false; // Flag to track if Cash on Delivery is selected

  late GoogleMapController mapController;
  late LatLng _selectedLocation;

  final LatLng kathmandu = LatLng(27.7172, 85.3240); // Kathmandu
  final LatLng lalitpur = LatLng(27.5662, 85.3240); // Lalitpur
  final LatLng bhaktapur = LatLng(27.6755, 85.4270); // Bhaktapur

  @override
  void initState() {
    //String postEmail =
    //    widget.post['email'] ?? ''; // Safely handle null post email
    super.initState();
    _selectedLocation = kathmandu; // Default to Kathmandu coordinates
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address cannot be empty';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }
    if (!RegExp(r'^[9][678][0-9]{8}$').hasMatch(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
    });
  }

  Future<void> _setAddressFromMap() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        _addressController.text =
            '${placemark.name}, ${placemark.locality}, ${placemark.country}';
      } else {
        _addressController.text = 'Address not found';
      }
    } catch (e) {
      print("Error: $e");
      _addressController.text = 'Error getting address';
    }
  }

  void _initiateKhaltiPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    final paymentData = {
      'amount': (widget.price * 100).toInt(), // Convert price to paisa
      'product_identity': widget.postid,
      'product_name': widget.productName,
      'user_phone': _phoneController.text, // Send the user's phone number
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.172/myapp_api/verify_payments.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['error']}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment Verified! Redirecting...')),
          );

          // Assuming the backend returns a payment URL
          String paymentUrl = responseData[
              'https://dev.khalti.com/api/v2/epayment/initiate/']; // Replace with actual key
          launchKhaltiPayment(paymentUrl); // Call method to launch payment page
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment request failed: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void launchKhaltiPayment(String paymentUrl) async {
    if (await canLaunch(paymentUrl)) {
      await launch(paymentUrl);
    } else {
      throw 'Could not open the payment page';
    }
  }

  void _handleCodPurchase() async {
    final purchaseData = {
      'postid': widget.postid,
      'price': widget.price,
      'product_name': widget.productName,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'email': widget.post['email'], // Post owner's email
    };

    try {
      // Make the initial purchase request to confirm the purchase
      final response = await http.post(
        Uri.parse('${Config.baseUrl}${Config.codpurches}'),
        body: json.encode(purchaseData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase confirmed with Cash on Delivery!'),
            ),
          );

          // Navigate back after email is sent
          Navigator.pop(context);

          // Send email to the post owner after successful purchase
          await _sendConfirmationEmail(purchaseData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request failed: ${response.statusCode}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

// Function to send a confirmation email to the post owner
  Future<void> _sendConfirmationEmail(Map<String, dynamic> purchaseData) async {
    try {
      final emailData = {
        'postid': purchaseData['postid'],
        'product_name': purchaseData['product_name'],
        'price': purchaseData['price'],
        'address': purchaseData['address'],
        'phone': purchaseData['phone'],
        'email': purchaseData['email'], // Post owner's email
      };

      final emailResponse = await http.post(
        Uri.parse(
            '${Config.baseUrl}${Config.codpurchesemail}'), // Your email endpoint
        body: json.encode(emailData),
      );

      if (emailResponse.statusCode == 200) {
        final emailResponseData = json.decode(emailResponse.body);
        if (emailResponseData['success']) {
          print('Email sent successfully!');
        } else {
          print('Error: ${emailResponseData['message']}');
        }
      } else {
        print('Email request failed: ${emailResponse.statusCode}');
      }
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Purchase Info'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Post ID: ${widget.postid}',
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              Text(
                'email: ${widget.post['email']} ',
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),

              Text(
                'Product: ${widget.productName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              Text(
                'Price: NPR ${widget.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 20),

              // Address field
              const Text(
                'Enter Your Address:',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Enter Address Manually'),
                  Checkbox(
                    value: !isMapSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        isMapSelected = !value!;
                      });
                    },
                  ),
                  const Text('Select Address from Map'),
                  Checkbox(
                    value: isMapSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        isMapSelected = value!;
                      });
                    },
                  ),
                ],
              ),

              if (!isMapSelected) ...[
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    hintText: 'Your Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.deepPurple, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 16.0),
                  ),
                  maxLines: 3,
                  validator: _validateAddress,
                ),
              ] else ...[
                const Text(
                  'Select Your Address on the Map:',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 250,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: kathmandu,
                      zoom: 12,
                    ),
                    onCameraMove: _onCameraMove,
                    markers: {
                      Marker(
                        markerId: MarkerId('selected-location'),
                        position: _selectedLocation,
                        infoWindow: InfoWindow(title: 'Selected Location'),
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _setAddressFromMap,
                  child: const Text('Set Address From Map'),
                ),
              ],

              const SizedBox(height: 20),

              // Phone number field
              const Text(
                'Enter Your Phone Number:',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                ),
                maxLength: 10,
                validator: _validatePhone,
              ),
              const SizedBox(height: 20),

              // Payment method selection
              const Text(
                'Choose Your Payment Method:',
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 10),

              //GestureDetector(
              //  onTap: () {
              //    setState(() {
              //      isKhaltiSelected = !isKhaltiSelected;
              //      if (isKhaltiSelected) {
              //        isCodSelected = false;
              //      }
              //    });
              //  },
              //  child: Container(
              //    decoration: BoxDecoration(
              //      borderRadius: BorderRadius.circular(8),
              //      border: isKhaltiSelected
              //          ? Border.all(color: Colors.deepPurple, width: 3)
              //          : Border.all(color: Colors.grey, width: 2),
              //    ),
              //    child: Stack(
              //      children: [
              //        Center(
              //          child: Image.asset(
              //            'assets/khalti.png',
              //            width: 200,
              //            height: 50,
              //            fit: BoxFit.contain,
              //          ),
              //        ),
              //        if (isKhaltiSelected)
              //          const Positioned(
              //            right: 0,
              //            top: 0,
              //            child: Icon(
              //              Icons.check_circle,
              //              color: Colors.green,
              //              size: 30,
              //            ),
              //          ),
              //      ],
              //    ),
              //  ),
              //),
              const SizedBox(height: 20),

              // Cash on Delivery option
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCodSelected = !isCodSelected;
                    if (isCodSelected) {
                      isKhaltiSelected = false;
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isCodSelected ? Colors.deepPurple : Colors.grey,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_money,
                              size: 40, color: Colors.green),
                          Text('Cash on Delivery'),
                        ],
                      ),
                      if (isCodSelected)
                        const Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 30,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Confirm Purchase button
              GestureDetector(
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (isKhaltiSelected) {
                      _initiateKhaltiPayment();
                    } else if (isCodSelected) {
                      _handleCodPurchase();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select a payment method')),
                      );
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Confirm Purchase',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 190, 142, 142)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
