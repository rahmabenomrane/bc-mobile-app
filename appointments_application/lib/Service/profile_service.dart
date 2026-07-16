import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ProfileService {
  static const String baseUrl = 'http://127.0.0.1:5032';

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await AuthService.getSavedToken();

    final response = await http.patch(
      Uri.parse("$baseUrl/api/profile/password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        "newPassword": newPassword,
        "confirmPassword": newPassword,
      }),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");

    Map<String, dynamic> data = {};
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print("JSON decode error: $e");
      }
    }

    return {
      "success": response.statusCode == 200,
      "error": data["error"] ?? "",
    };
  }
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await AuthService.getSavedToken();

    final response = await http.get(
      Uri.parse("$baseUrl/api/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["customer"];
    } else {
      throw Exception("Erreur get profile");
    }
  }

  static Future<bool> updateProfile(Map<String, dynamic> body) async {
    final token = await AuthService.getSavedToken();

    final response = await http.patch(
      Uri.parse("$baseUrl/api/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    print("TOKEN = $token");
    print("URL = $baseUrl");
    print("BODY = $body");
    return response.statusCode == 200;
  }
}