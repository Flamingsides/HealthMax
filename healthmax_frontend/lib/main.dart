// dart format width=68
import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/page_not_found.dart';
import 'GeneralPages/welcome_page.dart';
import 'UserPages/user_dashboard.dart';
import 'HPPages/hp_homepage.dart';
import 'HPPages/hp_userspage.dart';
import 'HPPages/hp_requestspage.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'HealthMax',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
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
            fontFamily: "LexendDecaNormal",
          ),
        ),
      ),
      home: isSignedIn ? UserDashboard() : WelcomePage(),
      routes: {
        '/hp_home': (context) => const HPHomePage(),
        '/hp_users': (context) => const HPUsersPage(),
        '/hp_requests': (context) => const HPRequestsPage(),
      },
    );
  }
}
