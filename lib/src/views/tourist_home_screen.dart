// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../utilities/data_structures.dart';
import 'review_guide_profile_screen.dart';
import 'tourist_profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/guide_card.dart';
import 'welcome_screen.dart';

class TouristHomeScreen extends StatefulWidget {
  const TouristHomeScreen({super.key});

  @override
  TouristHomeScreenState createState() => TouristHomeScreenState();
}

class TouristHomeScreenState extends State<TouristHomeScreen> {
  late Future<List<Guide>> futureGuides;

  @override
  void initState() {
    super.initState();
    futureGuides = Future.value([]);
    _initializeLocationAndFetchGuides();
  }

  Future<void> _initializeLocationAndFetchGuides() async {
    try {
      Position position = await _getCurrentLocation();
      await _updateLocation(position.latitude, position.longitude);
      setState(() {
        futureGuides = fetchGuides();
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Position> _getCurrentLocation() async {
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
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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

  Future<List<Guide>> fetchGuides() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print('Token in fetchGuides: $token'); // Debugging

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$localUri/user/tourist/recommend_guides.php'),
      headers: {
        'Authorization': 'Bearer $token',
      },
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
      body: FutureBuilder<List<Guide>>(
        future: futureGuides,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No guides found'));
          } else {
            final guides = snapshot.data!;
            return ListView(
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
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // This will be implemented later
        },
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
  final double rating;
  final int reviews;
  final double hourlyWage;
  final List<String> images;

  Guide({
    required this.userId,
    required this.name,
    required this.surname,
    required this.latitude,
    required this.longitude,
    required this.countryId,
    required this.rating,
    required this.reviews,
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
      rating: double.parse(json['rating']),
      reviews: json['reviews'],
      hourlyWage: double.parse(json['hourly_wage']),
      images: List<String>.from(json['images']),
    );
  }
}
