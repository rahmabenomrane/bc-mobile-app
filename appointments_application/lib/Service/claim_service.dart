import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/claim_model.dart';

class ClaimService {
  static const String _baseUrl = 'http://127.0.0.1:5032/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    print("[CLAIM SERVICE] TOKEN = ${token != null ? token.substring(0, token.length.clamp(0, 30)) + '...' : 'null'}");
    if (token == null) throw Exception("Session expirée. Veuillez vous reconnecter.");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── GET /api/claims ──────────────────────────────────────────
  static Future<List<ClaimModel>> fetchClaims() async {
    final Map<String, String> headers;
    try {
      headers = await _headers();
    } catch (e) {
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/claims'),
      headers: headers,
    );

    print('[CLAIM SERVICE] GET /claims → ${response.statusCode}');
    print('[CLAIM SERVICE] Body → ${response.body}');

    if (response.statusCode == 401) {
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Gère les deux formats : liste directe [] ou objet { "data": [] }
      List raw;
      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map && decoded['data'] is List) {
        raw = decoded['data'] as List;
      } else if (decoded is Map && decoded['value'] is List) {
        raw = decoded['value'] as List;
      } else {
        raw = [];
      }

      return raw
          .map((e) => ClaimModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erreur chargement réclamations: ${response.statusCode}');
  }

  // ── POST /api/claims ─────────────────────────────────────────
  static Future<ClaimModel> createClaim({
    required String vehicleNo,
    required String description,
    required int priority,
    String appointmentRef = '',
  }) async {
    final Map<String, String> headers;
    try {
      headers = await _headers();
    } catch (e) {
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    }

    final body = jsonEncode({
      'vehicleNo':      vehicleNo,
      'description':    description,
      'priority':       priority,
      'appointmentRef': appointmentRef,
    });

    print('[CLAIM SERVICE] POST /claims → $body');

    final response = await http.post(
      Uri.parse('$_baseUrl/claims'),
      headers: headers,
      body: body,
    );

    print('[CLAIM SERVICE] Status → ${response.statusCode}');
    print('[CLAIM SERVICE] Body   → ${response.body}');

    if (response.statusCode == 401) {
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['data'] is Map) {
        return ClaimModel.fromJson(decoded['data'] as Map<String, dynamic>);
      }
      return ClaimModel.fromJson(decoded as Map<String, dynamic>);
    }


    try {
      final err = jsonDecode(response.body);
      throw Exception(err['message'] ?? 'Erreur ${response.statusCode}');
    } catch (_) {
      throw Exception('Erreur ${response.statusCode}');
    }
  }
}