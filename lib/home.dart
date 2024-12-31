import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/buy.dart';
import 'profile.dart';
import 'addobj.dart';
import 'addcart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String username;
  final String email;
  final String id;

  const HomePage({
    super.key,
    required this.username,
    required this.email,
    required this.id,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String userName = '';
  List<dynamic> posts = [];
  bool isLoading = true;

  String baseUrl = 'http://192.168.1.81/myapp_api/post.php';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchPosts();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username') ?? 'User';
    setState(() {});
  }

  // Fetch posts from the API and sort them by creation time (most recent first)
  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Assuming each post has a 'created_at' field with a timestamp
        jsonResponse.sort((a, b) {
          // If created_at is in ISO 8601 format, use DateTime.parse to compare
          DateTime dateA = DateTime.parse(a['created_at']);
          DateTime dateB = DateTime.parse(b['created_at']);
          return dateB.compareTo(dateA); // Descending order (latest first)
        });

        setState(() {
          posts = jsonResponse;
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper function to ensure base64 string has the correct padding
  String _addBase64Padding(String base64String) {
    base64String = base64String.trim();
    int paddingLength = base64String.length % 4;
    if (paddingLength > 0) {
      base64String += '=' * (4 - paddingLength); // Add required padding
    }
    return base64String; // Return the cleaned base64 string
  }

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _fetchPosts();
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddObjPage(username: widget.username)),
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
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Good Morning, $userName!'
        : hour < 17
            ? 'Good Afternoon, $userName!'
            : 'Good Evening, $userName!';

    // Extract first letter of the username to display as initials
    String firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
              Row(
                children: [
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
                          builder: (context) => ProfilePage(
                            userName: widget.username,
                            email: widget.email,
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color.fromARGB(255, 201, 199, 204),
                      child: Text(
                        firstLetter, // Display the first letter of the user's name
                        style: const TextStyle(
                          color: Color.fromARGB(255, 15, 15, 15),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap the body with SingleChildScrollView to prevent overflow
        child: Column(
          children: [
            isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : posts.isEmpty
                    ? const Center(child: Text('No posts available.'))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 items per row
                          crossAxisSpacing: 10, // Spacing between columns
                          mainAxisSpacing: 10, // Spacing between rows
                          childAspectRatio: 0.75, // Maintain image aspect ratio
                        ),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuyPage(
                                    post: post,
                                    username: widget.username,
                                    id: widget.id,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Image section - takes 80% of space
                                  Expanded(
                                    flex: 8, // 80% space for the image
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: post['images'] != null &&
                                              post['images'].isNotEmpty
                                          ? Image.memory(
                                              base64Decode(
                                                _addBase64Padding(
                                                    post['images'][0]),
                                              ),
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              width: double.infinity,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.error);
                                              },
                                            )
                                          : const Icon(Icons.error),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Name and Price section - takes 20% of space
                                  Expanded(
                                    flex: 2, // 20% space for name and price
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            post['name'] ?? 'Unnamed Product',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: ${post['price']} NPR',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
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
        onTap: _onItemTapped,
      ),
    );
  }
}
