import 'package:flutter/material.dart';
import '../Service/profile_service.dart';
import '../Service/auth_service.dart';
import '../config/Palette.dart';
import 'ChangePasswordScreen .dart';
import 'home_page.dart';
import 'main_screen.dart';

class ProfileScreen extends StatefulWidget {

  final VoidCallback onGoHome;

  const ProfileScreen({
    super.key,
    required this.onGoHome,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  Map<String, dynamic>? profile;

  final fullNameCtrl = TextEditingController();
  final phoneCtrl    = TextEditingController();
  final emailCtrl    = TextEditingController();
  final addressCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    try {
      final data = await ProfileService.getProfile();
      setState(() {
        profile = data;
        // Concatène prénom + nom en un seul champ
        final first = data["firstName"] ?? "";
        final last  = data["lastName"]  ?? "";
        fullNameCtrl.text = "$first $last".trim();
        phoneCtrl.text   = data["phone"]   ?? "";
        emailCtrl.text   = data["email"]   ?? "";
        addressCtrl.text = data["address"] ?? "";
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print(e);
    }
  }

  Future<void> saveProfile() async {
    final success = await ProfileService.updateProfile({
      "lastName":  fullNameCtrl.text.trim(),
      "phone":     phoneCtrl.text.trim(),
      "email":     emailCtrl.text.trim(),
      "address":   addressCtrl.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil mis à jour avec succès"),
          backgroundColor: Colors.green,
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      widget.onGoHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur lors de la mise à jour"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

            // ── HEADER ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              height: 240,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios,
                        color: Palette.secondPageIconColor, size: 20),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Mon compte",
                    style: TextStyle(color: Palette.secondPageTitleColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Mon profil",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Palette.secondPageTitleColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Client n° ${profile?["customerNumber"] ?? ""}",
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

            // ── BODY ────────────────────────────────────────────────
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.only(topRight: Radius.circular(70)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _input("Nom complet", fullNameCtrl),
                      _input("Téléphone", phoneCtrl,
                          inputType: TextInputType.phone),
                      _input("Email", emailCtrl,
                          inputType: TextInputType.emailAddress),
                      _input("Adresse", addressCtrl),

                      const SizedBox(height: 20),

                      // Bouton enregistrer
                      GestureDetector(
                        onTap: saveProfile,
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
                              "Enregistrer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

// Bouton changer mot de passe
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordScreen(),
                          ),
                        ),
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Palette.gradientFirst),
                          ),
                          child: Center(
                            child: Text(
                              "Changer le mot de passe",
                              style: TextStyle(
                                color: Palette.gradientFirst,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bouton déconnexion
                      GestureDetector(
                        onTap: logout,
                        child: const Center(
                          child: Text(
                            "Déconnexion",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}