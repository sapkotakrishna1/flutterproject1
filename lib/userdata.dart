import 'dart:convert';
import 'package:flutter/material.dart';
import 'config.dart';
import 'package:http/http.dart' as http;

class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key, required this.username});

  final String username;

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<Map<String, dynamic>>? usersData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data
  Future<void> _fetchUserData() async {
    final url = Uri.parse('${Config.baseUrl}${Config.getuserdata}');

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData is Map && jsonData.containsKey('error')) {
          setState(() {
            errorMessage = jsonData['error'];
            isLoading = false;
          });
        } else if (jsonData is List) {
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
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to load data: $error';
        isLoading = false;
      });
    }
  }

  // Confirm and delete user
  void _confirmDeleteUser(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteUser(userId);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

// Delete user and go back
  Future<void> _deleteUser(String userId) async {
    final url = Uri.parse('${Config.baseUrl}${Config.deletetdata}');

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(url, body: {'id': userId});

      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);

        if (responseJson['status'] == 'success') {
          // Go back to the previous screen after deletion
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          setState(() {
            errorMessage = 'Failed to delete user: ${responseJson['message']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to delete user. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        Navigator.pop(context);
        errorMessage = 'Error deleting user: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : usersData == null || usersData!.isEmpty
                  ? const Center(child: Text('No user data found'))
                  : ListView.builder(
                      itemCount: usersData!.length,
                      itemBuilder: (context, index) {
                        final user = usersData![index];

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
                                        _confirmDeleteUser(user['id']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
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
