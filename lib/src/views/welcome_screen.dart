import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'register_tourist_screen.dart';
import 'register_guide_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: CustomButton(
                text: 'Register as Tourist',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterTouristScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: CustomButton(
                text: 'Register as Guide',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterGuideScreen()),
                  );
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
                        builder: (context) => LoginScreen(key: UniqueKey())),
                  );
                },
                child: const Text('Already have an account? Sign in'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
