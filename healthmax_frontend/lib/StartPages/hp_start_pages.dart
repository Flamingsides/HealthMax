import 'package:flutter/material.dart';
import 'start_pages_base.dart'; 
import '../helper_widgets.dart'; // Up one folder to get bgGradientHP

class HPStartPage extends StatelessWidget {
  const HPStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StartPage(
      heading1: "CARE",
      heading2: "Beyond Clinic",
      decoration: bgGradientHP,
      loginPage: (_) => const HPLoginPage(),
      registrationPage: (_) => const HPRegistrationPage(),
    );
  }
}

class HPRegistrationPage extends StatelessWidget {
  const HPRegistrationPage({super.key});

  // Function to show the "Inclosable" Notification
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) { // Use a specific name for dialog context
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Verification Required"),
          content: const Text(
            "Thank you for registering. Please wait for ID verification from our administrative team.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 1. Close the Dialog
                Navigator.of(dialogContext).pop(); 
                
                // 2. Close the Registration Page to go back to StartPage
                Navigator.of(context).pop(); 
              },
              child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationPage(
      decoration: bgGradientHP,
      onRegisterPressed: () => _showVerificationDialog(context), // Trigger the dialog
      loginPage: (_) => const HPLoginPage(),
    );
  }
}

class HPLoginPage extends StatelessWidget {
  const HPLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      decoration: bgGradientHP,
      registrationPage: (_) => const HPRegistrationPage(),
    );
  }
}