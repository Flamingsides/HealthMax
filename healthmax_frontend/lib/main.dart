// dart format width=68
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

// A purple background gradient for the user login and welcome pages
final bgGradient1 = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color.fromARGB(255, 73, 71, 175),
      Color.fromARGB(255, 152, 173, 223),
    ],
    stops: [0.0, 1.0],
  ),
);

class _MyAppState extends State<MyApp> {
  var isSignedIn = false;

  // Root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMax',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 35,
            fontFamily: "LexendExaNormal",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 25,
            fontFamily: "LexendExaNormal",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodySmall: TextStyle(fontSize: 20),
        ),
      ),
      home: isSignedIn ? UserDashboard() : WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // var screenSize = context.size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(12.0, 100, 12.0, 20),
        width: double.infinity,
        decoration: bgGradient1,
        child: ListView(
          children: [
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
                        // TODO: Link to user signin
                        print("User chosen");
                      },
                      child: Text(
                        "User",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall,
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
