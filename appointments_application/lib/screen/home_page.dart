import 'package:appointments_application/screen/RDVs_List.dart';
import 'package:appointments_application/screen/vehicle_selection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointments_application/config/Palette.dart' as color;

import '../Service/appointment_service.dart';
import '../Service/auth_service.dart';
import 'claims_list_screen.dart';
import 'login_signup.dart';

class HomePage extends StatefulWidget {

  final Function(int)? onNavigate;
  final VoidCallback? onOpenRdvs;
  final String customerNumber;


  const HomePage({

    super.key,

    this.onNavigate,

    this.onOpenRdvs,

    required this.customerNumber,

  });



  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> rdvs = [];
  bool loading = true;
  final AppointmentService appointmentService = AppointmentService();
  @override
  void initState() {
    super.initState();
    loadAppointments();
  }
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginSignupScreen(),
        ),
            (route) => false,
      );
    }
  }
  Future<void> loadAppointments() async {
    try {
      final data = await appointmentService.getCustomerAppointments(
          widget.customerNumber
      );
      setState(() {
        rdvs = data;
        loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }
  Map<String, dynamic>? getNextAppointment() {
    final now = DateTime.now();
    final futureRdvs = rdvs.where((rdv) {
      final endTimeStr = rdv["endTime"];
      final endTime = DateTime.tryParse(endTimeStr ?? "");
      return endTime != null && endTime.isAfter(now);
    }).toList();

    // Trier par date (le plus proche d'abord)
    futureRdvs.sort((a, b) {
      final aTime = DateTime.tryParse(a["startTime"] ?? "") ?? DateTime.now();
      final bTime = DateTime.tryParse(b["startTime"] ?? "") ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    return futureRdvs.isNotEmpty ? futureRdvs.first : null;
  }
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

                    // Bouton de notification
                    Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(right: 8),
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
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 7,
                              height: 7,
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

                    // Bouton de déconnexion (indépendant)
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: 38,
                        height: 38,
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
                        child: Icon(
                          Icons.logout,
                          size: 20,
                          color: color.Palette.homePageTitle,
                        ),
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
                            appointmentMode: true,

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
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ClaimsListScreen()),
  );
},
                  ),
                  _buildEnhancedServiceCard(
                    title: 'Mes RDVs',
                    icon: Icons.calendar_month_rounded,
                    iconBg: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF854F0B),
                    onTap: () {

                      widget.onOpenRdvs?.call();

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
                            appointmentMode: false,
                            onNavigate: widget.onNavigate,
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
              padding: EdgeInsets.only(bottom: 140),
              sliver: SliverToBoxAdapter(child: SizedBox()),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Carte prochain RDV ────────────────────────────────────────────────────

  Widget _buildNextRdvCard(BuildContext context) {
    final nextRdv = getNextAppointment();
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
            nextRdv != null ? nextRdv["agencyName"] ?? "Agence" : "Aucun rendez-vous prévu",
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            nextRdv != null ? nextRdv["serviceDescription"] ?? "Service" : "",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.75),
            ),
          ),

          const SizedBox(height: 20),
          if (nextRdv != null)
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
                      _formatDateTime(nextRdv["startTime"]),
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
                onTap: () => widget.onOpenRdvs?.call(),
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

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return "";
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day/$month/$year · ${hour}h${minute}';
    } catch (e) {
      return dateTimeStr.substring(0, 16);
    }
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
                Text(
                  "Service client\nd'exception",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color.Palette.homePageTitle,
                    height: 1.1,
                  ),
                ),

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

