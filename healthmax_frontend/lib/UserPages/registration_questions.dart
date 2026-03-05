import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/helper_widgets.dart';

class HorizontalBar extends StatelessWidget {
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;
  const HorizontalBar({
    super.key,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(3),
        child: SizedBox(
          height: 10,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(50)),
              color: isActive
                  ? activeColor ?? Colors.black
                  : inactiveColor ?? Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final int current;
  final int countBars;

  const ProgressBar({
    super.key,
    required this.current,
    required this.countBars,
  });

  @override
  Widget build(BuildContext context) {
    List<HorizontalBar> bars = List.generate(
      countBars,
      (index) => HorizontalBar(isActive: index == current),
    );

    return Row(children: bars);
  }
}

class RegistrationQuestions extends StatelessWidget {
  final int numQuestions;
  final int currentIndex;
  const RegistrationQuestions({
    super.key,
    required this.numQuestions,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      child: ListView(
        children: [ProgressBar(current: currentIndex, countBars: numQuestions)],
      ),
    );
  }
}
