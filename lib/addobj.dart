import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

class AddObjPage extends StatefulWidget {
  final String username;

  const AddObjPage({Key? key, required this.username}) : super(key: key);

  @override
  _AddObjPageState createState() => _AddObjPageState();
}

class _AddObjPageState extends State<AddObjPage> {
  bool _isLoading = false;
  List<Uint8List> _imageBytesList = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  late String _username;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
  }

  Future<void> _pickImages() async {
    final fileInput = html.FileUploadInputElement();
    fileInput.accept = 'image/*';
    fileInput.multiple = true;
    fileInput.click();

    fileInput.onChange.listen((e) async {
      final files = fileInput.files;
      if (files!.isEmpty) {
        print("No files selected");
        return;
      }

      List<Uint8List> newImages = [];
      for (var file in files) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;
        newImages.add(reader.result as Uint8List);
      }

      setState(() {
        _imageBytesList = newImages;
        print("Selected images: ${_imageBytesList.length}");
      });
    });
  }

  Future<void> _uploadImages() async {
    if (_imageBytesList.isEmpty) {
      _showSnackBar('Please select at least one image.');
      return;
    }

    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _ageController.text.isEmpty) {
      _showSnackBar('Please fill in all fields.');
      return;
    }

    final price = double.tryParse(_priceController.text);
    final age = int.tryParse(_ageController.text);

    if (price == null) {
      _showSnackBar('Price must be a valid number.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.79/myapp_api/addobj.php'),
    );

    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['price'] = price.toString();
    request.fields['age'] = age.toString();
    request.fields['username'] = _username;

    for (int i = 0; i < _imageBytesList.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'images[]',
        _imageBytesList[i],
        filename: 'image_$i.png',
      ));
    }

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);
        for (var item in data) {
          _showSnackBar(item['message']);
        }
        _clearFields();
        Navigator.pop(context);
      } else {
        _showSnackBar('Error: ${response.statusCode} - ${responseData.body}');
      }
    } catch (error) {
      _showSnackBar('An error occurred: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearFields() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _ageController.clear();
    setState(() {
      _imageBytesList.clear();
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Images'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Upload Images',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 150,
                  child: _imageBytesList.isEmpty
                      ? const Center(child: Text('Tap to select images'))
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: _imageBytesList.length,
                          itemBuilder: (context, index) {
                            return Image.memory(
                              _imageBytesList[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                    child: Text('Error loading image'));
                              },
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _uploadImages,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            const Color.fromARGB(255, 179, 173, 190),
                      ),
                      child: const Text('Upload Images',
                          style: TextStyle(fontSize: 18)),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
