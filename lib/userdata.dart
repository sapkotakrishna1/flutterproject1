import 'dart:convert';
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class UserDataPage extends StatefulWidget {
  const UserDataPage(
      {super.key, required this.username}); // Pass username in constructor

  final String username; // Declare a username variable

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<Map<String, dynamic>>? usersData; // List to hold user data
  bool isLoading = true; // To show loading spinner while fetching data
  String errorMessage = ''; // To store error message if any

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Function to fetch user data from the API
  Future<void> _fetchUserData() async {
    final url = Uri.parse(
        '${Config.baseUrl}${Config.login}'); // Replace with your PHP logout API URL

    try {
      final response = await http.get(url);

      // Check the status code of the response
      if (response.statusCode == 200) {
        print(
            'Response body: ${response.body}'); // Print the full response for debugging

        // Decode the JSON
        var jsonData = json.decode(response.body);

        // Check if the API response contains an error
        if (jsonData is Map && jsonData.containsKey('error')) {
          setState(() {
            errorMessage = jsonData['error'];
            isLoading = false;
          });
        } else if (jsonData is List) {
          // Handle the case where the response is a list of users
          setState(() {
            usersData = List<Map<String, dynamic>>.from(jsonData);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unexpected response format';
            isLoading = false;
          });
        }
      } else {
        // Handle non-200 responses
        print('Error: Server returned status code ${response.statusCode}');
        setState(() {
          errorMessage = 'Server returned status code ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      // Handle any errors during the request
      print('Error: $error');
      setState(() {
        errorMessage = 'Failed to load data: $error';
        isLoading = false;
      });
    }
  }

  // Function to handle Delete operation
  Future<void> _deleteUser(String userId) async {
    final url = Uri.parse('http://192.168.1.81/myapp_api/deletedata.php');
    try {
      final response = await http.post(url, body: {'id': userId});

      if (response.statusCode == 200) {
        print('User deleted: ${response.body}');
        // After deletion, refresh the user data
        _fetchUserData();
      } else {
        print('Failed to delete user: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting user: $error');
    }
  }

  // Function to navigate to Edit User screen
  void _navigateToEdit(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : usersData == null || usersData!.isEmpty
                  ? const Center(child: Text('No user data found')) // No data
                  : ListView.builder(
                      itemCount:
                          usersData!.length, // Number of items in the list
                      itemBuilder: (context, index) {
                        final user =
                            usersData![index]; // Get user data at current index

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('ID: ${user['id']}'),
                                Text('Username: ${user['username']}'),
                                Text('Email: ${user['email']}'),
                                Text('Location: ${user['location']}'),
                                Text('Gender: ${user['gender']}'),
                                Text('Contact: ${user['contact']}'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _navigateToEdit(user[
                                            'id']); // Navigate to Edit page
                                      },
                                      child: const Text('Edit'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deleteUser(user['id']); // Delete user
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.red, // Red button for delete
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// Edit User Page (for editing user data)
class EditUserPage extends StatelessWidget {
  final String userId;

  const EditUserPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('Editing user with ID: $userId'), // Placeholder UI
      ),
    );
  }
}
