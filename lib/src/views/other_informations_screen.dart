// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OtherInformationsScreen extends StatefulWidget {
  final dynamic missingInfo; // Eksik bilgileri tutacak değişken
  const OtherInformationsScreen({Key? key, required this.missingInfo})
      : super(key: key);

  @override
  State<OtherInformationsScreen> createState() => OtherInformationScreenState();
}

class OtherInformationScreenState extends State<OtherInformationsScreen> {
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
    final response = await http.get(Uri.parse(
        'http://192.168.1.86/buddy-backend/general/education_levels.php'));

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
    final response = await http.get(
        Uri.parse('http://192.168.1.86/buddy-backend/general/languages.php'));

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
    final response = await http.get(
        Uri.parse('http://192.168.1.86/buddy-backend/general/locations.php'));

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
    final response = await http.get(
        Uri.parse('http://192.168.1.86/buddy-backend/general/professions.php'));

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
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(
                          255, 0, 0, 0)), // Kenarlık rengini ayarlar
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Color.fromARGB(255, 0, 0, 0)), // Etkin kenarlık rengi
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0), // Odaklanıldığında kenarlık rengi
                ),
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
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue), // Kenarlık rengini ayarlar
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Color.fromARGB(255, 0, 0, 0)), // Etkin kenarlık rengi
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0), // Odaklanıldığında kenarlık rengi
                ),
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
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue), // Kenarlık rengini ayarlar
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Color.fromARGB(255, 0, 0, 0)), // Etkin kenarlık rengi
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ), // Odaklanıldığında kenarlık rengi
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
            {
              submitSelections();
              // TODO: Redirect to the home page
            }
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color.fromARGB(255, 47, 137, 228),
          ),
          child: const Text('Save and Continue'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Redirect to the home page
          },
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
    String? token = prefs.getString('jwt_token'); // JWT token

    var url = Uri.parse(
        'http://192.168.1.86/buddy-backend/user/save_other_informations.php');

    // Seçilen verilerin JSON formatında hazırlanması
    var requestBody = jsonEncode({
      'selectedEducationLevelId': selectedEducationLevelId,
      'selectedLanguages': selectedLanguages,
      'selectedLocationId': selectedLocationId,
      'selectedProfessions': selectedProfessions,
    });

    print(selectedEducationLevelId);
    print(selectedLanguages);
    print(selectedLocationId);
    print(selectedProfessions);

    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: requestBody,
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'error') {
        print("Errors: ${jsonResponse['errors']}");
      } else {
        print("Data: ${jsonResponse['data']}");
      }
    } else {
      print(
          "Failed to submit selections: Server responded with status code ${response.statusCode}");
    }
  }
}
