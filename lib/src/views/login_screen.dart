// ignore_for_file: use_build_context_synchronously, duplicate_ignore

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
      if (!responseData['error']) {
        // Giriş başarılı durumu
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', responseData['token']);

        // Eksik profil bilgilerini kontrol etme ve yönlendirme
        if (responseData['profile_status']) {
          // Profil tam ise ana sayfaya yönlendir
          // TODO: Ana sayfa ekranına yönlendirme yapılacak
        } else {
          // Eksik profil bilgileri varsa ilgili ekranlara yönlendir
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
                    OtherInformationsScreen(missingInfo: missingInfo)));
          }
        }
      } else {
        // Hata durumu (Kullanıcı adı bulunamadı veya şifre yanlış)
        WarningMessages.error(context, responseData['message']);
      }
    } else {
      // Sunucu tarafında bir hata oluştu
      WarningMessages.error(
          context, 'An error occurred. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theming for text fields to match the app's overall aesthetic
    final InputDecoration textFieldDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      filled: true,
      fillColor: Colors.white.withAlpha(235),
      labelStyle: TextStyle(color: Colors.blue.shade600),
    );

    return Scaffold(
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView to avoid overflow when keyboard is visible
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo image
              Image.asset(
                'assets/images/Logo2.png', // Make sure this path is correct
                height:
                    200, // Adjusted size to provide more space for other elements
              ),
              const SizedBox(height: 48),
              // Username input field
              TextFormField(
                controller: _usernameController,
                cursorColor: Colors.blue.shade600, // İmleç rengini ayarlar
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    // Normal durumda görünen sınır
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                        color: Colors.green), // Sınır rengini ayarlar
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Odaklanılmadığında görünen sınır
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 0, 0, 0)), // Sınır rengini ayarlar
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Odaklanıldığında görünen sınır
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                        color: Colors.blueAccent), // Sınır rengini ayarlar
                  ),
                  fillColor: Colors.white.withAlpha(235), // Arka plan rengi
                  filled: true, // Arka plan renginin görünür olmasını sağlar
                  labelStyle: TextStyle(
                      color: Colors.blue.shade600), // Etiket metni stili
                ),
              ),
              const SizedBox(height: 16),
              // Password input field
              TextFormField(
                controller: _passwordController,
                cursorColor: Colors.blue.shade600, // İmleç rengini ayarlar
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    // Normal durumda görünen sınır
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                        color: Colors.green), // Sınır rengini ayarlar
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Odaklanılmadığında görünen sınır
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(
                            255, 0, 0, 0)), // Sınır rengini ayarlar
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Odaklanıldığında görünen sınır
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: const BorderSide(
                        color: Colors.blueAccent), // Sınır rengini ayarlar
                  ),
                  fillColor: Colors.white.withAlpha(235), // Arka plan rengi
                  filled: true, // Arka plan renginin görünür olmasını sağlar
                  labelStyle: TextStyle(
                      color: Colors.blue.shade600), // Etiket metni stili
                ),
                obscureText: true, // Ensure password is obscured
              ),
              const SizedBox(height: 16),
              // Forgot password button/text
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
              // Login button
              CustomButton(
                text: 'Login',
                onPressed: () {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  loginUser(username, password); // loginUser function call
                },
                color: Colors.blue.shade600,
                textStyle: const TextStyle(
                    color: Colors.white), // Text style for the button
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      // Use pushReplacement to avoid building a stack of screens
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
