// lib/screen/VehicleSelectionScreen.dart
import 'package:appointments_application/screen/step_indicator.dart';
import 'package:flutter/material.dart';
import '../Service/vehicle_service.dart';
import '../models/vehicle_model.dart';
import '../config/Palette.dart';
import 'add_vehicle.dart';

class VehicleSelectionScreen extends StatefulWidget {
  final String customerNumber; // ← reçu par le parent

  const VehicleSelectionScreen({
    Key? key,
    required this.customerNumber,
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
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
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
    // Si un véhicule a été ajouté, on recharge la liste
    if (result == true) _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Palette.gradientFirst.withOpacity(0.9),
              Palette.gradientSecond,
            ],
            begin: const FractionalOffset(0.0, 0.4),
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          children: [
            // ── HEADER (même style qu'AddVehicleScreen) ──────────────────
            Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Palette.secondPageIconColor,
                      size: 20,
                    ),
                  ),

                  const SizedBox(height: 15),



                  StepIndicator(
                    currentStep: 1,
                    totalSteps: 5,
                  ),
                  const SizedBox(height: 15),



                  Text(
                    "Choisir une voiture",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Palette.secondPageTitleColor,
                    ),
                  ),

                  // Compteur + bouton Ajouter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isLoading && _errorMessage.isEmpty)
                        Text(
                          "${_vehicles.length} véhicule${_vehicles.length > 1 ? 's' : ''}",
                          style: TextStyle(
                            color: Palette.secondPageTitleColor.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                      const Spacer(),
                      // Bouton Ajouter dans le header
                      GestureDetector(
                        onTap: _goToAddVehicle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  color: Palette.secondPageTitleColor,
                                  size: 18),
                              const SizedBox(width: 6),
                              Text(
                                "Ajouter",
                                style: TextStyle(
                                  color: Palette.secondPageTitleColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── BODY  ──────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topRight: Radius.circular(70)),
                ),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── États de chargement / erreur / vide / liste ──────────────────────────
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Palette.gradientSecond),
            ),
            const SizedBox(height: 20),
            Text(
              "Chargement de vos véhicules...",
              style: TextStyle(color: Colors.grey.shade600),
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
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _gradientButton("Réessayer", _loadVehicles),
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
            Icon(Icons.directions_car,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "Aucun véhicule trouvé",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez votre premier véhicule",
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 32),
            _gradientButton("Ajouter un véhicule", _goToAddVehicle),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(25, 28, 25, 28),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) => _buildVehicleCard(_vehicles[index]),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, vehicle),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Palette.gradientFirst.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Icône avec dégradé
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Palette.gradientFirst.withOpacity(0.15),
                    Palette.gradientSecond.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: Palette.gradientSecond,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    vehicle.motorisationText,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  Text(
                    "N° ${vehicle.numVehicle}",
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade300, size: 26),
          ],
        ),
      ),
    );
  }

  // Bouton dégradé réutilisable
  Widget _gradientButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Palette.gradientFirst, Palette.gradientSecond],
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}