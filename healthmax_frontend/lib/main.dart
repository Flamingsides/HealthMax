import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// --- Theme & Provider ---
import 'theme_provider.dart';

// --- General & User Pages ---
import 'GeneralPages/welcome_page.dart';
import 'UserPages/user_homepage.dart';
import 'UserPages/HistoryPages/user_history_calorie.dart';
import 'UserPages/user_calorie.dart';
import 'UserPages/user_statistic.dart';
import 'UserPages/user_target.dart';
import 'UserPages/user_settings.dart';

// --- HP Pages ---
import 'package:healthmax_frontend/HPPages/hp_settings.dart';
import 'HPPages/hp_homepage.dart';
import 'HPPages/hp_userspage.dart';
import 'HPPages/hp_requestspage.dart';

void main() async {
  // Ensure Flutter bindings are initialized before loading .env
  WidgetsFlutterBinding.ensureInitialized(); 
  await dotenv.load(fileName: '.env');
  
  runApp(
    // 1. The Provider sits at the very top of the app
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    // 2. The app listens to the ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthMax',
      
      // 3. Magic happens here: The app switches based on the provider's state
      themeMode: themeProvider.themeMode,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      
      // Added const for performance optimization
      home: isSignedIn ? const UserHomePage(): const WelcomePage(),
      
      routes: {
        // Healthcare Provider routes
        '/hp_home': (context) => const HPHomePage(),
        '/hp_users': (context) => const HPUsersPage(),
        '/hp_requests': (context) => const HPRequestsPage(),
        '/hp_settings': (context) => const HPProfileClicked(),

        // User routes
        '/user_homepage': (context) => const UserHomePage(),
        '/user_history': (context) => const UserHistoryCaloriePage(),
        '/user_calorie': (context) => const UserCaloriePage(),
        '/user_statistic': (context) => const UserStatisticPage(),
        '/user_target': (context) => const UserTargetPage(),
        '/user_settings': (context) => const UserSettingsPage(),
      },
    );
  }
}