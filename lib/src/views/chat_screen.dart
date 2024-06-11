import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utilities/data_structures.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final int receiverId;
  final WebSocketChannel channel;

  ChatScreen({super.key, required this.userId, required this.receiverId})
      : channel = IOWebSocketChannel.connect('ws://192.168.1.105:8080');

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  String receiverName = '';
  String receiverPicturePath = '';

  @override
  void initState() {
    super.initState();
    _loadReceiverDetails();
    _loadMessages();
    widget.channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      setState(() {
        _messages.add(decodedMessage);
        _scrollToEndIfNeeded();
      });
    });
  }

  void _loadReceiverDetails() async {
    final response = await http.get(
      Uri.parse('$localUri/general/get_user_details.php?user_id=${widget.receiverId}'),
    );

    if (response.statusCode == 200) {
      final userDetails = jsonDecode(response.body);
      setState(() {
        receiverName = '${userDetails['name']} ${userDetails['surname']}';
        String role = userDetails['role'];
        receiverPicturePath = _getProfilePicturePath(userDetails['picture_path'], role);
      });
    }
  }

  void _loadMessages() async {
    final response = await http.get(
      Uri.parse('$localUri/general/get_messages.php?user_id=${widget.userId}&contact_id=${widget.receiverId}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> messages = jsonDecode(response.body);
      setState(() {
        _messages.addAll(messages.map((m) => Map<String, dynamic>.from(m)).toList());
        _scrollToEnd();
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = {
        'sender_id': widget.userId,
        'receiver_id': widget.receiverId,
        'content': _controller.text,
        'timestamp': DateTime.now().toIso8601String(), // Add timestamp when sending
      };
      widget.channel.sink.add(jsonEncode(message));
      setState(() {
        _messages.add(message);
        _scrollToEnd();
      });
      _controller.clear();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _scrollToEndIfNeeded() {
    if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
      _scrollToEnd();
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
  void dispose() {
    widget.channel.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (receiverPicturePath.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(receiverPicturePath),
                radius: 20,
              ),
            const SizedBox(width: 10),
            Text(receiverName.isNotEmpty ? receiverName : 'Chat'),
          ],
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['sender_id'] == widget.userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.teal : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['content'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) {
      return '';
    }
    final DateTime parsedTimestamp = DateTime.tryParse(timestamp) ?? DateTime.now();
    return '${parsedTimestamp.hour}:${parsedTimestamp.minute.toString().padLeft(2, '0')}';
  }
}
