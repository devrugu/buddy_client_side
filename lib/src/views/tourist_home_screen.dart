import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/data_structures.dart';
import 'tourist_profile_screen.dart';
import 'settings_screen.dart';
import '../widgets/guide_card.dart';

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
    futureGuides  = Future.value([]);
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
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _updateLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$localUri/buddy-backend/general/update_current_location.php'), // Replace with your endpoint URL
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

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$localUri/buddy-backend/user/tourist/recommend_guides.php'), // Replace with your endpoint URL
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        final guides = data['guides'] as List;
        return guides.map((guide) => Guide.fromJson(guide)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load guides');
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
                backgroundImage: NetworkImage('https://example.com/profile_picture.jpg'), // Replace with actual profile picture URL
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
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
              title: const Text('Sign Out'),
              onTap: () {
                // Implement sign out functionality later
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
                  name: '${guide.name} ${guide.surname}',
                  rating: guide.rating,
                  reviews: guide.reviews,
                  ratePerHour: guide.ratePerHour,
                  images: guide.images,
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
  final double rating;
  final int reviews;
  final double ratePerHour;
  final List<String> images;

  Guide({
    required this.userId,
    required this.name,
    required this.surname,
    required this.rating,
    required this.reviews,
    required this.ratePerHour,
    required this.images,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      userId: json['user_id'],
      name: json['name'],
      surname: json['surname'],
      rating: json['rating'] ?? 0.0,
      reviews: json['reviews'] ?? 0,
      ratePerHour: json['rate_per_hour'] ?? 0.0,
      images: List<String>.from(json['images']),
    );
  }
}
