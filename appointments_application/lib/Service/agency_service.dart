// lib/Service/agency_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/agency_model.dart';


class AgencyService {
  static const String _baseUrl = 'http://127.0.0.1:5032';
  final _storage = const FlutterSecureStorage();

  get content => null;

  Future<List<Agency>> getAgencies() async {
    final token = await _storage.read(key: 'token');

    print('[AGENCIES] token = $token');

    final response = await http.get(
      Uri.parse('$_baseUrl/api/agency'),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));

    print('[AGENCIES] statusCode = ${response.statusCode}');
    print('[AGENCIES] body = ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((j) => Agency.fromJson(j as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Session expirée');
    } else {
      throw Exception('Erreur chargement agences: ${response.statusCode}');
    }
  }
}