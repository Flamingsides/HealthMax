import 'package:flutter/material.dart';
import '../GeneralPages/start_pages_base.dart';
import 'registration_intro.dart';

class UserStartPage extends StatelessWidget {
  const UserStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StartPage(
      heading1: "WELLNESS",
      heading2: "BEGINS HERE",
      homeRoute: '/user_homepage', // Pass the home route for dynamic navigation
      loginPage: (_) => const UserLoginPage(),
      registrationPage: (_) => const UserRegistrationPage(),
      onLoginSuccess: () {
        // Clears the stack and routes to the User Dashboard/Home
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user_homepage',
          (route) => false,
        );
      },
    );
  }
}

class UserRegistrationPage extends StatelessWidget {
  const UserRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationPage(
      role: "user", // <-- NEW: Tells the backend this is a standard User!
      loginPage: (_) => const UserLoginPage(),
      postRegistration: (_) => const RegistrationIntro(),
    );
  }
}

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      role: "user", // <-- NEW: Tells the backend this is a standard User!
      registrationPage: (_) => const UserRegistrationPage(),
      homeRoute: '/user_homepage',
    );
  }
}
