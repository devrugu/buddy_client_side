// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/data_structures.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String? _profileImageUrl;
  final picker = ImagePicker();

  final TextEditingController hourlyWageController = TextEditingController();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  List<String> activities = ['Kayaking', 'Parasailing', 'Surfing'];
  List<String> interests = ['Art', 'Music', 'Reading'];
  List<String> professions = ['Actor', 'Actuary'];
  List<String> languages = ['Turkish (native)', 'English (advanced)'];
  List<String> pictures = [
    'assets/profile_placeholder.png',
    'assets/profile_placeholder.png',
    'assets/profile_placeholder.png',
    'assets/profile_placeholder.png',
    'assets/profile_placeholder.png'
  ];

  @override
  void initState() {
    super.initState();
    fetchProfilePicture();
  }

  Future<void> fetchProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt_token');
    final response = await http.get(
      Uri.parse('$localUri/user/get_profile_picture.php'),
      headers: {'Authorization': 'Bearer $jwt'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      String profilePictureName = data['profile_picture_path'];
      if (data['error'] == false) {
        setState(() {
          _profileImageUrl = '$localUri/uploads/$profilePictureName';
        });
      } else {
        print(data['message']);
      }
    } else {
      print('Failed to load profile picture');
    }
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await uploadProfilePicture();
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadProfilePicture() async {
    if (_image == null) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');
    var request = http.MultipartRequest('POST', Uri.parse('$localUri/user/update_profile_picture.php'));
    request.headers['Authorization'] = 'Bearer $jwt';
    request.files.add(await http.MultipartFile.fromPath('profile_picture', _image!.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Profile picture uploaded successfully.');
      fetchProfilePicture(); // Refresh the profile picture
    } else {
      print('Failed to upload profile picture.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Save hourly wage, location, and education level
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : const AssetImage('assets/profile_placeholder.png')) as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Name Surname',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Visibility(
                    visible: true, // set visibility for guides
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        TextField(
                          controller: hourlyWageController,
                          decoration: const InputDecoration(
                            labelText: 'Enter value for hourly wage',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your current hourly wage is 55\$',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            buildSectionTitle('Activities:'),
            buildAutoCompleteField(activityController, 'Start to write something', (value) {
              // Fetch suggestions from backend
            }),
            buildTags(activities, (tag) {
              setState(() {
                activities.remove(tag);
                // Delete from database
              });
            }),
            const SizedBox(height: 24),
            buildSectionTitle('Interests:'),
            buildAutoCompleteField(interestController, 'Start to write something', (value) {
              // Fetch suggestions from backend
            }),
            buildTags(interests, (tag) {
              setState(() {
                interests.remove(tag);
                // Delete from database
              });
            }),
            const SizedBox(height: 24),
            buildSectionTitle('Pictures:'),
            buildAddPicturesButton(),
            buildPicturesGrid(),
            const SizedBox(height: 24),
            buildSectionTitle('Professions:'),
            buildAutoCompleteField(professionController, 'Start to write something', (value) {
              // Fetch suggestions from backend
            }),
            buildTags(professions, (tag) {
              setState(() {
                professions.remove(tag);
                // Delete from database
              });
            }),
            const SizedBox(height: 24),
            buildSectionTitle('Languages:'),
            buildAutoCompleteField(languageController, 'Start to write something', (value) {
              // Fetch suggestions from backend
            }),
            buildTags(languages, (tag) {
              setState(() {
                languages.remove(tag);
                // Delete from database
              });
            }),
            const SizedBox(height: 24),
            buildSectionTitle('Education Level:'),
            buildAutoCompleteField(educationController, 'Start to write something', (value) {
              // Fetch suggestions from backend
            }),
            const Text(
              'Your education level is bachelor degree',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            buildSectionTitle('Location:'),
            buildAutoCompleteField(locationController, 'Start to write something', (value) {
              // Fetch suggestions from backend
            }),
            const Text(
              'Your location is Istanbul',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
    );
  }

  Widget buildAutoCompleteField(TextEditingController controller, String hint, Function(String) onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget buildTags(List<String> tags, Function(String) onDeleted) {
    return Wrap(
      spacing: 8.0,
      children: tags.map((tag) {
        return Chip(
          label: Text(tag),
          onDeleted: () => onDeleted(tag),
          backgroundColor: Colors.teal.shade100,
          deleteIconColor: Colors.teal,
        );
      }).toList(),
    );
  }

  Widget buildAddPicturesButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Handle add pictures
      },
      icon: const Icon(Icons.add_a_photo),
      label: const Text('Add pictures'),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.teal,
      ),
    );
  }

  Widget buildPicturesGrid() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: List.generate(pictures.length, (index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(pictures[index]), // Placeholder image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    pictures.removeAt(index);
                    // Delete from database
                  });
                },
                child: const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
