// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../utilities/data_structures.dart';
import 'messages_screen.dart';
import 'review_tourist_profile_screen.dart';
import 'chat_screen.dart';
import 'guide_profile_screen.dart';
import 'settings_screen.dart';
import 'welcome_screen.dart';
import 'travel_diary_screen.dart';
import '../widgets/tourist_card.dart';

class GuideHomeScreen extends StatefulWidget {
  const GuideHomeScreen({Key? key}) : super(key: key);

  @override
  GuideHomeScreenState createState() => GuideHomeScreenState();
}

class GuideHomeScreenState extends State<GuideHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<TouristRequest>> futurePendingRequests;
  late Future<List<TouristRequest>> futureAcceptedRequests;
  late Future<List<TouristRequest>> futureDeniedRequests;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    futurePendingRequests = fetchRequests('pending');
    futureAcceptedRequests = fetchRequests('accepted');
    futureDeniedRequests = fetchRequests('denied');
    _initializeLocationAndRefreshRequests();
    _timer = Timer.periodic(const Duration(seconds: 300), (Timer t) {
      _refreshRequests();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    _refreshRequests();
  }

  Future<void> _refreshRequests() async {
    setState(() {
      futurePendingRequests = fetchRequests('pending');
      futureAcceptedRequests = fetchRequests('accepted');
      futureDeniedRequests = fetchRequests('denied');
    });
  }

  Future<void> _initializeLocationAndRefreshRequests() async {
    try {
      Position? position;
      try {
        position = await _getCurrentLocation();
        if (position != null) {
          await _updateLocation(position.latitude, position.longitude);
        }
      } catch (e) {
        print('Error getting location: $e');
      }
      _refreshRequests();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    } else if (permission == LocationPermission.deniedForever) {
      return null;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      return null;
    }
  }

  Future<void> _updateLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print('Token in _updateLocation: $token'); // Debugging

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$localUri/general/update_current_location.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update location');
    }
  }

  Future<List<TouristRequest>> fetchRequests(String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$localUri/user/guide/tourist_requests.php?status=$status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Response Body: ${response.body}'); // Add this line to inspect the response

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        final requests = data['requests'] as List;
        return requests.map((request) => TouristRequest.fromJson(request)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load requests');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      print('JWT token not found');
      return;
    }

    final response = await http.post(
      Uri.parse('$localUri/user/logout.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        print('Logout successful');
        await prefs.remove('jwt_token');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        print('Error: ${data['message']}');
      }
    } else {
      print('Failed to logout: Server responded with status code ${response.statusCode}');
    }
  }

  Future<void> updateTokenWithTouristId(int touristId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      try {
        final jwt = JWT.verify(token, SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
        jwt.payload['tourist_id'] = touristId;
        final newToken = JWT(jwt.payload, header: jwt.header);
        final newTokenString = newToken.sign(SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
        await prefs.setString('jwt_token', newTokenString);
      } catch (e) {
        print('Error updating token: $e');
      }
    } else {
      print('JWT token not found');
    }
  }

  Future<void> finishService(int touristId, int requestId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$localUri/user/guide/finish_service.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'tourist_id': touristId, 'request_id': requestId}),
    );

    print('Response Body: ${response.body}'); // Add this line to inspect the response

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        _refreshRequests();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to finish service');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide Home'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Denied'),
          ],
          indicatorColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelColor: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('Guide Name'),
              accountEmail: Text(''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://example.com/profile_picture.jpg'), // Replace with actual profile picture URL
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                ); */
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Travel Diary'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TravelDiaryScreen()),
                );
              },
            ),
            ListTile(
  leading: const Icon(Icons.chat),
  title: const Text('Messages'),
  onTap: () async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      final jwt = JWT.verify(token, SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
      final userId = jwt.payload['data']['user_id'];
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessagesScreen(userId: userId)),
      );
    } else {
      print('JWT token not found');
    }
  },
),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                await _logout();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRequests,
        child: TabBarView(
          controller: _tabController,
          children: [
            buildRequestsList(futurePendingRequests, Colors.yellow, 'pending'),
            buildRequestsList(futureAcceptedRequests, Colors.green, 'accepted'),
            buildRequestsList(futureDeniedRequests, Colors.red, 'denied'),
          ],
        ),
      ),
    );
  }

  Widget buildRequestsList(Future<List<TouristRequest>> futureRequests, Color tabColor, String status) {
    return Container(
      color: tabColor.withOpacity(0.2),
      child: FutureBuilder<List<TouristRequest>>(
        future: futureRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No requests found'));
          } else {
            final requests = snapshot.data!;
            return ListView(
              children: requests.map((request) {
                return TouristCard(
                  touristId: request.touristId,
                  name: '${request.name} ${request.surname}',
                  rating: request.rating == 0.0 ? null : request.rating,
                  reviews: request.reviews == 0 ? null : request.reviews,
                  pictures: request.pictures,
                  serviceFinished: request.serviceFinished, // Pass the serviceFinished flag
                  onTap: () async {
                    await updateTokenWithTouristId(request.touristId);
                    if (status == 'pending') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewTouristProfileScreen(touristId: request.touristId),
                        ),
                      );
                    } else if (status == 'accepted') {
                      // TODO: Navigate to chat screen between guide(token-->user_id) and tourist(request.touristId)
                      final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('jwt_token');
                      final jwt = JWT.verify(token!, SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
        final userId = jwt.payload['data']['user_id'];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(userId: userId, receiverId: request.touristId)),
        );
                    }
                  },
                  extraButton: status == 'accepted' && !request.serviceFinished
                      ? ElevatedButton(
                          onPressed: () async {
                            bool? confirmed = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Finish Service'),
                                  content: const Text('Are you sure you want to finish this service?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                      },
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmed == true) {
                              await finishService(request.touristId, request.requestId);
                            }
                          },
                          child: const Text('Finish Service'),
                        )
                      : null,
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class TouristRequest {
  final int touristId;
  final int requestId;
  final String name;
  final String surname;
  final String status;
  final double? rating;
  final int? reviews;
  final List<String> pictures;
  final bool serviceFinished;

  TouristRequest({
    required this.touristId,
    required this.requestId,
    required this.name,
    required this.surname,
    required this.status,
    required this.rating,
    required this.reviews,
    required this.pictures,
    required this.serviceFinished,
  });

  factory TouristRequest.fromJson(Map<String, dynamic> json) {
    return TouristRequest(
      touristId: json['tourist_id'],
      requestId: json['request_id'],
      name: json['name'],
      surname: json['surname'],
      status: json['status'],
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : null,
      reviews: json['reviews'],
      pictures: List<String>.from(json['pictures']),
      serviceFinished: json['service_finished'] == 1, // Convert 1 to true and 0 to false
    );
  }
}
