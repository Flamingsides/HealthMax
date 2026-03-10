import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/helper_widgets.dart';

class RegistrationQuestions extends StatelessWidget {
  final int numQuestions;
  final int currentIndex;
  final List<Widget>? children;
  const RegistrationQuestions({
    super.key,
    required this.numQuestions,
    required this.currentIndex,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: bgWhite,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: ProgressBar(current: currentIndex, countBars: numQuestions),
          ),
          ...children ?? [],
        ],
      ),
    );
  }
}

class RegistrationGender extends StatelessWidget {
  const RegistrationGender({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 4,
      currentIndex: 0,
      children: [
        const SizedBox(height: 100),
        Text(
          "Select your Gender",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: "LexendExaNormal",
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.male, size: 150, color: Colors.blueAccent),
                  Text(
                    "Male",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: "LexendExaNormal",
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Icon(Icons.female, size: 150, color: Colors.purpleAccent),
                  Text(
                    "Female",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      fontFamily: "LexendExaNormal",
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RegistrationAge extends StatelessWidget {
  const RegistrationAge({super.key});

  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 4,
      currentIndex: 1,
      children: [
        const SizedBox(height: 100),
        Text(
          "Enter your Age",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: "LexendExaNormal",
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
