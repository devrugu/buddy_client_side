import 'package:flutter/material.dart';

import 'src/views/welcome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade800,
          elevation: 0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue.shade600,
          textTheme: ButtonTextTheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: Colors.blueAccent),
          bodyMedium: TextStyle(color: Colors.blueGrey),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
      home: const WelcomeScreen(key: Key('welcome_screen')),
    );
  }
}

void main() {
  runApp(MyApp(key: GlobalKey()));
}
