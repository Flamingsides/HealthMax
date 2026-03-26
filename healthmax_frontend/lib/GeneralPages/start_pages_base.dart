import 'package:flutter/material.dart' hide BackButton;
import 'helper_widgets.dart';

class StartPage extends StatelessWidget {
  final String heading1;
  final String heading2;
  final WidgetBuilder loginPage;
  final WidgetBuilder registrationPage;
  final BoxDecoration? decoration; 
  final VoidCallback? onLoginSuccess; 
  final String homeRoute; // 1. Added property for dynamic routing

  const StartPage({
    super.key,
    required this.heading1,
    required this.heading2,
    required this.loginPage,
    required this.registrationPage,
    required this.homeRoute, // Added to constructor
    this.decoration, 
    this.onLoginSuccess, 
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: decoration, 
      child: ListView(
        children: [
          BackButton(),
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
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        registrationPage: registrationPage, 
                        decoration: decoration, 
                        onLoginSuccess: onLoginSuccess,
                        homeRoute: homeRoute, 
                      ),
                    ),
                  );
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200, // LIGHT GREY FIX!
                  padding: const EdgeInsets.all(5),
                ),
                textColor: Colors.black87, // Dark text to contrast with the light button
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: "REGISTER",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: registrationPage));
                },
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200, // LIGHT GREY FIX!
                  padding: const EdgeInsets.all(5),
                ),
                textColor: Colors.black87, // Dark text
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
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: bgGradientHP,
      child: ListView(
        children: [
          BackButton(),
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
  final BoxDecoration? decoration; 
  final VoidCallback? onLoginSuccess; 
  final String homeRoute; // 3. Added property to catch the route

  const LoginPage({
    super.key, 
    required this.registrationPage, 
    required this.homeRoute, // Added to constructor
    this.decoration, 
    this.onLoginSuccess
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: decoration, 
      child: ListView(
        children: [
          BackButton(),
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
          CustomShortButton(
            label: "Login", 
            width: 200,
            onPressed: (){
              // 4. If a custom success callback is provided, use it. Otherwise, route dynamically.
              if (onLoginSuccess != null) {
                onLoginSuccess!();
              } else {
                Navigator.pushNamedAndRemoveUntil( 
                  context,
                  homeRoute, // Dynamic routing applied here
                  (route) => false
                );
              }
            },),
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