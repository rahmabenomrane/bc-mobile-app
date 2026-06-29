import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/service_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ServiceService {


  Future<List<ServiceModel>> getServicesByAgency(String agencyCode) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final String baseUrl = 'http://127.0.0.1:5032';
    print('[SERVICES] agencyCode = $agencyCode');
    print('[SERVICES] token = $token');

    Uri.parse('$baseUrl/api/services/agency/$agencyCode');


    final response = await http.get(
      Uri.parse('$baseUrl/api/services/agency/$agencyCode'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );


    print('[SERVICES] statusCode = ${response.statusCode}');
    print('[SERVICES] body = ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => ServiceModel.fromJson(e))
          .toList();
    }

    throw Exception(
      'Erreur chargement services : ${response.statusCode}',
    );
  }
}