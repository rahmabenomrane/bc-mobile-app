
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Service/vehicle_service.dart';
import '../models/vehicle_model.dart';
import '../config/Palette.dart';
import 'AppFooter.dart';
import 'step_indicator.dart';
import 'Locations_page.dart';
import 'add_vehicle.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final String customerNumber;
  final bool appointmentMode;
  final Function(int)? onNavigate;

  const VehicleSelectionScreen({
    Key? key,
    required this.customerNumber,
    this.appointmentMode = true,
    this.onNavigate,
  }) : super(key: key);

  @override
  State<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends State<VehicleSelectionScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final vehicles = await _vehicleService.getMyVehicles();
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      if (e.toString().contains("401") ||
          e.toString().contains("Session expirée")) {
        _showSessionExpiredDialog();
      } else {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Session expirée"),
        content: const Text(
            "Votre session a expiré. Veuillez vous reconnecter."),
        actions: [
          TextButton(
            onPressed: () {
              const FlutterSecureStorage().delete(key: "token");
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
            child: const Text("Reconnecter"),
          ),
        ],
      ),
    );
  }

  Future<void> _goToAddVehicle() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicleScreen(
          customerNumber: widget.customerNumber,
        ),
      ),
    );
    if (result == true) _loadVehicles();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.homePageBackground,

      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),

      bottomNavigationBar: !widget.appointmentMode
          ? SizedBox(
        height: 90,
        child: AppFooter(
          currentIndex: 0,
          onTap: (i) {
            widget.onNavigate?.call(i);
            Navigator.pop(context);
          },
        ),
      )
          : null,
    );
  }
  // ─── Header + step indicator ────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Palette.gradientFirst, Palette.gradientSecond],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + titre + bouton Ajouter
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Palette.secondPageIconColor,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.appointmentMode
                              ? 'Choisir un véhicule'
                              : 'Mes véhicules',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Palette.secondPageTitleColor,
                          ),
                        ),

                      ],
                    ),
                  ),
                  // Bouton Ajouter
                  GestureDetector(
                    onTap: _goToAddVehicle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              color: Palette.secondPageTitleColor, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            'Ajouter',
                            style: GoogleFonts.dmSans(
                              color: Palette.secondPageTitleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Step indicator
              if (widget.appointmentMode) ...[
              const SizedBox(height: 20),

              StepIndicator(currentStep: 1, totalSteps: 5),

              const SizedBox(height: 6),

              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              _StepLabel('Véhicule', active: true, done: false),
              _StepLabel('Agence', active: false, done: false),
              _StepLabel('Service', active: false, done: false),
              _StepLabel('Créneau', active: false, done: false),
    _StepLabel('Confirmation', active: false, done: false),
    ],
    ),
    ],]
          ),
        ),
      ),
    );
  }

  // ─── Body : loading / erreur / vide / liste ────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Palette.gradientFirst),
            ),
            const SizedBox(height: 20),
            Text(
              'Chargement de vos véhicules…',
              style: GoogleFonts.dmSans(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: GoogleFonts.dmSans(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _gradientButton('Réessayer', _loadVehicles),
            ],
          ),
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Palette.gradientFirst.withOpacity(0.1),
                    Palette.gradientSecond.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 40,
                color: Palette.gradientSecond.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucun véhicule trouvé',
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Palette.homePageTitle,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ajoutez votre premier véhicule',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: Palette.homePageSubtitle,
              ),
            ),
            const SizedBox(height: 32),
            _gradientButton('Ajouter un véhicule', _goToAddVehicle),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Bandeau compteur
        _buildCountBanner(),
        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: _vehicles.length,
            itemBuilder: (context, index) =>
                _buildVehicleCard(_vehicles[index]),
          ),
        ),
      ],
    );
  }

  // ─── Bandeau compteur ──────────────────────────────────────────────────────

  Widget _buildCountBanner() {
    return Container(
      color: Palette.gradientSecond.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Palette.gradientFirst.withOpacity(0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: Palette.gradientFirst,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_vehicles.length} véhicule${_vehicles.length > 1 ? 's' : ''} enregistré${_vehicles.length > 1 ? 's' : ''}',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Palette.homePageTitle,
            ),
          ),
          const Spacer(),
          widget.appointmentMode?
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Palette.gradientFirst.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Étape 1',
              style: TextStyle(
                fontSize: 10,
                color: Palette.gradientFirst,
                fontWeight: FontWeight.w600,
              ),
            ),
          ):const Spacer(),
        ],
      ),
    );
  }

  // ─── Carte véhicule

  Widget _buildVehicleCard(Vehicle vehicle) {
    return GestureDetector(
      onTap: () {
        if (widget.appointmentMode) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MapScreen(
                selectedVehicle: vehicle,
              ),
            ),
          );
        }
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Palette.gradientFirst.withOpacity(0.08),
                      Palette.gradientSecond.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: Palette.gradientSecond,
                  size: 26,
                ),
              ),

              const SizedBox(width: 14),

              // Infos véhicule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.fullName,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Palette.homePageTitle,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vehicle.motorisation,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: Palette.homePageSubtitle,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Chip numéro
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Palette.homePageBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 11,
                            color: Palette.homePageSubtitle,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            vehicle.registrationNumber.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Palette.homePagePlanColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bouton dégradé réutilisable ───────────────────────────────────────────

  Widget _gradientButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Palette.gradientFirst, Palette.gradientSecond],
          ),
          boxShadow: [
            BoxShadow(
              color: Palette.gradientFirst.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}


class _StepLabel extends StatelessWidget {
  final String text;
  final bool active;
  final bool done;

  const _StepLabel(this.text, {required this.active, required this.done});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        color: active
            ? Colors.white
            : done
            ? Colors.white54
            : Colors.white38,
      ),
    );
  }
}