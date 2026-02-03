import 'package:flutter/material.dart';
import 'start_pages_base.dart';

class UserStartPage extends StatelessWidget {
  const UserStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StartPage(
      heading1: "WELLNESS",
      heading2: "BEGINS HERE",
      loginPage: (_) => UserLoginPage(),
      registrationPage: (_) => UserRegistrationPage(),
    );
  }
}

class UserRegistrationPage extends StatelessWidget {
  const UserRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationPage(loginPage: (_) => UserLoginPage());
  }
}

class UserLoginPage extends StatelessWidget {
  const UserLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage(registrationPage: (_) => UserRegistrationPage());
  }
}
