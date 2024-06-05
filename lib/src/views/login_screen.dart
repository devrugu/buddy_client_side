// ignore_for_file: use_build_context_synchronously, duplicate_ignore, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_button.dart';
import '../widgets/warning_messages.dart';
import 'welcome_screen.dart';
import 'activities_and_interests_screen.dart';
import 'other_informations_screen.dart';
import '../utilities/data_structures.dart';
import 'tourist_home_screen.dart';
import 'guide_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required Key key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser(String username, String password) async {
    final url = '$localUri/user/login.php';
    print('Sending POST request to: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'password': password,
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData =
          json.decode(response.body);

      if (response.statusCode == 200) {
        if (!responseData['error']) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', responseData['token']);

          if (responseData['profile_status']) {
            final roleId = responseData['role_id'];
            // TODO: Implement navigation to the appropriate home screen
            if (roleId == 1) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const TouristHomeScreen(),
              ));
            } else if (roleId == 2) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const GuideHomeScreen(),
              ));
            }
          } else {
            dynamic missingInfo = responseData['missing_info'];
            if (missingInfo.contains('activities') ||
                missingInfo.contains('interests')) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    ActivitiesAndInterestsScreen(missingInfo: missingInfo),
              ));
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) =>
                    OtherInformationsScreen(missingInfo: missingInfo),
              ));
            }
          }
        } else {
          WarningMessages.error(context, responseData['message']);
        }
      } else {
        WarningMessages.error(
            context, 'An error occurred. Please try again later.');
      }
    } catch (e) {
      print('Error: $e');
      WarningMessages.error(context, 'Unable to login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/images/Logo2.png',
                height: 200,
              ),
              const SizedBox(height: 48),
              TextFormField(
                controller: _usernameController,
                cursorColor: Colors.blue.shade600,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  fillColor: Colors.white.withAlpha(235),
                  filled: true,
                  labelStyle: TextStyle(color: Colors.blue.shade600),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                cursorColor: Colors.blue.shade600,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  fillColor: Colors.white.withAlpha(235),
                  filled: true,
                  labelStyle: TextStyle(color: Colors.blue.shade600),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement forgot password functionality
                  },
                  child: const Text('Forgot Password?',
                      style: TextStyle(color: Colors.blueGrey)),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  loginUser(username, password); // loginUser function call
                },
                color: Colors.blue.shade600,
                textStyle: const TextStyle(
                    color: Colors.white),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              WelcomeScreen(key: UniqueKey())),
                    );
                  },
                  child: const Text('Back to Welcome Screen',
                      style: TextStyle(color: Colors.blueGrey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
