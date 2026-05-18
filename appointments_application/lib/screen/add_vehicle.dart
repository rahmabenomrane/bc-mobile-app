// lib/screen/AddVehicleScreen.dart
import 'package:flutter/material.dart';
import '../config/Palette.dart';

class AddVehicleScreen extends StatefulWidget {
  final String customerNumber; // ← transmis par VehicleSelectionScreen

  const AddVehicleScreen({super.key, required this.customerNumber});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _immatController = TextEditingController();
  final _modeleController = TextEditingController();
  final _anneeController  = TextEditingController();
  String? _selectedMotorisation;

  @override
  void dispose() {
    _immatController.dispose();
    _modeleController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  void _save() {
    // Validation simple
    if (_immatController.text.trim().isEmpty ||
        _modeleController.text.trim().isEmpty ||
        _anneeController.text.trim().isEmpty ||
        _selectedMotorisation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    final vehicleData = {
      'customerNumber'  : widget.customerNumber,  // ← inclus automatiquement
      'immatriculation' : _immatController.text.trim(),
      'modele'          : _modeleController.text.trim(),
      'annee'           : _anneeController.text.trim(),
      'motorisation'    : _selectedMotorisation,
    };

    // TODO : appeler votre service ici, ex:
    // await VehicleService().addVehicle(vehicleData);

    debugPrint("Données envoyées : $vehicleData");

    // Retourner true pour que VehicleSelectionScreen recharge la liste
    Navigator.pop(context, true);
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

            // ── HEADER ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              height: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios,
                        color: Palette.secondPageIconColor, size: 20),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Nouveau véhicule",
                    style: TextStyle(color: Palette.secondPageTitleColor),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Ajouter une voiture",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Palette.secondPageTitleColor,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Badge client (lecture seule, pour confirmation visuelle)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Client n° ${widget.customerNumber}",
                      style: TextStyle(
                        color: Palette.secondPageTitleColor.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY ──────────────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topRight: Radius.circular(70)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.65,
                    ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    
                        // INPUTS
                        _input("Immatriculation", _immatController),
                        _input("Modèle",           _modeleController),
                        _input("Année",            _anneeController,
                            inputType: TextInputType.number),
                    
                        const SizedBox(height: 15),
                    
                        // MOTORISATION
                        Text(
                          "Motorisation",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Palette.circuitsColor,
                          ),
                        ),
                    
                        const SizedBox(height: 10),
                    
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _chip("Essence"),
                            _chip("Diesel"),
                            _chip("Électrique"),
                            _chip("Hybride"),
                          ],
                        ),

                        const SizedBox(height: 30),
                    
                        // BOUTON ENREGISTRER
                        GestureDetector(
                          onTap: _save,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  Palette.gradientFirst,
                                  Palette.gradientSecond,
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Enregistrer le véhicule",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    
                      ],
                    ),
                  ),
                ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _input(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    final isSelected = _selectedMotorisation == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedMotorisation = text),
      child: Chip(
        label: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: isSelected
            ? Palette.gradientSecond
            : Colors.grey.shade100,
        side: isSelected
            ? BorderSide(color: Palette.gradientSecond)
            : BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}