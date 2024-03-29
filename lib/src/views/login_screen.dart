// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_button.dart';
import 'welcome_screen.dart';
import 'activities_and_interests_screen.dart';
import 'other_informations_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required Key key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginUser(String username, String password) async {
    const url = 'http://192.168.1.86/buddy-backend/user/login.php';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'username': username,
        'password': password,
      },
    );

    final responseData =
        json.decode(response.body); // Response'u JSON olarak decode edin.

    if (response.statusCode == 200) {
      if (responseData['status'] == 'success') {
        // Giriş başarılı durumu
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', responseData['token']);

        // Eksik profil bilgilerini kontrol etme ve yönlendirme
        if (responseData['profile_status'] == true) {
          // Profil tam ise ana sayfaya yönlendir
          /* Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage())); */
        } else {
          /*  eksik bilgilerden activities veya interests 
              eksikse ActivitiesAndInterestsScreen
              sayfasına yönlendir. diğer bilgilerden herhangi biri eksikse 
              OtherInformationsScreen
              sayfasına yönlendir.
          */
          dynamic missingInfo = responseData['missing_info'];
          if (missingInfo.contains('activities') ||
              missingInfo.contains('interests')) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) =>
                  ActivitiesAndInterestsScreen(missingInfo: missingInfo),
            ));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => OtherInformationsScreen(
                    missingInfo: responseData['missing_info'])));
          }
        }
      } else {
        // Hata durumu (Kullanıcı adı bulunamadı veya şifre yanlış)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(responseData['message']),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Try Again'),
                ),
              ],
            );
          },
        );
      }
    } else {
      // Sunucu tarafında bir hata oluştu
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Logo image
            Image.asset(
              'assets/images/Logo.png',
              height: 300,
            ),
            const SizedBox(height: 48),
            // Email/Username input field
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16),
            // Password input field
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            // Forgot password button/text
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 32),
            // Login button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: CustomButton(
                text: 'Login',
                onPressed: () {
                  // Get the values from the input fields
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  loginUser(username, password);
                },
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
                        builder: (context) => WelcomeScreen(key: UniqueKey())),
                  );
                },
                child: const Text('Back to Welcome Screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
