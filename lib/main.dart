import 'package:flutter/material.dart';
import 'src/views/welcome_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(key: Key('welcome_screen')),
    );
  }
}

void main() {
  runApp(MyApp(key: GlobalKey()));
}
