// lib/Service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:5032";
  static final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Login
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/Auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "password": password,
        }),
      );

      print("=== LOGIN RESPONSE ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Récupérer le token
        String? token = data['token'] ?? data['Token'] ?? data['accessToken'];
        String? customerNumber = data['customerNumber'] ?? data['CustomerNumber'];

        print("Token extrait: ${token != null ? 'OUI' : 'NON'}");
        print("CustomerNumber extrait: ${customerNumber ?? 'NON'}");

        // STOCKER LE TOKEN
        if (token != null) {
          await storage.write(key: "token", value: token);
          print("✅ Token stocké avec succès");

          // Vérifier immédiatement
          final savedToken = await storage.read(key: "token");
          print("Vérification token stocké: ${savedToken != null ? 'OK' : 'FAILED'}");
        } else {
          print("❌ Aucun token trouvé dans la réponse !");
          print("   Clés disponibles: ${data.keys}");
        }

        // STOCKER LE CUSTOMER NUMBER
        if (customerNumber != null) {
          await storage.write(key: "customerNumber", value: customerNumber);
          print("✅ CustomerNumber stocké: $customerNumber");
        }

        return data;
      } else {
        throw Exception("Échec de connexion: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Erreur login: $e");
      throw Exception("Erreur de connexion: $e");
    }
  }

  // Register
  static Future<void> register(
      String fullName,
      String phone,
      String email,
      String password, {
        String? address,
        String? civility,
      }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/Auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "password": password,
          "email": email,
          "firstName": fullName.split(' ').first,
          "lastName": fullName.split(' ').last,
          "address": address ?? "",
          "civility": civility ?? "Monsieur",
        }),
      );

      print("=== REGISTER RESPONSE ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception("Échec de l'inscription: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Erreur register: $e");
      throw Exception("Erreur d'inscription: $e");
    }
  }

  // Get saved token
  static Future<String?> getSavedToken() async {
    return await storage.read(key: "token");
  }

  // Get saved customer number
  static Future<String?> getSavedCustomerNumber() async {
    return await storage.read(key: "customerNumber");
  }

  // Logout
  static Future<void> logout() async {
    await storage.delete(key: "token");
    await storage.delete(key: "customerNumber");
    print("✅ Utilisateur déconnecté, tokens supprimés");
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getSavedToken();
    return token != null && token.isNotEmpty;
  }
}