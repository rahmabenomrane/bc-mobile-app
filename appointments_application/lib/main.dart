import 'package:appointments_application/screen/RDVs_List.dart';
import 'package:appointments_application/screen/add_vehicle.dart';
import 'package:appointments_application/screen/home_page.dart';
import 'package:appointments_application/screen/main_screen.dart';
import 'package:appointments_application/screen/vehicle_selection.dart';
import 'package:flutter/material.dart';
import 'package:appointments_application/screen/login_signup.dart';
import 'package:get/get.dart';

void main() {
  runApp(const LoginSignupUI());
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
//HomePage
//LoginSignupScreen
//VehicleSelectionScreen