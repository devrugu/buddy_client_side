// review_tourist_profile_screen.dart
// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/data_structures.dart';
import 'chat_screen.dart';

class ReviewTouristProfileScreen extends StatefulWidget {
  final int touristId;

  const ReviewTouristProfileScreen({super.key, required this.touristId});

  @override
  ReviewTouristProfileScreenState createState() => ReviewTouristProfileScreenState();
}

class ReviewTouristProfileScreenState extends State<ReviewTouristProfileScreen> {
  Map<String, dynamic>? touristProfile;
  int _currentImageIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    fetchTouristProfile();
  }

  fetchTouristProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('$localUri/user/guide/get_tourist_profile.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          touristProfile = json.decode(response.body)['profile'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching profile')));
    }
  }

  acceptRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('$localUri/user/guide/respond_request.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'accepted',
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['error'] == false) {
          // TODO: Navigate to chat screen
          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(touristId: widget.touristId),
            ),
          );*/
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error accepting request')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error processing request')));
    }
  }

  denyRequest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('$localUri/user/guide/respond_request.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'denied',
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['error'] == false) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error denying request')));
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error processing request')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (touristProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tourist Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      List<String> touristImages = List<String>.from(touristProfile!['images'] ?? []);
      List<String> reviewTexts = touristProfile!['review_texts'].split('|||');
      List<String> reviewRatings = touristProfile!['review_ratings'].split('|||');
      return Scaffold(
        appBar: AppBar(title: Text('${touristProfile!['name']} ${touristProfile!['surname']}')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (touristImages.isNotEmpty)
                Stack(
                  children: [
                    CarouselSlider(
                      items: touristImages.map((imageUrl) {
                        return Container(
                          height: 300.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        height: 300.0,
                        autoPlay: false,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      carouselController: _carouselController,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: touristImages.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _carouselController.animateToPage(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: _currentImageIndex == entry.key ? 12.0 : 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  .withOpacity(_currentImageIndex == entry.key ? 0.9 : 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text('Name:'),
                      subtitle: Text('${touristProfile!['name']} ${touristProfile!['surname']}'),
                    ),
                    if (touristProfile!['phone_number'] != null) ...[
                      ListTile(
                        title: const Text('Phone:'),
                        subtitle: Text('${touristProfile!['phone_number']}'),
                      ),
                    ],
                    if (touristProfile!['languages'] != null && touristProfile!['languages'].isNotEmpty) ...[
                      ListTile(
                        title: const Text('Languages:'),
                        subtitle: Text('${touristProfile!['languages']}'),
                      ),
                    ],
                    if (touristProfile!['activities'] != null && touristProfile!['activities'].isNotEmpty) ...[
                      ListTile(
                        title: const Text('Activities:'),
                        subtitle: Text('${touristProfile!['activities']}'),
                      ),
                    ],
                    if (touristProfile!['professions'] != null && touristProfile!['professions'].isNotEmpty) ...[
                      ListTile(
                        title: const Text('Professions:'),
                        subtitle: Text('${touristProfile!['professions']}'),
                      ),
                    ],
                    ListTile(
                      title: const Text('Rating:'),
                      subtitle: Text('${touristProfile!['average_rating']} (${touristProfile!['review_count']} reviews)'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Reviews:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: List.generate(reviewTexts.length, (index) {
                        return ListTile(
                          title: Text(reviewTexts[index]),
                          subtitle: Row(
                            children: List.generate(int.parse(reviewRatings[index]), (starIndex) {
                              return const Icon(Icons.star, color: Colors.yellow, size: 20.0);
                            }),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: acceptRequest,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Accept'),
                        ),
                        ElevatedButton(
                          onPressed: denyRequest,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Deny'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
