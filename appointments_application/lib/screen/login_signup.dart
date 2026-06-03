// lib/screen/LoginSignupScreen.dart
import 'package:appointments_application/config/Palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'main_screen.dart';
import 'dart:async';
import '../Service/auth_service.dart';

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isMale           = true;
  bool isSignupScreen   = false;
  bool isRememberMe     = false;
  bool _isLoading       = false;

  final TextEditingController phoneController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController    = TextEditingController();
  final TextEditingController nameController     = TextEditingController();
  final TextEditingController addressController  = TextEditingController();

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
              width: MediaQuery.of(context).size.width,
              height: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Icon(Icons.info_outline,
                          size: 20, color: Palette.secondPageIconColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Bienvenue chez STA",
                      style: TextStyle(
                          fontSize: 14, color: Palette.secondPageTitleColor)),
                  const SizedBox(height: 4),
                  Text(
                    isSignupScreen ? "Créer un compte" : "Se connecter",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Palette.secondPageTitleColor),
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
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          _buildTab("Se connecter", !isSignupScreen,
                                  () => setState(() => isSignupScreen = false)),
                          const SizedBox(width: 28),
                          _buildTab("S'inscrire", isSignupScreen,
                                  () => setState(() => isSignupScreen = true)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Formulaire
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            _buildField(
                              icon: MaterialCommunityIcons.phone,
                              hint: "Numéro de téléphone",
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              icon: MaterialCommunityIcons.lock,
                              hint: "Mot de passe",
                              obscure: true,
                              controller: passwordController,
                            ),
                            const SizedBox(height: 12),

                            // Champs inscription uniquement
                            if (isSignupScreen) ...[
                              _buildField(
                                icon: MaterialCommunityIcons.account,
                                hint: "Nom complet",
                                controller: nameController,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                icon: MaterialCommunityIcons.email,
                                hint: "Email",
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                              ),
                              const SizedBox(height: 12),
                              _buildField(
                                icon: MaterialCommunityIcons.map_marker,
                                hint: "Adresse",
                                controller: addressController,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildGenderOption("Homme",
                                      MaterialCommunityIcons.face_man, true),
                                  const SizedBox(width: 24),
                                  _buildGenderOption("Femme",
                                      MaterialCommunityIcons.face_woman, false),
                                ],
                              ),
                            ],

                            // Remember me (connexion uniquement)
                            if (!isSignupScreen) ...[
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: isRememberMe,
                                        onChanged: (v) =>
                                            setState(() => isRememberMe = v!),
                                        activeColor: Palette.activeColor,
                                      ),
                                      const Text("Se souvenir de moi",
                                          style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: Text("Mot de passe oublié?",
                                        style: TextStyle(
                                            color: Palette.activeColor,
                                            fontSize: 13)),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Bouton principal
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Palette.gradientFirst.withOpacity(0.85),
                                      Palette.gradientSecond.withOpacity(0.9),
                                    ],
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => isSignupScreen
                                      ? _register()
                                      : _login(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2),
                                  )
                                      : Text(
                                    isSignupScreen
                                        ? "S'inscrire"
                                        : "Se connecter",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LOGIN ────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final data = await AuthService.login(
        phoneController.text.trim(),
        passwordController.text,
      );

      // Vérifier que le token est bien stocké
      final storedToken = await AuthService.getSavedToken();
      print("=== APRÈS LOGIN ===");
      print("Token stocké: ${storedToken != null ? 'OUI' : 'NON'}");
      if (storedToken != null) {
        print("Token (début): ${storedToken.substring(0, 50)}...");
      }

      if (storedToken == null) {
        throw Exception("Le token n'a pas été stocké correctement");
      }

      final customerNumber = await AuthService.getSavedCustomerNumber();
      print("CustomerNumber stocké: $customerNumber");

      if (customerNumber == null) {
        throw Exception("Le customerNumber n'a pas été stocké correctement");
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            token: storedToken,
            customerNumber: customerNumber,
          ),
        ),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // ── REGISTER ─────────────────────────────────────────────────────────────
  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.register(
        nameController.text.trim(),
        phoneController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        address:  addressController.text.trim(),
        civility: isMale ? "Monsieur" : "Madame",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Compte créé avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => isSignupScreen = false);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ── Widgets helpers ───────────────────────────────────────────────────────

  Widget _buildTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: active ? Palette.circuitsColor : Palette.textColor1)),
          if (active)
            Container(
                margin: const EdgeInsets.only(top: 3),
                height: 2,
                width: 55,
                color: Colors.orange),
        ],
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required String hint,
    bool obscure = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Palette.iconColor),
        hintText: hint,
        border:
        OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon, bool isMaleOption) {
    final selected = isMaleOption ? isMale : !isMale;
    return GestureDetector(
      onTap: () => setState(() => isMale = isMaleOption),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? LinearGradient(
                colors: [
                  Palette.gradientFirst.withOpacity(0.8),
                  Palette.gradientSecond.withOpacity(0.9),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              )
                  : null,
              color: selected ? null : Colors.transparent,
              border: Border.all(
                  width: 1,
                  color: selected
                      ? Colors.transparent
                      : Palette.textColor1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon,
                color: selected ? Colors.white : Palette.iconColor,
                size: 18),
          ),
          Text(label, style: TextStyle(color: Palette.textColor1)),
        ],
      ),
    );
  }
}