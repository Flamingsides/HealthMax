import 'package:flutter/material.dart';
import './helper_widgets.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          "Oops! This page does not exist!",
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
