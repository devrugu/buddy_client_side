// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'other_informations_screen.dart';
import '../utilities/data_structures.dart';
import '../widgets/warning_messages.dart';
import 'tourist_home_screen.dart';
import 'guide_home_screen.dart';

class ActivitiesAndInterestsScreen extends StatefulWidget {
  final dynamic missingInfo;
  const ActivitiesAndInterestsScreen({Key? key, required this.missingInfo})
      : super(key: key);

  @override
  State<ActivitiesAndInterestsScreen> createState() =>
      ActivitiesAndInterestsScreenState();
}

class ActivitiesAndInterestsScreenState
    extends State<ActivitiesAndInterestsScreen> {
  bool isLoading = true;
  List<dynamic> categories = [];
  Map<int, bool> selectedActivities = {};
  List<Map<String, dynamic>> interests = []; // İlgi alanları listesi
  List<String> selectedInterests = []; // Seçilen ilgi alanları
  final TextEditingController _interestsController =
      TextEditingController(); // Controller ekleme

  @override
  void initState() {
    super.initState();
    fetchActivities();
    fetchInterests(); // Interests verisini de çekin
  }

  @override
  void dispose() {
    _interestsController.dispose(); // Controller'ı temizle
    super.dispose();
  }

  Future<void> fetchActivities() async {
    final url = '$localUri/general/activities.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final fetchedCategories = json.decode(response.body);
      setState(() {
        categories = fetchedCategories;
        isLoading = false;
        for (var category in categories) {
          for (var activity in category['activities']) {
            selectedActivities[int.parse(activity['activity_id'])] = false;
          }
        }
      });
    } else {
      print('Failed to load activities');
    }
  }

  Future<void> fetchInterests() async {
    final url = '$localUri/general/interests.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final fetchedInterests = json.decode(response.body);
      setState(() {
        interests = List<Map<String, dynamic>>.from(fetchedInterests);
      });
    } else {
      print('Failed to load interests');
    }
  }

  Future<void> submitSelections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    var url = Uri.parse('$localUri/user/save_activites_and_interests.php');

    var requestBody = jsonEncode({
      'selectedActivities': selectedActivities.keys
          .where((key) => selectedActivities[key]!)
          .toList(),
      'selectedInterests': selectedInterests,
    });

    print('URL: $url');
    print('Request Body: $requestBody');

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      var decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedResponse['status'] == 'success') {
        WarningMessages.success(context, decodedResponse['message']);
        navigateToNextOrHomeScreen();
      } else {
        WarningMessages.error(
            context, decodedResponse['message'] ?? 'An error occurred.');
      }
    } catch (e) {
      print('Error: $e');
      WarningMessages.error(
          context, 'An error occurred. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildMainContent(context),
    );
  }

  Widget buildMainContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Let's complete your profile!",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.missingInfo.contains('activities'))
            buildActivitiesSection(),
          if (widget.missingInfo.contains('interests'))
            buildInterestsAutocomplete(),
          buildButtons(context),
        ],
      ),
    );
  }

  Widget buildActivitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "You can choose the activities you like to do:",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        ...categories.map((category) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ExpansionTile(
              backgroundColor: const Color.fromARGB(255, 47, 137, 228),
              title: Text(category['category_name'],
                  style: const TextStyle(
                      color: Color.fromARGB(255, 47, 137, 228))),
              children: List<Widget>.from(
                category['activities'].map<Widget>((activity) {
                  return CheckboxListTile(
                    value:
                        selectedActivities[int.parse(activity['activity_id'])],
                    onChanged: (bool? value) {
                      setState(() {
                        selectedActivities[int.parse(activity['activity_id'])] =
                            value!;
                      });
                    },
                    title: Text(activity['activity_name'],
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget buildInterestsAutocomplete() {
    // Create a local TextEditingController
    TextEditingController autocompleteController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Select your interests:",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            } else {
              // Filter out already selected interests from the suggestions
              return interests
                  .where((interest) =>
                      !selectedInterests.contains(interest['interest_name']) &&
                      interest['interest_name']
                          .toLowerCase()
                          .startsWith(textEditingValue.text.toLowerCase()))
                  .map((e) => e['interest_name']);
            }
          },
          onSelected: (String selection) {
            setState(() {
              selectedInterests.add(selection);
            });
            // Clear the text field after making a selection
            autocompleteController.clear();
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Assign the local controller to the text field
            autocompleteController = fieldTextEditingController;

            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search your interests',
              ),
            );
          },
        ),
        Wrap(
          children: selectedInterests
              .map((interest) => Chip(
                    label: Text(interest),
                    onDeleted: () {
                      setState(() {
                        selectedInterests.remove(interest);
                      });
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: submitSelectionsAndNavigate,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Save and Continue'),
          ),
          ElevatedButton(
            onPressed: navigateToNextOrHomeScreen,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  void submitSelectionsAndNavigate() {
    submitSelections();
    navigateToNextOrHomeScreen();
  }

  void navigateToNextOrHomeScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      try {
        final jwt = JWT.verify(token, SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
        final roleId = jwt.payload['data']['role_id'];

        // TODO: Implement navigation to the appropriate home screen
        if (roleId == 1 || roleId == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TouristHomeScreen()),
          );
        } /*else if (roleId == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GuideHomeScreen()),
          );
        }*/ else {
          WarningMessages.error(context, 'Invalid role ID');
        }
      } catch (e) {
        print('Error decoding token: $e');
        WarningMessages.error(context, 'Invalid token. Please log in again.');
      }
    } else {
      WarningMessages.error(context, 'Token not found. Please log in again.');
    }
  }
}
