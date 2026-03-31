import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthmax_frontend/UserPages/user_provider.dart';
import 'package:provider/provider.dart';

// Supabase
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Theme & Provider ---
import 'theme_provider.dart';
import '../GeneralPages/auth_provider.dart';
import 'UserPages/calorie_provider.dart';
import 'UserPages/goal_provider.dart';

// --- General & User Pages ---
import 'GeneralPages/welcome_page.dart';
import 'UserPages/user_homepage.dart';
import 'UserPages/HistoryPages/user_history_calorie.dart';
import 'UserPages/user_calorie.dart';
import 'UserPages/user_statistic.dart';
import 'UserPages/user_target.dart';
import 'UserPages/user_settings.dart';
import 'UserPages/user_log_food.dart';

// --- HP Pages ---
import 'package:healthmax_frontend/HPPages/hp_settings.dart';
import 'HPPages/hp_homepage.dart';
import 'HPPages/hp_userspage.dart';
import 'HPPages/hp_requestspage.dart';

void main() async {
  // Ensure Flutter bindings are initialized before loading .env
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialise supabase
  await Supabase.initialize(
    url: "https://rjxzxtqaiakwofgkegwl.supabase.co",
    // Publishable key (safe to use here)
    anonKey: "sb_publishable_503KzCdmIJFjM8rswosVPQ_qBxwvS51",
  );

  runApp(
    // The Provider sits at the very top of the app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CalorieProvider()),
        ChangeNotifierProvider(create: (context) => GoalProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
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
      home: isSignedIn ? const UserHomePage() : const WelcomePage(),

      routes: {
        // Healthcare Provider routes
        '/hp_home': (context) => const HPHomePage(),
        '/hp_users': (context) => const HPUsersPage(),
        '/hp_requests': (context) => const HPRequestsPage(),
        '/hp_settings': (context) => const HPSettingsPage(),

        // User routes
        '/user_homepage': (context) => const UserHomePage(),
        '/user_history': (context) => const UserHistoryCaloriePage(),
        '/user_calorie': (context) => const UserCaloriePage(),
        '/user_statistic': (context) => const UserStatisticPage(),
        '/user_target': (context) => const UserTargetPage(),
        '/user_settings': (context) => const UserSettingsPage(),
        '/user_log_food': (context) => const UserLogFoodPage(),
      },
    );
  }
}
