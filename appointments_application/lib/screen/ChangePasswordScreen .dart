import 'package:flutter/material.dart';
import '../Service/profile_service.dart';
import '../config/Palette.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentCtrl = TextEditingController();
  final newCtrl     = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool _isLoading       = false;
  bool _showCurrent     = false;
  bool _showNew         = false;
  bool _showConfirm     = false;

  @override
  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = currentCtrl.text.trim();
    final newPass = newCtrl.text.trim();
    final confirm = confirmCtrl.text.trim();

    // Validation côté Flutter
    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showError("Veuillez remplir tous les champs");
      return;
    }
    if (newPass.length < 6) {
      _showError("Le nouveau mot de passe doit contenir au moins 6 caractères");
      return;
    }
    if (newPass != confirm) {
      _showError("Les mots de passe ne correspondent pas");
      return;
    }
    if (current == newPass) {
      _showError("Le nouveau mot de passe doit être différent de l'ancien");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ProfileService.changePassword(
        currentPassword: current,
        newPassword: newPass,
      );

      if (!mounted) return;

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe modifié avec succès"),
            backgroundColor: Colors.green,
          ),
        );
        // ✅ Retour à la page précédente après succès
        Navigator.pop(context);
      } else {
        _showError(result["error"] ?? "Erreur inconnue");
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
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

            // ── HEADER ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.only(top: 70, left: 30, right: 30),
              height: 220,
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
                    "Sécurité",
                    style: TextStyle(color: Palette.secondPageTitleColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Changer le mot de passe",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Palette.secondPageTitleColor,
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
                      const SizedBox(height: 10),

                      _passwordField(
                        "Mot de passe actuel",
                        currentCtrl,
                        _showCurrent,
                            () => setState(() => _showCurrent = !_showCurrent),
                      ),
                      _passwordField(
                        "Nouveau mot de passe",
                        newCtrl,
                        _showNew,
                            () => setState(() => _showNew = !_showNew),
                      ),
                      _passwordField(
                        "Confirmer le nouveau mot de passe",
                        confirmCtrl,
                        _showConfirm,
                            () => setState(() => _showConfirm = !_showConfirm),
                      ),

                      const SizedBox(height: 10),

                      // Règles de sécurité
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Règles du mot de passe :",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text("• Au moins 6 caractères",
                                style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                            Text("• Différent de l'ancien mot de passe",
                                style: TextStyle(fontSize: 12, color: Colors.blueAccent)),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      GestureDetector(
                        onTap: _isLoading ? null : _save,
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
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text(
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

  Widget _passwordField(
      String label,
      TextEditingController ctrl,
      bool visible,
      VoidCallback toggle,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      ),
    );
  }
}