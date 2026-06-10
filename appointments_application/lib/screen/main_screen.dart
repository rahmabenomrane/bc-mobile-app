import 'package:appointments_application/config/Palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AppFooter.dart';
import 'RDVs_List.dart';
import 'home_page.dart';

class MainScreen extends StatefulWidget {
  final String token;
  final String customerNumber;
  const MainScreen({
    required this.token,
    Key? key ,
    required this.customerNumber
  }) : super(key: key);

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
      onNavigate: (index) {
    setState(() {
    _currentIndex = index;
    });}
      ),

      Container(),
      Container(),
      // MapScreen(),
    ];

    return Scaffold(
      backgroundColor: Palette.homePageBackground,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: SizedBox(
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
    );
  }

}