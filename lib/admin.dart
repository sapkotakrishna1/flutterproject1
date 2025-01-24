import 'package:flutter/material.dart';
import 'package:myapp/postdata.dart'; // Import PostData.dart
import 'package:myapp/userdata.dart'; // Import UserData.dart
import 'package:myapp/buydata.dart';
import 'package:myapp/adminprofile.dart'; // Import AdminProfile.dart

class AdminPage extends StatelessWidget {
  final String username;
  final String email;

  const AdminPage({super.key, required this.username, required this.email});

  // Navigate to UserDataPage
  void _navigateToUserData(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDataPage(username: username),
      ),
    );
  }

  // Navigate to PostDataPage
  void _navigateToPostData(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDataPage(username: username),
      ),
    );
  }

  // Navigate to BuyDataPage
  void _navigateToBuyData(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyDataPage(username: username),
      ),
    );
  }

  // Navigate to AdminProfilePage
  void _navigateToAdminProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdminProfilePage(username: username, email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the first letter of the username
    String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : "";

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), // Standard app bar height
        child: AppBar(
          automaticallyImplyLeading: false, // Disable the back button
          title: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Welcome message
                Text(
                  'Welcome, Admin $username',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // CircleAvatar with first letter of the username and logout functionality
                GestureDetector(
                  onTap: () {
                    _navigateToAdminProfile(
                        context); // Navigate to AdminProfilePage
                  },
                  child: CircleAvatar(
                    radius: 20, // Size of the circle
                    backgroundColor: const Color.fromARGB(
                        255, 8, 8, 8), // Circle background color
                    child: Text(
                      firstLetter, // First letter of username
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.blue, // Standard app bar background color
          elevation: 0,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 12.0, // Space between AppBar and container
          ),

          // First Container
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0), // Container radius
            child: Container(
              width: double.infinity, // Container takes up full width
              height: 140, // Adjusted height for better spacing
              color: Color.fromARGB(255, 219, 208, 208), // Container color
              child: Padding(
                padding:
                    const EdgeInsets.all(16.0), // Padding for better spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "User Data" text at the top of the first container
                    const Text(
                      'User Data', // Text inside the container
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            20, // Increased font size for better visibility
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 15), // Space between the text and the boxes
                    // Row to hold two 50x50 boxes horizontally (larger box size)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align items to the left
                      children: [
                        // First box - User Data Box
                        GestureDetector(
                          onTap: () => _navigateToUserData(
                              context), // Navigate to UserDataPage
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                            child: Container(
                              width: 60, // Box size
                              height: 60, // Box size
                              color: Colors.blue, // Box color
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person,
                                      color: Colors.white), // User icon
                                  SizedBox(
                                      height: 5), // Space between icon and text
                                  Text(
                                    'User Data', // Text below the icon
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // Font size for label
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 20), // Space between the two boxes
                        // Second box - Post Data Box
                        GestureDetector(
                          onTap: () => _navigateToPostData(
                              context), // Navigate to PostDataPage
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                            child: Container(
                              width: 60, // Box size
                              height: 60, // Box size
                              color: Colors.green, // Box color
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.post_add,
                                      color: Colors.white), // Post icon
                                  SizedBox(
                                      height: 5), // Space between icon and text
                                  Text(
                                    'Post Data', // Text below the icon
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // Font size for label
                                    ),
                                  ),
                                ],
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
          ),

          const SizedBox(height: 20), // Space between the two containers

          // Second Container
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0), // Container radius
            child: Container(
              width: double.infinity, // Container takes up full width
              height: 140, // Adjusted height for better spacing
              color: Color.fromARGB(255, 216, 206, 206), // Container color
              child: Padding(
                padding:
                    const EdgeInsets.all(16.0), // Padding for better spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Post Data" text at the top of the second container
                    const Text(
                      'Payment Data', // Text inside the container
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            20, // Increased font size for better visibility
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 15), // Space between the text and the boxes
                    // Row to hold two 50x50 boxes horizontally (larger box size)
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start, // Align items to the left
                      children: [
                        // First box - User Data Box
                        GestureDetector(
                          onTap: () => _navigateToBuyData(
                              context), // Navigate to UserDataPage
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
                            child: Container(
                              width: 60, // Box size
                              height: 60, // Box size
                              color: Colors.blue, // Box color
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.payment,
                                      color: Colors.white), // User icon
                                  SizedBox(
                                      height: 5), // Space between icon and text
                                  Text(
                                    'Buy Data', // Text below the icon
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12, // Font size for label
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: 20), // Space between the two boxes
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
