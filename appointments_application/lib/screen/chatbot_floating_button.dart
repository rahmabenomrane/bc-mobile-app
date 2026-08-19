import 'package:flutter/material.dart';
import 'package:appointments_application/config/Palette.dart';
import 'package:appointments_application/screen/DiagnosticScreen.dart';

class ChatbotFloatingButton extends StatelessWidget {
  final bool showOnAllPages;

  const ChatbotFloatingButton({
    Key? key,
    this.showOnAllPages = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 140,
      child: GestureDetector(
        onTap: () {
          // Navigation vers DiagnosticScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiagnosticScreen(),
            ),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Palette.backgroundColor,
                Palette.secondPageIconColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.smart_toy_rounded,
            color: Colors.blueAccent,
            size: 32,
          ),
        ),
      ),
    );
  }
}