// review_guide_profile_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/data_structures.dart';

class ReviewGuideProfileScreen extends StatefulWidget {
  final int guideId;

  const ReviewGuideProfileScreen({super.key, required this.guideId});

  @override
  ReviewGuideProfileScreenState createState() => ReviewGuideProfileScreenState();
}

class ReviewGuideProfileScreenState extends State<ReviewGuideProfileScreen> {
  Map<String, dynamic>? guideProfile;
  int _currentImageIndex = 0;
  final CarouselController _carouselController = CarouselController();

  @override
  void initState() {
    super.initState();
    fetchGuideProfile();
  }

  fetchGuideProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('$localUri/user/tourist/get_guide_profile.php'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          guideProfile = json.decode(response.body)['profile'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching profile')));
    }
  }

  sendInvitation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final response = await http.post(
      Uri.parse('$localUri/user/tourist/send_invitation.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'receiver_id': widget.guideId.toString(),
      }),
    );
    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error sending invitation')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (guideProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Guide Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    } else {
      List<String> guideImages = List<String>.from(guideProfile!['images'] ?? []);
      List<String> reviewTexts = guideProfile!['review_texts'].split('|||');
      List<String> reviewRatings = guideProfile!['review_ratings'].split('|||');
      return Scaffold(
        appBar: AppBar(title: Text('${guideProfile!['name']} ${guideProfile!['surname']}')),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (guideImages.isNotEmpty)
                Stack(
                  children: [
                    CarouselSlider(
                      items: guideImages.map((imageUrl) {
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
                      children: guideImages.asMap().entries.map((entry) {
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
                      subtitle: Text('${guideProfile!['name']} ${guideProfile!['surname']}'),
                    ),
                    if (guideProfile!['phone_number'] != null) ...[
                      ListTile(
                        title: const Text('Phone:'),
                        subtitle: Text('${guideProfile!['phone_number']}'),
                      ),
                    ],
                    if (guideProfile!['languages'] != null && guideProfile!['languages'].isNotEmpty) ...[
                      ListTile(
                        title: const Text('Languages:'),
                        subtitle: Text('${guideProfile!['languages']}'),
                      ),
                    ],
                    if (guideProfile!['activities'] != null && guideProfile!['activities'].isNotEmpty) ...[
                      ListTile(
                        title: const Text('Activities:'),
                        subtitle: Text('${guideProfile!['activities']}'),
                      ),
                    ],
                    if (guideProfile!['professions'] != null && guideProfile!['professions'].isNotEmpty) ...[
                      ListTile(
                        title: const Text('Professions:'),
                        subtitle: Text('${guideProfile!['professions']}'),
                      ),
                    ],
                    ListTile(
                      title: const Text('Rating:'),
                      subtitle: Text('${guideProfile!['average_rating']} (${guideProfile!['review_count']} reviews)'),
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
                    ElevatedButton(
                      onPressed: sendInvitation,
                      child: const Text('Send Invitation'),
                    ),
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
