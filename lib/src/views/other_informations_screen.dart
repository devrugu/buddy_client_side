// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../utilities/data_structures.dart';
import '../widgets/warning_messages.dart';
import 'tourist_home_screen.dart';
import 'guide_home_screen.dart';

class OtherInformationsScreen extends StatefulWidget {
  final dynamic missingInfo; // Eksik bilgileri tutacak değişken
  const OtherInformationsScreen({Key? key, required this.missingInfo})
      : super(key: key);

  @override
  State<OtherInformationsScreen> createState() =>
      OtherInformationsScreenState();
}

class OtherInformationsScreenState extends State<OtherInformationsScreen> {
  // Kullanıcı seçimlerini tutacak değişkenler
  String? selectedEducationLevelId; // Seçilen eğitim seviyesinin ID'si
  List<dynamic> educationLevels = []; // Eğitim seviyelerinin listesi

  List<dynamic> languages = []; // Dillerin listesi
  Map<String, int> selectedLanguages = {}; // Seçilen diller ve seviyeleri
  String languageLevel = 'beginner'; // Varsayılan dil seviyesi

  String? selectedLocationId; // Seçilen konumun ID'si
  List<dynamic> locations = []; // Konumların listesi

  List<dynamic> professions = []; // Mesleklerin listesi
  Map<String, String> selectedProfessions =
      {}; // Seçilen meslekler ve tecrübe yılları

  @override
  void initState() {
    super.initState();
    // İlk veri yüklemelerini burada başlatabilirsiniz
    fetchEducationLevels(); // Eğitim seviyelerini çek
    fetchLanguages(); // Dilleri çek
    fetchLocations(); // Konumları çek
    fetchProfessions(); // Meslekleri çek
  }

  Future<void> fetchEducationLevels() async {
    final response =
        await http.get(Uri.parse('$localUri/general/education_levels.php'));

    if (response.statusCode == 200) {
      setState(() {
        educationLevels = json.decode(response.body);
      });
    } else {
      // Hata yönetimi
      print('Failed to load education levels');
    }
  }

  Future<void> fetchLanguages() async {
    final response =
        await http.get(Uri.parse('$localUri/general/languages.php'));

    if (response.statusCode == 200) {
      setState(() {
        languages = json.decode(response.body);
      });
    } else {
      // Hata yönetimi
      print('Failed to load languages');
    }
  }

  Future<void> fetchLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response =
        await http.get(Uri.parse('$localUri/general/locations.php'), headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      setState(() {
        locations = json.decode(response.body);
      });
    } else {
      print('Failed to load locations');
    }
  }

  // Meslekleri çeken fonksiyon
  Future<void> fetchProfessions() async {
    final response =
        await http.get(Uri.parse('$localUri/general/professions.php'));

    if (response.statusCode == 200) {
      setState(() {
        professions = json.decode(response.body);
      });
    } else {
      // Hata yönetimi
      print('Failed to load professions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: const Color.fromARGB(255, 47, 137, 228),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (widget.missingInfo.contains('educationlevels'))
                buildEducationLevelSelector(),
              if (widget.missingInfo.contains('languages'))
                buildLanguageSelector(),
              if (widget.missingInfo.contains('locations'))
                buildLocationSelector(),
              if (widget.missingInfo.contains('professions'))
                buildProfessionSelector(),
              buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEducationLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 8.0, bottom: 8.0), // İstenirse sağlanabilir.
          child: Text(
            'Select your education level:',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        DropdownButtonFormField<String>(
          focusColor: Colors.blue,
          dropdownColor: Colors.blue,
          iconEnabledColor: Colors.blue,
          decoration: InputDecoration(
            // Eğer kenarlık eğimini de istiyorsanız, aşağıdaki gibi borderRadius kullanabilirsiniz.
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
          isExpanded: true, // Dropdown'ın genişliğini ayarlar
          value: selectedEducationLevelId,
          hint: const Text('Education level'),
          onChanged: (newValue) {
            setState(() {
              selectedEducationLevelId = newValue;
            });
          },
          items: educationLevels.map<DropdownMenuItem<String>>((level) {
            return DropdownMenuItem<String>(
              value: level['education_level_id'].toString(),
              child: Text(
                level['education_level_name'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildLanguageSelector() {
    TextEditingController languageController = TextEditingController();

    // Dil seviyelerini sayısal değerlere eşleyen bir Map
    Map<String, int> languageLevels = {
      'beginner': 1,
      'intermediate': 2,
      'advanced': 3,
      'native': 4,
    };

    // Sayısal değerlerden metin karşılıklarına dönüştürmek için bir map
    Map<int, String> languageLevelNames = {
      1: 'beginner',
      2: 'intermediate',
      3: 'advanced',
      4: 'native',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Select your languages:",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            } else {
              return languages
                  .where((language) => language['language_name']
                      .toLowerCase()
                      .startsWith(textEditingValue.text.toLowerCase()))
                  .cast<Map<String, dynamic>>();
            }
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['language_name'],
          onSelected: (Map<String, dynamic> selection) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Select Language Level"),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return DropdownButton<String>(
                        value: languageLevel,
                        onChanged: (String? newValue) {
                          setState(() {
                            languageLevel = newValue!;
                          });
                        },
                        items: <String>[
                          'beginner',
                          'intermediate',
                          'advanced',
                          'native'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        setState(() {
                          selectedLanguages[selection['language_name']] =
                              languageLevels[languageLevel]!;
                          Navigator.of(context).pop();
                          languageController.clear();
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            languageController = fieldTextEditingController;

            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search languages',
              ),
            );
          },
        ),
        Wrap(
          spacing: 8.0,
          children: selectedLanguages.entries.map((entry) {
            String languageLevelText =
                languageLevelNames[entry.value] ?? 'Unknown';
            return Chip(
              label: Text('${entry.key} - $languageLevelText'),
              deleteIcon: const Icon(Icons.cancel),
              onDeleted: () {
                setState(() {
                  selectedLanguages.remove(entry.key);
                });
              },
              backgroundColor: Colors.blue.shade600,
              labelStyle: const TextStyle(color: Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildLocationSelector() {
    // ignore: unused_local_variable
    TextEditingController locationController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Select your location:",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            } else {
              return locations
                  .where((location) => location['location_name']
                      .toLowerCase()
                      .startsWith(textEditingValue.text.toLowerCase()))
                  .cast<Map<String, dynamic>>();
            }
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['location_name'],
          onSelected: (Map<String, dynamic> selection) {
            setState(() {
              selectedLocationId = selection['location_id'];
            });
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            locationController = fieldTextEditingController;

            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search locations',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildProfessionSelector() {
    TextEditingController professionController = TextEditingController();
    String experienceLevel = '0'; // Varsayılan olarak 'under 1 year'

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Select your professions:",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Autocomplete<Map<String, dynamic>>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            } else {
              return professions
                  .where((profession) => profession['profession_name']
                      .toLowerCase()
                      .startsWith(textEditingValue.text.toLowerCase()))
                  .cast<Map<String, dynamic>>();
            }
          },
          displayStringForOption: (Map<String, dynamic> option) =>
              option['profession_name'],
          onSelected: (Map<String, dynamic> selection) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Select Experience Level"),
                  content: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return DropdownButton<String>(
                        value: experienceLevel,
                        onChanged: (String? newValue) {
                          setState(() {
                            experienceLevel = newValue!;
                          });
                        },
                        items: <String>[
                          '0', // under 1 year
                          '1', // 1 year
                          '2', // 2 years
                          '3', // 3 years
                          '4', // 4 years
                          '5', // 5 years
                          '6', // 6 years
                          '7', // over 6 years
                        ].map<DropdownMenuItem<String>>((String value) {
                          String textValue = value == '0'
                              ? 'under 1 year'
                              : value == '7'
                                  ? 'over 6 years'
                                  : '$value year${value == '1' ? '' : 's'}';
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(textValue),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        setState(() {
                          selectedProfessions[selection['profession_name']] =
                              experienceLevel;
                          Navigator.of(context).pop();
                          professionController.clear();
                        });
                      },
                    ),
                  ],
                );
              },
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            professionController = fieldTextEditingController;

            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              cursorColor: Colors.blue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Search professions',
              ),
            );
          },
        ),
        Wrap(
          spacing: 8.0,
          children: selectedProfessions.entries.map((entry) {
            String textValue = entry.value == '0'
                ? 'under 1 year'
                : entry.value == '7'
                    ? 'over 6 years'
                    : '${entry.value} year${entry.value == '1' ? '' : 's'}';
            return Chip(
              label: Text('${entry.key} - $textValue'),
              deleteIcon: const Icon(Icons.cancel),
              onDeleted: () {
                setState(() {
                  selectedProfessions.remove(entry.key);
                });
              },
              backgroundColor: Colors.blue.shade600,
              labelStyle: const TextStyle(color: Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            submitSelections();
            // TODO: Redirect to the home page
            navigateToNextOrHomeScreen();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 47, 137, 228),
          ),
          child: const Text('Save and Continue'),
        ),
        ElevatedButton(
          onPressed: navigateToNextOrHomeScreen,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 47, 137, 228),
          ),
          child: const Text('Skip'),
        ),
      ],
    );
  }

  Future<void> submitSelections() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    var url = Uri.parse('$localUri/user/save_other_informations.php');

    var requestBody = jsonEncode({
      'selectedEducationLevelId': selectedEducationLevelId,
      'selectedLanguages': selectedLanguages,
      'selectedLocationId': selectedLocationId,
      'selectedProfessions': selectedProfessions,
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

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'error') {
          // Eğer bir hata varsa kullanıcıya hata mesajı göster
          WarningMessages.error(
              context, "Errors: ${jsonResponse['errors'].join(', ')}");
        } else {
          // Başarılı işlem sonrası ana sayfaya yönlendir
          navigateToNextOrHomeScreen();
        }
      } else {
        // Sunucu tarafında bir hata oluştuysa kullanıcıya bilgi ver
        WarningMessages.error(context,
            "Failed to submit selections: Server responded with status code ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      WarningMessages.error(
          context, 'An error occurred. Please try again later.');
    }
  }

  void navigateToNextOrHomeScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      try {
        final jwt = JWT.verify(token, SecretKey('d98088e564499fd3c0f6b7865aa79b282401825355fdae75078fdfa0818c889f'));
        final roleId = jwt.payload['data']['role_id'];

        // TODO: Implement navigation to the appropriate home screen
        if (roleId == 1) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TouristHomeScreen()),
          );
        } else if (roleId == 2) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const GuideHomeScreen()),
          );
        } else {
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
