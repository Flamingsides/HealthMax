import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthmax_frontend/GeneralPages/welcome_page.dart';
import 'package:healthmax_frontend/UserPages/user_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- Import Providers ---
import '../../UserPages/calorie_provider.dart';
import '../../GeneralPages/health_providers.dart';
import '../../UserPages/goal_provider.dart';
import '../../UserPages/hp_providers.dart';
import '../../UserPages/feedback_provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;
        
        if (session != null) {
          // --- THE DATA BRIDGE ---
          // When a session exists, we force the Providers to fetch the live Supabase data 
          // BEFORE we allow the UserHomePage to render.
          return FutureBuilder(
            future: Future.wait([
              Provider.of<CalorieProvider>(context, listen: false).fetchUserDataAndLogs(),
              Provider.of<HealthProvider>(context, listen: false).fetchHealthData(),
              Provider.of<GoalProvider>(context, listen: false).fetchGoalData(),
              Provider.of<HPProvider>(context, listen: false).fetchHPConnections(),
              Provider.of<FeedbackProvider>(context, listen: false).fetchFeedback(),

            ]),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                // Show a loading screen while Supabase data is being fetched
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFF5A84F1)),
                        SizedBox(height: 20),
                        Text("Syncing with HealthMax Cloud...", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              }
              // Once data is locked into the Providers, show the Homepage!
              return const UserHomePage();
            },
          );
        } else {
          return const WelcomePage();
        }
      },
    );
  }
}