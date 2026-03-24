// dart format width=68
import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/page_not_found.dart';
import 'package:healthmax_frontend/HPPages/hp_profileclicked.dart';
import 'GeneralPages/welcome_page.dart';
import 'UserPages/user_dashboard.dart';
import 'HPPages/hp_homepage.dart';
import 'HPPages/hp_userspage.dart';
import 'HPPages/hp_requestspage.dart';
import 'UserPages/user_homepage.dart';
import 'UserPages/user_history.dart';
import 'UserPages/user_calorie.dart';
import 'UserPages/user_statistic.dart';
import 'UserPages/user_target.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
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
        '/hp_settings': (context) => const HPProfileClicked(),
        '/user_homepage': (context) => const UserHomePage(),
        '/user_history': (context) => const UserHistoryPage(),
        '/user_calorie': (context) => const UserCaloriePage(),
        '/user_statistic': (context) => const UserStatisticPage(),
        '/user_target': (context) => const UserTargetPage(),
        // Add more routes as needed
      },
    );
  }
}
