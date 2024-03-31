import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'register_tourist_screen.dart';
import 'register_guide_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make padding responsive to screen size
    final EdgeInsets padding = MediaQuery.of(context).size.width > 600
        ? const EdgeInsets.symmetric(horizontal: 120.0, vertical: 24.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0);

    return Scaffold(
      body: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Use the logo image provided
            Image.asset(
              'assets/images/Logo2.png', // Update the path to where your logo is located
              height: 250, // Adjust the size accordingly
            ),
            const SizedBox(height: 48),
            // Refactor CustomButton to use a more general style that matches the logo
            CustomButton(
              text: 'Register as Tourist',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterTouristScreen()),
                );
              },
              color:
                  Colors.blue.shade600, // Use the primary color from the theme
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
              color:
                  Colors.blue.shade600, // Use the primary color from the theme
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
                    color: Colors
                        .blueGrey, // Choose a color that matches your logo
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
