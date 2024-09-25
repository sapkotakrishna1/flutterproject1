import 'package:flutter/material.dart';
import 'profile.dart'; // Import the ProfilePage
import 'addobj.dart'; // Import the AddObjPage
import 'addcart.dart'; // Import the AddCartPage
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class HomePage extends StatefulWidget {
  const HomePage({super.key, required String username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the selected index
  String userName = ''; // To store the fetched username
  bool _isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget initializes
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username') ?? 'User'; // Default to 'User'
    setState(() {
      _isLoading = false; // Update loading state
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    // Navigate to the appropriate page based on the selected index
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddObjPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddCartPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()), // Show loading indicator
      );
    }

    final hour = DateTime.now().hour;
    String greeting;

    // Determine the greeting based on the time of day
    if (hour < 12) {
      greeting = 'Good Morning, $userName!';
    } else if (hour < 17) {
      greeting = 'Good Afternoon, $userName!';
    } else {
      greeting = 'Good Evening, $userName!';
    }

    const String imageUrl =
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
              Text(
                greeting,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                color: Colors.white,
                onPressed: () {
                  print("Search tapped!");
                },
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(imageUrl),
                  child: imageUrl.isEmpty
                      ? const Text('User',
                          style: TextStyle(color: Colors.white))
                      : null,
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to the Home Page! $userName!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
