import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/helper_widgets.dart';
import 'package:healthmax_frontend/GeneralPages/welcome_page.dart';
import 'package:healthmax_frontend/UserPages/user_homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (content, snapshot) {
        // If auth is loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Screen(child: Center(child: CircularProgressIndicator()));
        }

        // In case use is logged in (valid session exists)
        final session = snapshot.hasData ? snapshot.data!.session : null;
        if (session != null) {
          return UserHomePage();
        } else {
          return WelcomePage();
        }
      },
    );
  }
}
