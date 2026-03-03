import 'dart:io';

import 'package:flutter/material.dart';
import '../GeneralPages/helper_widgets.dart';

class RegistrationIntro extends StatelessWidget {
  const RegistrationIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Text(
              "Start your Wellness Journey",
              style: TextStyle(
                fontFamily: "LexendExaNormal",
                fontWeight: FontWeight.w900,
                fontSize: 35,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            left: 0,
            top: 220,
            child: SizedBox(
              width: 200,
              child: Image(
                image: AssetImage("assets/images/registration-intro-move.png"),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 240,
            child: SizedBox(
              width: 170,
              child: Image(
                image: AssetImage("assets/images/registration-intro-track.png"),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 340,
            child: SizedBox(
              width: 143,
              child: Image(
                image: AssetImage("assets/images/registration-intro-rest.png"),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 380,
            child: SizedBox(
              width: 235,
              child: Image(
                image: AssetImage(
                  "assets/images/registration-intro-balance.png",
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 440,
            child: SizedBox(
              width: 134,
              child: Image(
                image: AssetImage("assets/images/registration-intro-plan.png"),
              ),
            ),
          ),
          Positioned(
            top: 600,
            left: 0,
            right: 0,
            child: Slider(value: 0, onChanged: (_) => {}),
          ),
        ],
      ),
    );
  }
}
