import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // For desktop/web platforms
import 'dart:io'; // For working with images (File) on mobile and desktop
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:typed_data'; // For working with byte data on the web

class AddObjPage extends StatefulWidget {
  final String username;

  const AddObjPage({super.key, required this.username});

  @override
  _AddObjPageState createState() => _AddObjPageState();
}

class _AddObjPageState extends State<AddObjPage> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  List<File> _selectedImages = []; // Variable to store the selected images
  List<Uint8List> _selectedWebImages = []; // For web images as byte data

  late String _username;

  @override
  void initState() {
    super.initState();
    _username = widget.username; // Get username from the widget
  }

  // Method to select images from gallery or camera, platform-dependent
  Future<void> _pickImages() async {
    final picker = ImagePicker();

    try {
      if (kIsWeb) {
        // For web platform, handle the file picking and image processing differently
        final result = await FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: true);
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            // Convert the picked files to byte arrays for web
            _selectedWebImages = result.files.map((e) => e.bytes!).toList();
          });
        } else {
          _showSnackBar('No files selected.');
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        // For mobile platforms (Android, iOS), use ImagePicker to pick multiple images
        final pickedFiles = await picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            // Convert picked files to File objects for mobile
            _selectedImages =
                pickedFiles.map((file) => File(file.path)).toList();
          });
        } else {
          _showSnackBar('No images selected.');
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // For desktop platforms (Windows, macOS, Linux), use FilePicker to pick multiple images
        final result = await FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: true);
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            // Convert the picked files to File objects for desktop
            _selectedImages = result.files.map((e) => File(e.path!)).toList();
          });
        } else {
          _showSnackBar('No files selected.');
        }
      }
    } catch (e) {
      _showSnackBar('Error picking image(s): $e');
    }
  }

  // Convert the selected image to Base64 string
  Future<String> _getBase64String(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  // Method to upload form data along with the selected images (Base64-encoded)
  Future<void> _uploadImages() async {
    // Validate fields
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _ageController.text.isEmpty ||
        (_selectedImages.isEmpty && _selectedWebImages.isEmpty)) {
      _showSnackBar('Please fill in all fields and select images.');
      return;
    }

    final price = double.tryParse(_priceController.text);
    final age = int.tryParse(_ageController.text);

    if (price == null) {
      _showSnackBar('Price must be a valid number.');
      return;
    }

    if (age == null) {
      _showSnackBar('Age must be a valid number.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Prepare the request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.81/myapp_api/addobj.php'),
    );

    // Add fields to the request
    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['price'] = price.toString();
    request.fields['age'] = age.toString();
    request.fields['username'] = _username;

    try {
      // Add images for mobile platform (Base64-encoded)
      for (var image in _selectedImages) {
        final base64String = await _getBase64String(image);
        request.fields['images[]'] = base64String;
      }

      // Add images for web platform (Base64-encoded)
      for (var imageBytes in _selectedWebImages) {
        final base64String = base64Encode(imageBytes);
        request.fields['images[]'] = base64String;
      }
    } catch (e) {
      _showSnackBar('Error adding images to the request: $e');
      return;
    }

    // Send the request
    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      // Check if the response body contains HTML (indicating an error page)
      if (responseData.body.startsWith('<')) {
        _showSnackBar(
            'Server error: Received an HTML response instead of JSON.');
        return;
      }

      // Decode the JSON response safely
      final data = json.decode(responseData.body);
      if (data is Map<String, dynamic>) {
        if (data['status'] == 'success') {
          _showSnackBar(data['message']);
          _clearFields();
          Navigator.pop(context);
        } else {
          _showSnackBar(data['message']);
        }
      } else {
        _showSnackBar('Unexpected response format.');
      }
    } catch (e) {
      _showSnackBar('Error occurred: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Clear form fields after successful upload
  void _clearFields() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _ageController.clear();
    setState(() {
      _selectedImages = []; // Clear the selected images
      _selectedWebImages = []; // Clear the selected web images
    });
  }

  // Show snack bar messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Object'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Text
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Add Object Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Name field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // Description field
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),

              // Price field
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),

              // Age field
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Image Picker button with Icon
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text('Pick Images'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Display the selected images based on platform
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedImages.map((image) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        image,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              if (_selectedWebImages.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _selectedWebImages.map((imageBytes) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        imageBytes,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadImages,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Submit Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
