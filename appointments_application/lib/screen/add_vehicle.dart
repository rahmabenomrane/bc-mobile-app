// lib/screen/AddVehicleScreen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Service/vehicle_service.dart';
import '../config/Palette.dart';

class AddVehicleScreen extends StatefulWidget {
  final String customerNumber;
  const AddVehicleScreen({super.key, required this.customerNumber});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _immatController = TextEditingController();
  final _modeleController = TextEditingController();
  final _mileageController = TextEditingController();
  String? _selectedMotorisation;
  bool _isLoading = false;
  List makes = [];
  List models = [];

  String? selectedMake;
  String? selectedModel;
  @override
  void initState() {
    super.initState();
    loadMakes();
  }
  @override
  void dispose() {
    _immatController.dispose();
    _modeleController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  final String baseUrl = "http://127.0.0.1:5032";
  Future<void> loadMakes() async {
    final res = await http.get(Uri.parse("$baseUrl/api/vehicles/makes"));

    final data = jsonDecode(res.body);

    setState(() {
      makes = data['data'] ?? [];
    });

    print("MAKES => $makes");
  }
  Future<void> loadModels(String makeCode) async {
    final res = await http.get(
      Uri.parse("$baseUrl/api/vehicles/models/$makeCode"),
    );

    final data = jsonDecode(res.body);

    setState(() {
      models = data['data'] ?? [];
    });
    print("MODELS => $models");
  }
  Future<void> _save() async {
    print ("saveeeeeee");
    print(_immatController.text, );
    print(selectedModel);
        print(_selectedMotorisation);
    if (_immatController.text.trim().isEmpty ||
        selectedModel== null  ||
        _selectedMotorisation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await VehicleService().createVehicle(

        modelCode: selectedModel!,
        makeCode: selectedMake!,
        motorisation: _selectedMotorisation!,
        registrationNumber: _immatController.text.trim(),
        mileage: int.tryParse(_mileageController.text.trim()) ?? 0,

      );

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de la création du véhicule."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                        _input("Kilométrage", _mileageController, inputType: TextInputType.number),
                        DropdownButton<String>(
                          value: selectedMake,
                          hint: const Text("Marque"),
                          items: makes.map<DropdownMenuItem<String>>((m) {
                            return DropdownMenuItem<String>(
                              value: m['code'].toString(),
                              child: Text(m['name'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMake = value;
                              selectedModel = null;
                              models.clear();
                            });

                            loadModels(value!);
                          },
                        ),
                        DropdownButton<String>(
                          value: selectedModel,
                          hint: const Text("Modèle"),
                          items: models.map<DropdownMenuItem<String>>((m) {
                            return DropdownMenuItem<String>(
                              value: m['code'].toString(),
                              child: Text(m['name'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedModel = value;
                            });
                          },
                        ),

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

                        GestureDetector(
                          onTap: _isLoading ? null : _save,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [Palette.gradientFirst, Palette.gradientSecond],
                              ),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                "Enregistrer le véhicule",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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