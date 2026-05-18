import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/Palette.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isEven) {
          int step = index ~/ 2 + 1;
          bool isActive = step <= currentStep;

          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isActive
                  ? LinearGradient(
                colors: [
                  Palette.gradientFirst,
                  Palette.gradientSecond,
                ],
              )
                  : null,
              border: Border.all(
                color: isActive
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                "$step",
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        } else {
          // Ligne entre cercles
          int step = (index ~/ 2) + 1;
          bool isActive = step < currentStep;

          return Expanded(
            child: Container(
              height: 3,
              color: isActive
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
            ),
          );
        }
      }),
    );
  }
}