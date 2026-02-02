import 'package:flutter/material.dart';
import 'helper_widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
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

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Complete UserDashboard widget
    return const Text("User Dashboard");
  }
}
