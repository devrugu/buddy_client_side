import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/data_structures.dart';

class FilterPane extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  const FilterPane({Key? key, required this.initialFilters}) : super(key: key);

  @override
  FilterPaneState createState() => FilterPaneState();
}

class FilterPaneState extends State<FilterPane> {
  final TextEditingController _ageRangeController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();

  List<String> professionSuggestions = [];
  List<String> interestSuggestions = [];
  List<String> activitySuggestions = [];
  List<String> languageSuggestions = [];

  @override
  void initState() {
    super.initState();
    _ageRangeController.text = widget.initialFilters['ageRange']?.toString() ?? '';
    _professionController.text = widget.initialFilters['profession'] ?? '';
    _interestController.text = widget.initialFilters['interest'] ?? '';
    _activityController.text = widget.initialFilters['activity'] ?? '';
    _languageController.text = widget.initialFilters['language'] ?? '';

    _professionController.addListener(() {
      if (_professionController.text.isNotEmpty) {
        _fetchProfessionSuggestions();
      }
    });

    _interestController.addListener(() {
      if (_interestController.text.isNotEmpty) {
        _fetchInterestSuggestions();
      }
    });

    _activityController.addListener(() {
      if (_activityController.text.isNotEmpty) {
        _fetchActivitySuggestions();
      }
    });

    _languageController.addListener(() {
      if (_languageController.text.isNotEmpty) {
        _fetchLanguageSuggestions();
      }
    });
  }

  @override
  void dispose() {
    _ageRangeController.dispose();
    _professionController.dispose();
    _interestController.dispose();
    _activityController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfessionSuggestions() async {
    final query = _professionController.text;
    if (query.isEmpty) return;
    final url = '$localUri/general/professions_filter.php';
    final response = await http.get(Uri.parse('$url?query=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['professions'] != null) {
        final List<dynamic> suggestions = data['professions'];
        setState(() {
          professionSuggestions = suggestions.map((s) => s as String).toList();
        });
      }
    }
  }

  Future<void> _fetchInterestSuggestions() async {
    final query = _interestController.text;
    if (query.isEmpty) return;
    final url = '$localUri/general/interests_filter.php';
    final response = await http.get(Uri.parse('$url?query=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['interests'] != null) {
        final List<dynamic> suggestions = data['interests'];
        setState(() {
          interestSuggestions = suggestions.map((s) => s as String).toList();
        });
      }
    }
  }

  Future<void> _fetchActivitySuggestions() async {
    final query = _activityController.text;
    if (query.isEmpty) return;
    final url = '$localUri/general/activities_filter.php';
    final response = await http.get(Uri.parse('$url?query=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['activities'] != null) {
        final List<dynamic> suggestions = data['activities'];
        setState(() {
          activitySuggestions = suggestions.map((s) => s as String).toList();
        });
      }
    }
  }

  Future<void> _fetchLanguageSuggestions() async {
    final query = _languageController.text;
    if (query.isEmpty) return;
    final url = '$localUri/general/languages_filter.php';
    final response = await http.get(Uri.parse('$url?query=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['languages'] != null) {
        final List<dynamic> suggestions = data['languages'];
        setState(() {
          languageSuggestions = suggestions.map((s) => s as String).toList();
        });
      }
    }
  }

  void _applyFilters() {
    List<int> ageRange = [0, 100];
    final ageRangeParts = _ageRangeController.text.split('-');
    if (ageRangeParts.length == 2) {
      ageRange = [
        int.tryParse(ageRangeParts[0].trim()) ?? 0,
        int.tryParse(ageRangeParts[1].trim()) ?? 100,
      ];
    }

    final filters = {
      'ageRange': ageRange,
      'profession': _professionController.text,
      'interest': _interestController.text,
      'activity': _activityController.text,
      'language': _languageController.text,
    };

    Navigator.pop(context, filters);
  }

  RangeValues _parseAgeRange() {
    final parts = _ageRangeController.text.split('-');
    if (parts.length == 2) {
      final start = double.tryParse(parts[0].trim()) ?? 0;
      final end = double.tryParse(parts[1].trim()) ?? 100;
      return RangeValues(start, end);
    }
    return const RangeValues(0, 100);
  }

  RangeLabels _getAgeRangeLabels() {
    final parts = _ageRangeController.text.split('-');
    if (parts.length == 2) {
      return RangeLabels(parts[0].trim(), parts[1].trim());
    }
    return const RangeLabels('0', '100');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter Guides',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RangeSlider(
              values: _parseAgeRange(),
              min: 0,
              max: 100,
              divisions: 100,
              labels: _getAgeRangeLabels(),
              onChanged: (RangeValues values) {
                setState(() {
                  _ageRangeController.text = '${values.start.round()} - ${values.end.round()}';
                });
              },
            ),
            const SizedBox(height: 20),
            _buildTextFieldWithSuggestions(_professionController, 'Select Profession', professionSuggestions),
            _buildTextFieldWithSuggestions(_interestController, 'Select Interest', interestSuggestions),
            _buildTextFieldWithSuggestions(_activityController, 'Select Activity', activitySuggestions),
            _buildTextFieldWithSuggestions(_languageController, 'Select Language', languageSuggestions),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithSuggestions(TextEditingController controller, String labelText, List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: labelText),
        ),
        if (suggestions.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]),
                  onTap: () {
                    controller.text = suggestions[index];
                    setState(() {
                      suggestions.clear();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
