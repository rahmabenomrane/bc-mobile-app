// lib/screen/home_page.dart
import 'package:appointments_application/screen/RDVs_List.dart';
import 'package:appointments_application/screen/vehicle_selection.dart';
import 'package:flutter/material.dart';
import 'package:appointments_application/config/Palette.dart' as color;

import 'Locations_page.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;
  final String customerNumber; // ← MODIFIÉ : plus de variable globale

  const HomePage({
    Key? key,
    this.onNavigate,
    required this.customerNumber, // ← MODIFIÉ
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildEnhancedServiceCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.Palette.gradientSecond, size: 38),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Material(
        color: color.Palette.homePageBackground,
        child: CustomScrollView(
          slivers: [

            // SECTION 1 : Logo
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              sliver: SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Center(
                    child: Image.asset("images/STA.jpg", height: 40),
                  ),
                ),
              ),
            ),

            // SECTION 2 : Vos rendez-vous
            SliverPadding(
              padding:
              const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Vos Rendez-vous",
                        style: TextStyle(
                          fontSize: 20,
                          color: color.Palette.homePageSubtitle,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => widget.onNavigate?.call(1),
                      child: Row(
                        children: [
                          Text(
                            "Détails",
                            style: TextStyle(
                              fontSize: 20,
                              color: color.Palette.homePageDetail,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.arrow_forward,
                              size: 20, color: color.Palette.homePageIcons),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // SECTION 3 : Carte Gradient
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.Palette.gradientFirst.withOpacity(0.8),
                        color.Palette.gradientSecond.withOpacity(0.9),
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                      topRight: Radius.circular(80),
                    ),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(5, 10),
                        blurRadius: 20,
                        color:
                        color.Palette.gradientSecond.withOpacity(0.2),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, top: 25, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Prochain Rendez-vous",
                            style: TextStyle(
                                fontSize: 16,
                                color:
                                color.Palette.homePageContainerTextSmall)),
                        const SizedBox(height: 5),
                        Text("Agence Lac1",
                            style: TextStyle(
                                fontSize: 25,
                                color:
                                color.Palette.homePageContainerTextSmall)),
                        const SizedBox(height: 5),
                        Text("Service Réparation",
                            style: TextStyle(
                                fontSize: 25,
                                color:
                                color.Palette.homePageContainerTextSmall)),
                        const SizedBox(height: 25),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.timer,
                                    size: 20,
                                    color: color
                                        .Palette.homePageContainerTextSmall),
                                const SizedBox(width: 10),
                                Text("19/04/2026 10h",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: color.Palette
                                            .homePageContainerTextSmall)),
                              ],
                            ),
                            Expanded(child: Container()),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.Palette.gradientFirst,
                                    blurRadius: 10,
                                    offset: const Offset(4, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.play_circle_fill,
                                  color: Colors.white, size: 60),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // SECTION 4 : SAV Image Stack
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 30),
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                              image: AssetImage("images/SAV.png"),
                              fit: BoxFit.fill),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 40,
                                offset: const Offset(8, 10),
                                color: color.Palette.gradientSecond
                                    .withOpacity(0.3)),
                            BoxShadow(
                                blurRadius: 10,
                                offset: const Offset(-1, -5),
                                color: color.Palette.gradientSecond
                                    .withOpacity(0.3)),
                          ],
                        ),
                      ),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(right: 200, bottom: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                              image: AssetImage("assets/figure.png")),
                        ),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 100,
                        margin: const EdgeInsets.only(left: 150, top: 50),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Service client d'exception",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: color.Palette.homePageDetail)),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                text: "Des techniciens certifiés\n",
                                style: TextStyle(
                                    color: color.Palette.homePagePlanColor,
                                    fontSize: 16),
                                children: const [
                                  TextSpan(text: "à votre service"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SECTION 5 : Titre "Nos Services"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 35, vertical: 15),
                child: Text(
                  "Nos Services",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                    color: color.Palette.homePageTitle,
                  ),
                ),
              ),
            ),

            // SECTION 6 : Grille de services
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              sliver: SliverGrid(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate([

                  _buildEnhancedServiceCard(
                    title: "Prendre RDV",
                    icon: Icons.calendar_month,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleSelectionScreen(
                            customerNumber: widget.customerNumber, // ← du token
                          ),
                        ),
                      );
                    },
                  ),

                  _buildEnhancedServiceCard(
                    title: "Réclamations",
                    icon: Icons.report_problem,
                    onTap: () {
                      // TODO
                    },
                  ),

                  _buildEnhancedServiceCard(
                    title: "News",
                    icon: Icons.campaign,
                    onTap: () {
                      // TODO
                    },
                  ),
                  _buildEnhancedServiceCard(
                    title: "Agences",
                    icon: Icons.map_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MapScreen(),
                        ),
                      );
                    },
                  ),

                ]),
              ),
            ),

            // Espace footer
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 100),
              sliver: SliverToBoxAdapter(child: SizedBox()),
            ),
          ],
        ),
      ),
    );
  }
}