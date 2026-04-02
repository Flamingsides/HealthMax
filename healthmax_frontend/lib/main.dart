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
import 'UserPages/hp_providers.dart';
import 'GeneralPages/health_providers.dart';
import 'UserPages/feedback_provider.dart';

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
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: "https://rjxzxtqaiakwofgkegwl.supabase.co",
    anonKey: "sb_publishable_503KzCdmIJFjM8rswosVPQ_qBxwvS51",
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CalorieProvider()),
        ChangeNotifierProvider(create: (context) => GoalProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => HPProvider()), 
        ChangeNotifierProvider(create: (context) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthMax',
      themeMode: themeProvider.themeMode,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,

      // ==========================================
      // PHASE 3: GLOBAL ACCESSIBILITY SCALER
      // ==========================================
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            // textScaleFactor is deprecated. TextScaler is the modern standard!
            textScaler: TextScaler.linear(themeProvider.fontScale), 
          ),
          child: child!,
        );
      },

      home: isSignedIn ? const UserHomePage() : const WelcomePage(),
      routes: {
        '/hp_home': (context) => const HPHomePage(),
        '/hp_users': (context) => const HPUsersPage(),
        '/hp_requests': (context) => const HPRequestsPage(),
        '/hp_settings': (context) => const HPSettingsPage(),
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