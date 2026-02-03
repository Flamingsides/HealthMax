import 'package:flutter/material.dart';

// A purple background gradient for the user login and welcome pages
final bgGradient1 = const BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      // TODO: Get gradient details from Tengku
      Color.fromARGB(255, 73, 71, 175),
      Color.fromARGB(255, 77, 78, 175),
      Color.fromARGB(255, 77, 80, 170),
      Color.fromARGB(255, 152, 173, 223),
    ],
    stops: [0.0, 0.4, 0.6, 1.0],
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
        padding: EdgeInsets.all(19),
        width: double.infinity,
        decoration: bgGradient1,
        child: child,
      ),
    );
  }
}

// Back button that runs Navigator.pop() when pressed
class BackButton extends StatelessWidget {
  const BackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              iconColor: Colors.white,
              backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(30),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, size: 35),
          ),
        ),
      ],
    );
  }
}
