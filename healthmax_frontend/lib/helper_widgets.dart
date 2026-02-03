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

class CustomInputBox extends StatelessWidget {
  final String hint;
  const CustomInputBox({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 1.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Color.fromRGBO(255, 255, 255, 1.0)),
        ),
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(20),
        fillColor: Color.fromRGBO(233, 15, 15, 0.4),
        labelStyle: TextStyle(
          fontSize: 16,
          fontFamily: "LexendGigaNormal",
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        hint: Text(
          hint,
          style: TextStyle(
            fontSize: 16,
            fontFamily: "LexendGigaNormal",
            color: Color.fromRGBO(255, 255, 255, 0.6),
          ),
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final Color? textColor;
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.buttonStyle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed:
          onPressed ??
          () {
            print("$label button clicked!");
          },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          label,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontFamily: "LexendDecaNormal",
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

class CustomShortButton extends CustomButton {
  final double width;
  const CustomShortButton({
    super.key,
    required super.label,
    required this.width,
    super.onPressed,
    super.buttonStyle,
    super.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: width, child: super.build(context)),
    );
  }
}

class CustomQuestionLink extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback? onPressed;
  const CustomQuestionLink({
    super.key,
    required this.question,
    required this.linkText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(question, textAlign: TextAlign.right),
        TextButton(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(3, 10, 15, 10)),
          ),
          onPressed: onPressed ?? () => print("$linkText link pressed"),
          child: Text(
            linkText,
            style: TextStyle(color: Color.fromRGBO(65, 0, 98, 1)),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

// Custom heading for Hello! on registration page
class CustomHeading1 extends StatelessWidget {
  final String text;
  const CustomHeading1({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 48,
        fontFamily: "LexendDecaNormal",
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1.5,
      ),
    );
  }
}

class CustomHeading2 extends StatelessWidget {
  final String text;
  const CustomHeading2({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontFamily: "LexendGigaNormal",
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
