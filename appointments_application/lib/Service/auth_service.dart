// lib/Service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:5032";
  static final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Login
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/Auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phone, "password": password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("=== BODY COMPLET ===");
        print(response.body);
        print("Clés disponibles: ${data.keys.toList()}");
        // ✅ Supprimer uniquement les clés de session
        await storage.delete(key: "token");
        await storage.delete(key: "customerNumber");
        await storage.delete(key: "customerEmail");

        final token = data['token'] ?? data['Token'] ?? data['accessToken'];
        final customerNumber = data['customerNumber'] ?? data['CustomerNumber'];
        final email = data['email'] ?? data['Email'] ?? '';

        print("Token reçu: $token");
        print("CustomerNumber reçu: $customerNumber");

        if (token != null) {
          await storage.write(key: "token", value: token);
          final check = await storage.read(key: "token");
          print("Token vérifié après write: $check");
        }

        if (customerNumber != null) {
          await storage.write(key: "customerNumber", value: customerNumber);
        }

        if (email.isNotEmpty) {
          await storage.write(key: "customerEmail", value: email);
        }

        return data;
      } else {
        throw Exception("Échec: ${response.statusCode} — ${response.body}");
      }
    } catch (e) {
      print("❌ Erreur login: $e");
      rethrow;
    }
  }
  static Future<void> fetchAndStoreEmail(String customerNumber) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/Auth/customer/$customerNumber"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final email = data['email'] ?? data['Email'] ?? '';
        if (email.isNotEmpty) {
          await storage.write(key: "customerEmail", value: email);
          print("✅ Email stocké: $email");
        }
      }
    } catch (e) {
      print("❌ fetchAndStoreEmail: $e");
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
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/Auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          "phone": phone,
          "password": password,
          "email": email,
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
    await storage.deleteAll();
    print(" Session complètement effacée");
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getSavedToken();
    return token != null && token.isNotEmpty;
  }
}