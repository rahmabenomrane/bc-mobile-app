import 'package:appointments_application/config/Palette.dart';
import 'package:appointments_application/screen/profile_screen.dart';
import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import 'AppFooter.dart';
import 'Locations_page.dart';
import 'RDVs_List.dart';
import 'chatbot_floating_button.dart';
import 'home_page.dart';

class MainScreen extends StatefulWidget {
  final String token;
  final String customerNumber;

  const MainScreen({
    required this.token,
    required this.customerNumber,
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showNextRdvs = false;

  final GlobalKey<RdvsListState> historyRdvKey = GlobalKey<RdvsListState>();

  void openNextRdvs() {
    setState(() {
      _showNextRdvs = true;
    });
  }

  void closeNextRdvs() {
    setState(() {
      _showNextRdvs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        customerNumber: widget.customerNumber,
        onNavigate: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onOpenRdvs: openNextRdvs,
      ),
      ProfileScreen(
        onGoHome: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      RdvsList(
        key: historyRdvKey,
        customerNumber: widget.customerNumber,
        showHistory: true,
      ),
      MapScreen(
        fromFooter: true,
        selectedVehicle: Vehicle.empty(),
      ),
    ];

    return Scaffold(
      backgroundColor: Palette.homePageBackground,
      extendBody: true,
      body: Stack(
        children: [
          _showNextRdvs
              ? RdvsList(
            customerNumber: widget.customerNumber,
            showHistory: false,
            onNavigate: (index) {
              setState(() {
                _showNextRdvs = false;
                _currentIndex = index;
              });
            },
          )
              : IndexedStack(
            index: _currentIndex,
            children: pages,
          ),

          const ChatbotFloatingButton(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: SizedBox(
          height: 90,
          child: AppFooter(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _showNextRdvs = false;
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}