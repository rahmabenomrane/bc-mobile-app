import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/vehicle_model.dart';

class VehicleService {

  final storage = const FlutterSecureStorage();

  final String baseUrl = "http://10.0.2.2:5032";

  Future<List<Vehicle>> getMyVehicles() async {

    final token = await storage.read(key: "token");

    final response = await http.get(
      Uri.parse("$baseUrl/api/vehicles"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final List vehiclesJson = data["data"];

      return vehiclesJson
          .map((json) => Vehicle.fromJson(json))
          .toList();

    } else {

      throw Exception("Erreur chargement véhicules");
    }
  }
}