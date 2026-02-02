// dart format width=68
import 'package:flutter/material.dart';
import 'pages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isSignedIn = false;

  // Root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMax',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 35,
            fontFamily: "LexendExaNormal",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 25,
            fontFamily: "LexendExaNormal",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            fontFamily: "LexendDecaNormal",
          ),
        ),
      ),
      home: isSignedIn ? UserDashboard() : WelcomePage(),
    );
  }
}
