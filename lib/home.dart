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
  int _selectedIndex = 0;
  String userName = '';
  List<dynamic> posts = [];
  bool isLoading = true;

  get baseUrl => null; // Adjust this if needed.

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchPosts();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('username') ?? 'User';
    setState(() {});
  }

  Future<void> _fetchPosts() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('http://localhost/myapp_api/post.php'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
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
                      backgroundImage: NetworkImage(
                          'https://yourprofileimageurl.com/image.jpg'), // Replace with actual URL
                      child: const Text('U',
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
                ? const Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
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
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                          post['user_image'] ??
                                              'https://via.placeholder.com/150', // Fallback image
                                        ),
                                        child: const Text(
                                          'U',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 8), // Spacing
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              post['userName'] ?? userName,
                                              style: const TextStyle(
                                                  color: Colors.deepPurple,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.more_vert),
                                              color: Colors.deepPurple,
                                              onPressed: () {
                                                print(
                                                    'More options for ${post['name']}');
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    post['created_at'] ?? 'Date not available',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post['name'] ?? 'Unnamed Product',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post['description'] ?? 'No description',
                                    style: const TextStyle(height: 1.4),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      post['image'] != null &&
                                              post['image'].isNotEmpty
                                          ? '$baseUrl${post['image']}'
                                          : 'http://localhost/myapp_api/post.php', // Fallback image
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Price: ${post['price']} NPR'),
                                      Text('Age: ${post['age']} years'),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
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
                                          backgroundColor: Colors.deepPurple,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Buy'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.chat),
                                        color: Colors.deepPurple,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
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
