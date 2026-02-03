import 'package:flutter/material.dart';
import 'start_pages_base.dart';

class HPStartPage extends StatelessWidget {
  const HPStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StartPage(
      heading1: "CARE",
      heading2: "Beyond Clinic",
      loginPage: (_) => HPLoginPage(),
      registrationPage: (_) => HPRegistrationPage(),
    );
  }
}

class HPRegistrationPage extends StatelessWidget {
  const HPRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationPage(loginPage: (_) => HPLoginPage());
  }
}

class HPLoginPage extends StatelessWidget {
  const HPLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage(registrationPage: (_) => HPRegistrationPage());
  }
}
