import 'package:flutter/material.dart';
import 'profile.dart'; // Import the ProfilePage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current hour
    final hour = DateTime.now().hour;
    String greeting;

    // Determine the greeting based on the time of day
    if (hour < 12) {
      greeting = 'Good Morning!';
    } else if (hour < 17) {
      greeting = 'Good Afternoon!';
    } else {
      greeting = 'Good Evening!';
    }

    // Profile image URL
    final String imageUrl =
        'https://yourprofileimageurl.com/image.jpg'; // Replace with your image URL

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back arrow
        backgroundColor: Colors.deepPurple,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting text
              Text(
                greeting,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Favorites icon
              IconButton(
                icon: const Icon(Icons.favorite),
                color: Colors.white,
                onPressed: () {
                  // Handle favorites action
                  print("Favorites tapped!");
                },
                padding: const EdgeInsets.all(10), // Remove default padding
              ),
              // Search icon
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.white,
                onPressed: () {
                  // Handle search action
                  print("Search tapped!");
                },
                padding: const EdgeInsets.all(10), // Remove default padding
              ),
              // Profile image
              GestureDetector(
                onTap: () {
                  // Navigate to ProfilePage when the profile is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 20, // Adjust the radius for a smaller circle
                  backgroundImage: NetworkImage(imageUrl),
                  child: imageUrl.isEmpty
                      ? const Text('Your Name',
                          style: TextStyle(color: Colors.white))
                      : null,
                ),
              ),
              const SizedBox(width: 5), // Smaller spacing
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Page!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
