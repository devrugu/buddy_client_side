// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../utilities/data_structures.dart';
import 'messages_screen.dart';
import 'review_guide_profile_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/guide_card.dart';
import 'travel_diary_screen.dart';
import 'welcome_screen.dart';
import 'filter_pane.dart';

class TouristHomeScreen extends StatefulWidget {
  const TouristHomeScreen({super.key});

  @override
  TouristHomeScreenState createState() => TouristHomeScreenState();
}

class TouristHomeScreenState extends State<TouristHomeScreen> {
  late Future<List<Guide>> futureGuides;
  Map<String, dynamic> appliedFilters = {};

  @override
  void initState() {
    super.initState();
    futureGuides = Future.value([]);
    _initializeLocationAndFetchGuides();
  }

  Future<void> _initializeLocationAndFetchGuides() async {
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
      setState(() {
        futureGuides = fetchGuides();
      });
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

  Future<List<Guide>> fetchGuides({Map<String, dynamic>? filters}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print('Token in fetchGuides: $token'); // Debugging

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$localUri/user/tourist/recommend_guides.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(filters ?? {}),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        final guides = data['guides'] as List;
        return guides.map((guide) => Guide.fromJson(guide)).toList();
      } else {
        print('Error: ${data['message']}');
        throw Exception(data['message']);
      }
    } else {
      print(
          'Failed to load guides: Server responded with status code ${response.statusCode}');
      throw Exception('Failed to load guides');
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
          MaterialPageRoute(
              builder: (context) => const WelcomeScreen()),
        );
      } else {
        print('Error: ${data['message']}');
      }
    } else {
      print('Failed to logout: Server responded with status code ${response.statusCode}');
    }
  }

  Future<void> _refreshGuides() async {
    setState(() {
      futureGuides = fetchGuides(filters: appliedFilters);
    });
  }

  void _openFilterPane() async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return Dialog(
        child: FilterPane(
          initialFilters: appliedFilters,
        ),
      );
    },
  );

  if (result != null) {
    setState(() {
      appliedFilters = result;
      futureGuides = fetchGuides(filters: appliedFilters);
    });
  }
}


  void _clearFilters() {
    setState(() {
      appliedFilters = {};
      futureGuides = fetchGuides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const UserAccountsDrawerHeader(
              accountName: Text('Tourist Name'),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
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
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
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
        onRefresh: _refreshGuides,
        child: FutureBuilder<List<Guide>>(
          future: futureGuides,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: const [
                  Center(child: Text('No guides found')),
                ],
              );
            } else {
              final guides = snapshot.data!;
              return Column(
                children: [
                  if (appliedFilters.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filters applied', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      children: guides.map((guide) {
                        return GuideCard(
                          guideId: guide.userId,
                          name: '${guide.name} ${guide.surname}',
                          rating: guide.rating,
                          reviews: guide.reviews,
                          ratePerHour: guide.hourlyWage,
                          images: guide.images,
                          onTap: () async {
                            // Save selected guide ID to JWT token
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('jwt_token');
                            if (token != null) {
                              try {
                                final jwt = JWT.verify(token, SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
                                jwt.payload['data']['selected_guide_id'] = guide.userId;
                                final newToken = JWT(jwt.payload, header: jwt.header);
                                final newTokenString = newToken.sign(SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
                                await prefs.setString('jwt_token', newTokenString);
                                print('New Token: $newTokenString'); // Debugging
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReviewGuideProfileScreen(guideId: guide.userId)),
                                );
                              } catch (e) {
                                print('Error modifying token: $e');
                              }
                            } else {
                              print('JWT token not found');
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openFilterPane,
        label: const Text('Find Your Guide'),
        icon: const Icon(Icons.search),
      ),
    );
  }
}

class Guide {
  final int userId;
  final String name;
  final String surname;
  final double latitude;
  final double longitude;
  final int countryId;
  final double? rating; // Updated to handle null
  final int? reviews; // Updated to handle null
  final double hourlyWage;
  final List<String> images;

  Guide({
    required this.userId,
    required this.name,
    required this.surname,
    required this.latitude,
    required this.longitude,
    required this.countryId,
    this.rating, // Updated to handle null
    this.reviews, // Updated to handle null
    required this.hourlyWage,
    required this.images,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      userId: json['user_id'],
      name: json['name'],
      surname: json['surname'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      countryId: json['country_id'],
      rating: json['rating'] != null ? double.parse(json['rating']) : null, // Updated to handle null
      reviews: json['reviews'], // Updated to handle null
      hourlyWage: double.parse(json['hourly_wage']),
      images: List<String>.from(json['images']),
    );
  }
}
