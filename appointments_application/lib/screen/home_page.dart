// lib/screen/home_page.dart
import 'package:appointments_application/screen/RDVs_List.dart';
import 'package:appointments_application/screen/vehicle_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointments_application/config/Palette.dart' as color;
import 'Locations_page.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;
  final String customerNumber;

  const HomePage({
    Key? key,
    this.onNavigate,
    required this.customerNumber,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // ─── Service card ──────────────────────────────────────────────────────────

  Widget _buildEnhancedServiceCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconBg,
    Color? iconColor,
    String? badge,
  }) {
    final bg = iconBg    ?? color.Palette.gradientFirst.withOpacity(0.08);
    final fg = iconColor ?? color.Palette.gradientSecond;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: fg, size: 22),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.Palette.gradientFirst.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: color.Palette.gradientFirst,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color.Palette.homePageTitle,
              ),
            ),
            const SizedBox(height: 2),
            Icon(Icons.arrow_forward_rounded,
                size: 14, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Material(
        color: color.Palette.homePageBackground,
        child: CustomScrollView(
          slivers: [

            // ── SECTION 1 : App bar ─────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Image.asset("images/STA.jpg", height: 36),
                    const Spacer(),
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded,
                              size: 20, color: color.Palette.homePageTitle),
                          Positioned(
                            top: 8, right: 8,
                            child: Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(
                                color: color.Palette.gradientFirst,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── SECTION 2 : Titre ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos rendez-vous',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: color.Palette.homePageTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── SECTION 3 : Carte prochain RDV ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _buildNextRdvCard(context),
              ),
            ),

            // ── SECTION 4 : Banner SAV ──────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              sliver: SliverToBoxAdapter(child: _buildSavBanner()),
            ),

            // ── SECTION 5 : Titre services ──────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nos services',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: color.Palette.homePageTitle,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            // ── SECTION 6 : Grille services ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              sliver: SliverGrid(
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildListDelegate([
                  _buildEnhancedServiceCard(
                    title: 'Prendre RDV',
                    icon: Icons.calendar_month_rounded,
                    iconBg: color.Palette.gradientFirst.withOpacity(0.08),
                    iconColor: color.Palette.gradientFirst,
                    badge: 'Nouveau',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleSelectionScreen(
                            customerNumber: widget.customerNumber,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildEnhancedServiceCard(
                    title: 'Réclamations',
                    icon: Icons.report_problem_rounded,
                    iconBg: const Color(0xFFFCEBEB),
                    iconColor: const Color(0xFFA32D2D),
                    onTap: () {
                      // TODO
                    },
                  ),
                  _buildEnhancedServiceCard(
                    title: 'News & Offres',
                    icon: Icons.campaign_rounded,
                    iconBg: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF854F0B),
                    onTap: () {
                      // TODO
                    },
                  ),
                  _buildEnhancedServiceCard(
                    title: 'Mes véhicules',
                    icon: Icons.directions_car_rounded,
                    iconBg: const Color(0xFFE1F5EE),
                    iconColor: const Color(0xFF0F6E56),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VehicleSelectionScreen(
                            customerNumber: widget.customerNumber,
                          ),
                        ),
                      );
                    },
                  ),
                ]),
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────────
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 110),
              sliver: SliverToBoxAdapter(child: SizedBox()),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte prochain RDV ────────────────────────────────────────────────────

  Widget _buildNextRdvCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.Palette.gradientFirst.withOpacity(0.92),
            color.Palette.gradientSecond,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft:     Radius.circular(20),
          bottomLeft:  Radius.circular(20),
          bottomRight: Radius.circular(20),
          topRight:    Radius.circular(60),
        ),
        boxShadow: [
          BoxShadow(
            color: color.Palette.gradientFirst.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, height: 6,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF9FE1CB),
                    shape: BoxShape.circle,
                  ),
                ),
                Text(
                  'Prochain rendez-vous',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Agence Lac 1',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Service Réparation',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.75),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              // Puce date
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.9)),
                    const SizedBox(width: 6),
                    Text(
                      '19/04/2026 · 10h00',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Bouton voir
              GestureDetector(
                onTap: () => widget.onNavigate?.call(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: color.Palette.gradientFirst.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Voir',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color.Palette.gradientFirst,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 13,
                          color: color.Palette.gradientFirst),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Banner SAV ────────────────────────────────────────────────────────────

  Widget _buildSavBanner() {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image en fond à droite
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  "images/SAV.png",
                  width: 160,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Dégradé blanc pour lisibilité
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.97),
                    Colors.white.withOpacity(0.6),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.45, 0.65, 1],
                ),
              ),
            ),
          ),
          // Texte
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 0, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Certifié',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF27500A),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Service client\nd'exception",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color.Palette.homePageTitle,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Techniciens certifiés à votre service',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: color.Palette.homePageSubtitle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}