import 'package:flutter/material.dart' hide BackButton;
import 'helper_widgets.dart';

class StartPage extends StatelessWidget {
  final String heading1;
  final String heading2;
  final WidgetBuilder loginPage;
  final WidgetBuilder registrationPage;
  final BoxDecoration? decoration; // Added property

  const StartPage({
    super.key,
    required this.heading1,
    required this.heading2,
    required this.loginPage,
    required this.registrationPage,
    this.decoration, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: decoration, // Pass it to Screen
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 100),
          Text(
            heading1,
            style: const TextStyle(
              fontSize: 45,
              fontFamily: "LexendTeraNormal",
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            heading2,
            style: const TextStyle(
              fontSize: 30,
              fontFamily: "LexendMegaNormal",
              color: Color.fromARGB(255, 249, 234, 67),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 300),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomButton(
                label: "LOGIN",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: loginPage));
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: const BorderSide(color: Color.fromARGB(51, 0, 0, 0)),
                  padding: const EdgeInsets.all(5),
                ),
                textColor: Colors.white,
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: "REGISTER",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: registrationPage));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  final WidgetBuilder postRegistration;
  final WidgetBuilder loginPage;

  const RegistrationPage({
    super.key, 
    required this.loginPage,
    required this.postRegistration,
     // Add this to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: bgGradientHP,
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 50),
          const CustomHeading1(text: "Hello!"),
          const SizedBox(height: 3),
          const CustomHeading2(text: "Register to get started!"),
          const SizedBox(height: 30),
          const CustomInputBox(hint: "Username"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Email"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Password"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Confirm Password"),
          const SizedBox(height: 50),
          // TODO: Add functionality to button
          CustomShortButton(
            label: "Register",
            width: 200,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: postRegistration),
              );
            },
          ),
          CustomQuestionLink(
            question: "Already have an account?",
            linkText: "Login now!",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: loginPage));
            },
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final WidgetBuilder registrationPage;
  final BoxDecoration? decoration; // Added property

  const LoginPage({super.key, required this.registrationPage, this.decoration});

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: decoration, // Pass it to Screen
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 50),
          const CustomHeading1(text: "Welcome"),
          const CustomHeading1(text: "back!"),
          const SizedBox(height: 10),
          const CustomHeading2(text: "Glad to see you again!"),
          const SizedBox(height: 30),
          const CustomInputBox(hint: "Username"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Password"),
          const SizedBox(height: 50),
          const CustomShortButton(label: "Login", width: 200),
          CustomQuestionLink(
            question: "Don't have an account?",
            linkText: "Register Now!",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: registrationPage));
            },
          ),
        ],
      ),
    );
  }
}