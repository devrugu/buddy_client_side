import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtherInformationsScreen extends StatefulWidget {
  final dynamic missingInfo; // Eksik bilgileri tutacak
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
  Map<String, String> selectedLanguages = {}; // Seçilen diller ve seviyeleri
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
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEducationLevelSelector() {
    return DropdownButton<String>(
      value: selectedEducationLevelId,
      hint: const Text('Select your education level'),
      onChanged: (newValue) {
        setState(() {
          selectedEducationLevelId = newValue;
        });
      },
      items: educationLevels.map<DropdownMenuItem<String>>((level) {
        return DropdownMenuItem<String>(
          value: level['education_level_id'].toString(),
          child: Text(level['education_level_name']),
        );
      }).toList(),
    );
  }

  Widget buildLanguageSelector() {
    TextEditingController languageController = TextEditingController();

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
                              languageLevel;
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
            return Chip(
              label: Text('${entry.key} - ${entry.value}'),
              deleteIcon: const Icon(Icons.cancel),
              onDeleted: () {
                setState(() {
                  selectedLanguages.remove(entry.key);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget buildLocationSelector() {
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
                          // Add other values up to '6'
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
            );
          }).toList(),
        ),
      ],
    );
  }

  void submitForm() async {
    // Seçilen bilgileri 'save_other_information.php' endpoint'ine POST request olarak gönderin
    // http paketini kullanarak POST isteğini oluşturun
  }
}
