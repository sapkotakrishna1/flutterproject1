import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChangeProfilePicturePage extends StatefulWidget {
  const ChangeProfilePicturePage({super.key});

  @override
  _ChangeProfilePicturePageState createState() =>
      _ChangeProfilePicturePageState();
}

class _ChangeProfilePicturePageState extends State<ChangeProfilePicturePage> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update the image file
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile Picture'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? const CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 50,
                    ),
                  )
                : CircleAvatar(
                    radius: 100,
                    backgroundImage: FileImage(_image!),
                  ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Show a dialog to choose between gallery or camera
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Choose an option'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _pickImage(ImageSource.gallery); // Pick from gallery
                          Navigator.of(context).pop();
                        },
                        child: const Text('Gallery'),
                      ),
                      TextButton(
                        onPressed: () {
                          _pickImage(ImageSource.camera); // Pick from camera
                          Navigator.of(context).pop();
                        },
                        child: const Text('Camera'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Change Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
