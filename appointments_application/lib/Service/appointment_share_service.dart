import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/appointment_share_response.dart';

class AppointmentShareService {
  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  static const String _baseUrl =
      'http://127.0.0.1:5032';

  static Future<AppointmentShareResponse> createShareLink({
    required String appointmentNo,
    required String customerEmail,
    required String vehicleRegistration,
    required String vehicleName,
    required String agencyName,
    required String agencyAddress,
    required String agencyPhone,
    required String serviceName,
    required DateTime appointmentDate,
    required String appointmentTime,
  }) async {
    final token = await _storage.read(
      key: 'token',
    );

    if (token == null || token.isEmpty) {
      throw Exception(
        'Utilisateur non authentifié.',
      );
    }

    final uri = Uri.parse(
      '$_baseUrl/api/appointment-share/create',
    );

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'appointmentNo': appointmentNo,
        'customerEmail': customerEmail,
        'vehicleRegistration': vehicleRegistration,
        'vehicleName': vehicleName,
        'agencyName': agencyName,
        'agencyAddress': agencyAddress,
        'agencyPhone': agencyPhone,
        'serviceName': serviceName,
        'appointmentDate': appointmentDate.toIso8601String(),
        'appointmentTime': appointmentTime,
        'status': 'Confirmé',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de créer le lien du rendez-vous. '
            'Code: ${response.statusCode} '
            '${response.body}',
      );
    }

    final json =
    jsonDecode(response.body)
    as Map<String, dynamic>;

    return AppointmentShareResponse.fromJson(
      json,
    );
  }
}