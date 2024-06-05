// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../utilities/data_structures.dart';
import 'tourist_home_screen.dart';
import 'guide_home_screen.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';
import 'register_tourist_screen.dart';
import 'register_guide_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isCheckingLoginStatus = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token != null) {
      final response = await http.post(
        Uri.parse('$localUri/user/validate_token.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['error'] == false) {
          final roleId = data['role_id'];
          if (roleId == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TouristHomeScreen()),
            );
          } else if (roleId == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GuideHomeScreen()),
            );
          }
          return;
        }
      }
    }
    setState(() {
      _isCheckingLoginStatus = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).size.width > 600
        ? const EdgeInsets.symmetric(horizontal: 120.0, vertical: 24.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);

    if (_isCheckingLoginStatus) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset(
              'assets/images/Logo2.png',
              height: 250,
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: 'Register as Tourist',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterTouristScreen()),
                );
              },
              color: Colors.blue.shade600,
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Register as Guide',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterGuideScreen()),
                );
              },
              color: Colors.blue.shade600,
              textStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginScreen(key: UniqueKey())),
                  );
                },
                child: const Text(
                  'Already have an account? Sign in',
                  style: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
