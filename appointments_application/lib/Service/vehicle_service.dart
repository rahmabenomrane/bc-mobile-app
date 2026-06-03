import 'dart:convert';
import 'dart:math' as Math;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final storage = const FlutterSecureStorage();
  final String baseUrl = "http://10.0.2.2:5032";

  Future<List<Vehicle>> getMyVehicles() async {
    print("=== DÉBUT getMyVehicles ===");

    final token = await storage.read(key: "token");

    if (token == null) {
      throw Exception("Non authentifié. Veuillez vous reconnecter.");
    }

    print("=== GET VEHICULES ===");
    print("URL: $baseUrl/api/Vehicles");
    print("Authorization: Bearer ${token.substring(0, Math.min(30, token.length))}...");

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/Vehicles"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data["success"] == true) {
          final List vehiclesJson = data["data"] ?? [];
          print("✅ ${vehiclesJson.length} véhicule(s) trouvé(s)");

          return vehiclesJson
              .map((json) => Vehicle.fromJson(json))
              .toList();
        } else {
          throw Exception(data["message"] ?? "Erreur inconnue");
        }
      } else if (response.statusCode == 401) {
        print("❌ ERREUR 401: Token invalide ou expiré");
        print("   Token utilisé: $token");
        throw Exception("Session expirée. Veuillez vous reconnecter.");
      } else {
        throw Exception("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception: $e");
      rethrow;
    }
  }
}