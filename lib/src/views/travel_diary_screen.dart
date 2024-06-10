import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/data_structures.dart';
import 'service_details_screen.dart';

class TravelDiaryScreen extends StatefulWidget {
  const TravelDiaryScreen({Key? key}) : super(key: key);

  @override
  TravelDiaryScreenState createState() => TravelDiaryScreenState();
}

class TravelDiaryScreenState extends State<TravelDiaryScreen> {
  late Future<List<Service>> futureServices;

  @override
  void initState() {
    super.initState();
    futureServices = fetchServices();
  }

  Future<List<Service>> fetchServices() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$localUri/user/travel_diary.php'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['error'] == false) {
        final services = data['services'] as List;
        return services.map((service) => Service.fromJson(service)).toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load services');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Diary'),
      ),
      body: FutureBuilder<List<Service>>(
        future: futureServices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No services found'));
          } else {
            final services = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(10),
              children: services.map((service) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(
                      service.title.isNotEmpty ? service.title : 'No title given',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.location,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        Text(
                          service.dateVisited,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceDetailsScreen(service: service),
                        ),
                      );
                      if (result == true) {
                        setState(() {
                          futureServices = fetchServices();  // Refresh the list
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}

class Service {
  final int id;
  String title;
  String location;
  String dateVisited;
  String note;
  List<String> images;
  String touristName;

  Service({
    required this.id,
    required this.title,
    required this.location,
    required this.dateVisited,
    required this.note,
    required this.images,
    required this.touristName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['diary_id'],
      title: json['guide_title'] ?? 'No title given',
      location: json['location_name'],
      dateVisited: json['date_visited'],
      note: json['guide_note'] ?? '',
      images: List<String>.from(json['images']),
      touristName: '${json['tourist_name']} ${json['tourist_surname']}',
    );
  }
}
