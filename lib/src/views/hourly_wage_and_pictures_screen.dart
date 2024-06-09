// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import '../widgets/warning_messages.dart';
import 'tourist_home_screen.dart';
import 'guide_home_screen.dart';
import '../utilities/data_structures.dart';

class HourlyWageAndPicturesScreen extends StatefulWidget {
  final dynamic missingInfo;

  const HourlyWageAndPicturesScreen({Key? key, required this.missingInfo}) : super(key: key);

  @override
  HourlyWageAndPicturesScreenState createState() => HourlyWageAndPicturesScreenState();
}

class HourlyWageAndPicturesScreenState extends State<HourlyWageAndPicturesScreen> {
  final TextEditingController _hourlyWageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  XFile? _profileImage;

  Future<void> _selectImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = pickedImages;
    });
    }

  Future<void> _uploadData() async {
    final uri = Uri.parse('$localUri/user/save_hourly_wage_and_pictures.php');
    final request = http.MultipartRequest('POST', uri);

    if (widget.missingInfo.contains('profiles')) {
      request.fields['hourly_wage'] = _hourlyWageController.text;
    }

    for (int i = 0; i < _selectedImages.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'pictures[]',
          _selectedImages[i].path,
          filename: _selectedImages[i].name,
        ),
      );
    }

    if (_profileImage != null) {
      request.fields['profile_picture'] = _profileImage!.name;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final result = json.decode(responseData);

    if (response.statusCode == 200 && !result['error']) {
      final roleId = result['role_id'];
      if (!(result['missing_info'].contains('profiles') ||
          result['missing_info'].contains('pictures'))) {
            if (roleId == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TouristHomeScreen()),
        );
      } else if (roleId == 2) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const GuideHomeScreen()),
        );
      }
          }
    } else {
      WarningMessages.error(context, result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Wage and Pictures'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              if (widget.missingInfo.contains('profiles'))
                TextField(
                  controller: _hourlyWageController,
                  decoration: const InputDecoration(
                    labelText: 'Hourly Wage',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectImages,
                child: const Text('Select Pictures'),
              ),
              const SizedBox(height: 16),
              if (_selectedImages.isNotEmpty)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _selectedImages.map((image) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _profileImage = image;
                        });
                      },
                      child: Stack(
                        children: <Widget>[
                          Image.file(
                            File(image.path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          if (_profileImage == image)
                            const Positioned(
                              right: 0,
                              top: 0,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (widget.missingInfo.contains('profiles') &&
                      _hourlyWageController.text.isEmpty) {
                    WarningMessages.error(context, 'Please enter your hourly wage.');
                    return;
                  }

                  if (_selectedImages.isEmpty) {
                    WarningMessages.error(context, 'Please select at least one picture.');
                    return;
                  }

                  if (_profileImage == null) {
                    WarningMessages.error(context, 'Please select a profile picture.');
                    return;
                  }

                  _uploadData();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
