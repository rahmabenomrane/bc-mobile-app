import 'package:appointments_application/config/Palette.dart';
import 'package:appointments_application/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import 'AppFooter.dart';
import 'RDVs_List.dart';
import 'home_page.dart';

class MainScreen extends StatefulWidget {
  final String token;
  final String customerNumber;
  const MainScreen({
    required this.token,
    super.key ,
    required this.customerNumber
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      HomePage(
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        customerNumber: widget.customerNumber,
      ),
      RdvsList(
        customerNumber: widget.customerNumber,
          showHistory: false,
      onNavigate: (index) {
    setState(() {
    _currentIndex = index;
    });}
      ),

      ProfileScreen(
        onGoHome: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      RdvsList(
        customerNumber: widget.customerNumber,
        showHistory: true,
      ),
      Container(),

    ];

    return Scaffold(
      backgroundColor: Palette.homePageBackground,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            height: 90,
            child: AppFooter(
              currentIndex: _currentIndex,
              onTap: (i) {
                setState(() {
                  _currentIndex = i;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

}