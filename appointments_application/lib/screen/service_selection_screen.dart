// lib/screen/service_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/Palette.dart';
import '../models/vehicle_model.dart';
import 'appointment_slot_screen.dart';
import 'step_indicator.dart';
import '../models/service_model.dart';
import '../Service/service_service.dart';
class ServiceSelectionScreen extends StatefulWidget {
  final Vehicle selectedVehicle;
  final Map<String, dynamic> selectedAgency;

  const ServiceSelectionScreen({
    super.key,
    required this.selectedVehicle,
    required this.selectedAgency,
  });

  @override
  State<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends State<ServiceSelectionScreen> {
  int? _selectedServiceIndex;

  final ServiceService _serviceService = ServiceService();

  List<ServiceModel> _services = [];

  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadServices();
  }
  Future<void> _loadServices() async {
    try {
      final agencyCode = widget.selectedAgency['code'];
      print("AGENCY = ${widget.selectedAgency}");
      final services =
      await _serviceService.getServicesByAgency(
        agencyCode,
      );

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.homePageBackground,
      body: Column(
        children: [
          _buildHeader(context),
          _buildVehicleAgencyBanner(),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : _error.isNotEmpty
                ? Center(child: Text(_error))
                : _buildServiceList(),
          ),
          if (_selectedServiceIndex != null) _buildBottomCTA(),
        ],
      ),
    );
  }

  // ─── Header avec gradient + step indicator ────────────────────────────────
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
              // Back + title row
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisir un service',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Palette.secondPageTitleColor,
                        ),
                      ),

                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Step indicator
              StepIndicator(currentStep: 3, totalSteps: 5),
              const SizedBox(height: 6),

              // Labels étapes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StepLabel('Véhicule',     done: true,  active: false),
                  _StepLabel('Agence',       done: true,  active: false),
                  _StepLabel('Service',      done: false, active: true),
                  _StepLabel('Créneau',      done: false, active: false),
                  _StepLabel('Confirmation', done: false, active: false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bandeau véhicule + agence ────────────────────────────────────────────
  Widget _buildVehicleAgencyBanner() {
    return Container(
      color: Palette.gradientSecond.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Véhicule
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Palette.gradientFirst.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: Palette.gradientFirst,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedVehicle.fullName,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Palette.homePageTitle,
                  ),
                ),
                Text(
                  widget.selectedAgency['name'],
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Palette.homePageSubtitle,
                  ),
                ),
              ],
            ),
          ),
          // Badge agence
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Palette.gradientFirst.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Étape 3',
              style: TextStyle(
                fontSize: 10,
                color: Palette.gradientFirst,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Liste des services ───────────────────────────────────────────────────
  Widget _buildServiceList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _services.length,
      itemBuilder: (context, index) => _buildServiceCard(index),
    );
  }

  Widget _buildServiceCard(int index) {
    final service = _services[index];
    final isSelected = _selectedServiceIndex == index;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedServiceIndex = isSelected ? null : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Palette.gradientFirst.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Palette.gradientSecond
                : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Palette.gradientFirst.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ]
              : [
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [Palette.gradientFirst, Palette.gradientSecond],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : LinearGradient(
                    colors: [
                      Palette.gradientFirst.withOpacity(0.08),
                      Palette.gradientSecond.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  service.icon,
                  color: isSelected ? Colors.white : Palette.gradientSecond,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          service.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Palette.gradientFirst
                                : Palette.homePageTitle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Palette.gradientSecond.withOpacity(0.12)
                                : Palette.homePageBackground,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Text(
                    //   service.description,
                    //   style: GoogleFonts.dmSans(
                    //     fontSize: 12,
                    //     color: Palette.homePageSubtitle,
                    //   ),
                    // ),

                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Chevron / check
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Container(
                  key: const ValueKey('check'),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Palette.gradientFirst, Palette.gradientSecond],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16),
                )
                    : Icon(
                  key: const ValueKey('chevron'),
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade300,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── CTA bottom ───────────────────────────────────────────────────────────
  Widget _buildBottomCTA() {
    final service = _services[_selectedServiceIndex!];

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100),
          ),
          boxShadow: [
            BoxShadow(
              color: Palette.gradientFirst.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Palette.gradientFirst,
                        Palette.gradientSecond,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    service.icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Palette.homePageTitle,
                        ),
                      ),

                      // Text(
                      //   service.duration,
                      //   style: TextStyle(
                      //     fontSize: 11,
                      //     color: Palette.homePageSubtitle,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Palette.gradientFirst,
                      Palette.gradientSecond,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AppointmentSlotScreen(
                          selectedVehicle: widget.selectedVehicle,
                          selectedAgency: widget.selectedAgency,
                          selectedService: service,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    'Continuer vers le créneau',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Micro-widgets ─────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final bool selected;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.selected,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: highlight && selected ? Palette.green : iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            color: highlight
                ? Palette.green
                : Palette.homePageSubtitle,
          ),
        ),
      ],
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