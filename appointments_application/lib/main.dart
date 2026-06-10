import 'package:flutter/material.dart';
import 'package:appointments_application/screen/login_signup.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async{
  runApp(const LoginSignupUI());
  final storage = FlutterSecureStorage();
  await storage.delete(key: "token");
  await storage.delete(key: "customerNumber");
  await storage.delete(key: "customerEmail");
}

class LoginSignupUI extends StatelessWidget {
  const LoginSignupUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: LoginSignupScreen(),
    );
  }
}
