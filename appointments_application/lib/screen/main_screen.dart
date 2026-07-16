import 'package:appointments_application/config/Palette.dart';
import 'package:appointments_application/screen/profile_screen.dart';
import 'package:flutter/material.dart';

import '../models/vehicle_model.dart';
import 'AppFooter.dart';
import 'Locations_page.dart';
import 'RDVs_List.dart';
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


  // index du footer uniquement
  int _currentIndex = 0;


  // page interne (Mes RDVs)
  bool _showNextRdvs = false;



  final GlobalKey<RdvsListState> historyRdvKey =
  GlobalKey<RdvsListState>();



  void openNextRdvs(){

    setState(() {

      _showNextRdvs = true;

    });

  }



  void closeNextRdvs(){

    setState(() {

      _showNextRdvs = false;

    });

  }



  @override
  Widget build(BuildContext context) {


    final pages = [


      HomePage(

        customerNumber: widget.customerNumber,


        onNavigate: (index){

          setState(() {

            _currentIndex = index;

          });

        },


        onOpenRdvs: openNextRdvs,

      ),



      ProfileScreen(

        onGoHome: (){

          setState(() {

            _currentIndex = 0;

          });

        },

      ),



      // Historique du footer uniquement

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


      body: _showNextRdvs

          ?

      RdvsList(

        customerNumber: widget.customerNumber,

        showHistory: false,

      )


          :

      IndexedStack(

        index: _currentIndex,

        children: pages,

      ),




      bottomNavigationBar: SafeArea(

        bottom: true,

        child: SizedBox(

          height: 90,


          child: AppFooter(

            currentIndex: _currentIndex,


            onTap: (index){


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