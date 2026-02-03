import 'package:flutter/material.dart' hide BackButton;
import 'helper_widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: ListView(
        children: [
          const SizedBox(height: 80),
          Text(
            "Welcome",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 80),
          Text(
            "HealthMax: Your Virtual Health Companion",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 150),
          Center(
            child: SizedBox(
              width: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UserStartPage()),
                      );
                    },
                    child: Text(
                      "User",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Link to healthcare provider sign in
                      print("Healthcare Provider chosen");
                    },
                    child: Text(
                      "Healthcare Provider",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserStartPage extends StatelessWidget {
  const UserStartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 100),
          Text(
            "WELLNESS",
            style: TextStyle(
              fontSize: 45,
              fontFamily: "LexendTeraNormal",
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "BEGINS HERE",
            style: TextStyle(
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(150, 171, 222, 0.0),
                  // shadowColor: Color.fromARGB(51, 0, 0, 0),
                  side: BorderSide(color: Color.fromARGB(51, 0, 0, 0)),
                  padding: EdgeInsets.all(5),
                ),
                onPressed: () {
                  // TODO: Link to user login page
                  print("Login chosen");
                },
                child: Text(
                  "LOGIN",
                  // TODO: change style to match
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: "LexendDecaNormal",
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(5)),
                onPressed: () {
                  // TODO: Link to user registration page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UserRegistrationPage()),
                  );
                },
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: "LexendDecaNormal",
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserRegistrationPage extends StatelessWidget {
  const UserRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: ListView(
        children: [
          const BackButton(),
          const SizedBox(height: 50),
          Text(
            "Hello!",
            style: TextStyle(
              fontSize: 48,
              fontFamily: "LexendDecaNormal",
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            "Register to get started!",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "LexendGigaNormal",
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),
          const CustomInputBox(hint: "Username"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Email"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Password"),
          const SizedBox(height: 20),
          const CustomInputBox(hint: "Confirm Password"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print("Register button clicked!");
            },
            child: const Text("Register"),
          ),
          const SizedBox(height: 20),
          Text(
            "Already have an account? Login now!",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Complete UserDashboard widget
    return const Text("User Dashboard");
  }
}
