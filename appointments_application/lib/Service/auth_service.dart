// lib/Service/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl =
      "http://10.0.2.2:5032/api/auth";
  static final _storage = FlutterSecureStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // 🔐 LOGIN — retourne le Map complet et persiste le customerNumber
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
      String phone,
      String password,
      ) async {

    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "phone": phone,
        "password": password,
      }),
    );

    print("URL : $url");
    print("LOGIN STATUS : ${response.statusCode}");
    print("LOGIN BODY   : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur login");
    }
  }
  // ─────────────────────────────────────────────────────────────────────────
  // 📝 REGISTER
  // ─────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String phone, String email, String password,
      {String address = "", String civility = "Monsieur"}) async {
    final url = Uri.parse("$baseUrl/customers");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name":     name,
        "phone":    phone,
        "email":    email,
        "password": password,
        "address":  address,
        "civility": civility,
      }),
    );

    print("REGISTER STATUS : ${response.statusCode}");
    print("REGISTER BODY   : ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception("Erreur register: ${response.body}");
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔑 Getters pour les données persistées (utile au redémarrage de l'app)
  // ─────────────────────────────────────────────────────────────────────────
  static Future<String> getSavedCustomerNumber() async {
    return await _storage.read(key: "customerNumber") ?? "";
  }

  static Future<String> getSavedToken() async {
    return await _storage.read(key: "token") ?? "";
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔍 Extraction du customerNumber depuis le JSON de réponse
  //
  // Business Central retourne souvent les champs en PascalCase.
  // Lance l'app, lis "LOGIN BODY" dans la console Flutter,
  // et vérifie que le bon champ est en tête de liste ci-dessous.
  // ─────────────────────────────────────────────────────────────────────────
  static String _extractCustomerNumber(Map<String, dynamic> data) {
    final candidates = [
      "CustomerNo",       // BC standard (le plus probable)
      "customerNo",
      "CustomerNumber",
      "customerNumber",
      "customer_number",
      "CustomerCode",
      "customerCode",
      "No",
      "no",
      "numClient",
      "sub",
    ];

    for (final key in candidates) {
      if (data.containsKey(key) && data[key] != null && data[key].toString().isNotEmpty) {
        return data[key].toString();
      }
    }

    // Aucun champ trouvé → affiche toutes les clés dispo pour debug
    print("⚠️  customerNumber introuvable. Clés disponibles : ${data.keys.toList()}");
    return "";
  }
}