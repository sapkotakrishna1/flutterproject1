import 'package:flutter/material.dart';
import 'package:myapp/buy.dart';
import 'profile.dart';
import 'addobj.dart';
import 'addcart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  final String username;
  final String email;
  final String userId;

  const HomePage({
    Key? key,
    required this.username,
    required this.email,
    required this.userId,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the selected index
  String userName = ''; // Store the fetched username
  List<dynamic> posts = []; // List to store posts
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on initialization
    _fetchPosts(); // Fetch posts from API
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username') ?? 'User'; // Default to 'User'
    setState(() {});
  }

  // Fetch posts from the API
  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true; // Set loading state
    });
    try {
      final response =
          await http.get(Uri.parse('http://localhost/myapp_api/post.php'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          posts = jsonResponse; // Store fetched posts
          isLoading = false; // Update loading state
        });
      } else {
        setState(() {
          isLoading = false; // Update loading state on error
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Update loading state on error
      });
    }
  }

  // Handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
    if (index == 0) {
      _fetchPosts(); // Refresh posts for Home
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
                      backgroundImage: NetworkImage(
                          'https://yourprofileimageurl.com/image.jpg'),
                      child: const Text('User',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : posts.isEmpty
                    ? const Center(child: Text('No posts available.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // More options button at the top right
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      onPressed: () {
                                        print(
                                            'More options for ${post['name']}');
                                      },
                                    ),
                                  ),
                                  // Username
                                  Text(post['username'],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic)),
                                  const SizedBox(height: 4),
                                  // Created at
                                  Text(post['created_at'],
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  // Name
                                  Text(post['name'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  // Description
                                  Text(post['description'],
                                      style: const TextStyle(height: 1.4)),
                                  const SizedBox(height: 8),
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      post['image'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Price and Age
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                          'Price: ${post['price']} NPR'), // Changed to NPR
                                      Text('Age: ${post['age']} years'),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  // Buy Button and Chat Icon
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    BuyPage(post: post)),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 128, 115, 151),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Buy'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chat),
                                        color: const Color.fromARGB(
                                            255, 109, 96, 133),
                                        onPressed: () {
                                          print(
                                              'Chat icon pressed for ${post['name']}');
                                        },
                                      ),
                                    ],
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
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
