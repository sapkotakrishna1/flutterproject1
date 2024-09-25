import 'package:flutter/material.dart';
import 'login.dart'; // Import the login.dart file
import 'reg.dart'; // Import the registration page if you have one

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restore',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Set LoginPage as the home
      routes: {
        '/reg': (context) =>
            const RegisterPage(), // Define route for registration page
      },
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}
