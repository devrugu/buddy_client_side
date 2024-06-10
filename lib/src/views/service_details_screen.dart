// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../utilities/data_structures.dart';
import 'travel_diary_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Service service;

  const ServiceDetailsScreen({Key? key, required this.service}) : super(key: key);

  @override
  ServiceDetailsScreenState createState() => ServiceDetailsScreenState();
}

class ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  int _rating = 0;
  bool _hasReview = false;
  String _review = '';
  int _ratingValue = 0;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.service.title;
    _noteController.text = widget.service.note;
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    // Fetch the review details from the backend
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.get(
      Uri.parse('$localUri/user/get_review.php?diary_id=${widget.service.id}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['error'] == false) {
        setState(() {
          _hasReview = result['hasReview'];
          _review = result['review'];
          _ratingValue = result['rating'];
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error fetching review')));
    }
  }

  Future<void> _saveDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$localUri/user/update_service_details.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diary_id': widget.service.id,
        'title': _titleController.text,
        'note': _noteController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Details saved successfully')));
        setState(() {
          widget.service.title = _titleController.text;
          widget.service.note = _noteController.text;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving details')));
    }
  }

  Future<void> _uploadImage(XFile image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$localUri/user/upload_service_image.php'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['diary_id'] = widget.service.id.toString();

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error uploading image')));
    }
  }

  Future<void> _submitReview() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('JWT token not found');
    }

    final response = await http.post(
      Uri.parse('$localUri/user/add_review.php'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'diary_id': widget.service.id,
        'rating': _rating,
        'review': _reviewController.text,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['error'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully')));
        setState(() {
          _hasReview = true;
          _review = _reviewController.text;
          _ratingValue = _rating;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error submitting review')));
    }
  }

  Widget _buildReviewSection() {
    return _hasReview
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _ratingValue ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              Text(
                'Review: $_review',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Make a review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Write your review',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                child: const Text('Submit Review'),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.title.isNotEmpty ? widget.service.title : 'No title given'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _titleController.text = _titleController.text;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Service given to ${widget.service.touristName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Text(
              'Service provided in ${widget.service.location}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            Text(
              'Service was provided on ${widget.service.dateVisited}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            if (widget.service.note.isNotEmpty)
              Text(
                'Note: ${widget.service.note}',
                style: const TextStyle(fontSize: 18, color: Colors.black87),
              )
            else
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Add note',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        _noteController.text = _noteController.text;
                      });
                    },
                  ),
                ),
                maxLines: 3,
              ),
            const SizedBox(height: 20),
            _buildReviewSection(),
            const SizedBox(height: 20),
            const Text(
              'Add photos about your trip',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _images.add(pickedFile);
                  });
                  await _uploadImage(pickedFile);
                }
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add Photo'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: widget.service.images.length + _images.length,
              itemBuilder: (context, index) {
                if (index < widget.service.images.length) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      '$localUri/uploads/service/${widget.service.images[index]}',
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(_images[index - widget.service.images.length].path),
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
