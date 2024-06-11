import 'dart:convert';
import 'package:buddy_client_side/src/utilities/data_structures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  final int userId;

  const MessagesScreen({super.key, required this.userId});

  @override
  MessagesScreenState createState() => MessagesScreenState();
}

class MessagesScreenState extends State<MessagesScreen> {
  List<Map<String, dynamic>> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    final response = await http.get(
      Uri.parse('$localUri/general/get_chat_contacts.php?user_id=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> contacts = jsonDecode(response.body);
      setState(() {
        _contacts = contacts.map((c) => Map<String, dynamic>.from(c)).toList();
      });
    }
  }

  String _getProfilePicturePath(String? picturePath, String role) {
    if (picturePath == null || picturePath.isEmpty) {
      return ''; // Return empty path if no picture is available
    }
    String directory = (role.toLowerCase() == 'guide') ? 'guide' : 'tourist';
    return '$localUri/uploads/$directory/$picturePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.teal,
      ),
      body: _contacts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                String profilePicturePath = _getProfilePicturePath(contact['picture_path'], contact['role']);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: profilePicturePath.isNotEmpty
                          ? NetworkImage(profilePicturePath)
                          : null,
                      backgroundColor: Colors.teal,
                      child: profilePicturePath.isEmpty
                          ? Text(
                              contact['contact_name'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
                    ),
                    title: Text(
                      '${contact['contact_name']} ${contact['contact_surname']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact['last_message'] ?? 'No messages yet'),
                        Text(
                          contact['last_message_timestamp'] ?? '',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            userId: widget.userId,
                            receiverId: contact['contact_id'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
