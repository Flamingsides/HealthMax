import 'package:flutter/material.dart';

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

// Screen template for welcome, user registration and user login pages.
class Screen extends StatelessWidget {
  final Widget child;
  const Screen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(12.0, 100, 12.0, 20),
        width: double.infinity,
        decoration: bgGradient1,
        child: child,
      ),
    );
  }
}
