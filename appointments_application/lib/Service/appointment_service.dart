import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Appontment_model.dart';

class AppointmentService {
  static const String baseUrl = "http://10.0.2.2:5032/api";

  static Future<bool> createAppointment({
    required String agencyCode,
    required String serviceCode,
    required DateTime date,
    required int startTime,
    required int endTime,
    required String pontId,
    required String vehicleNumber,
  }) async {

    final url = Uri.parse("$baseUrl/Appointment/create");

    final body = {
      "agencyCode": agencyCode,
      "serviceCode": serviceCode,
      "date": date.toIso8601String(),
      "StartTime": startTime,
      "EndTime" : startTime + 1,
      "pontId": pontId,
      "status": "Confirmed",
      "vehicleNumber": vehicleNumber,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print(response.body);

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(response.body);
  }
  static Future<List<AppointmentModel>> getAppointments(
      String agencyCode,
      String serviceCode,
      ) async {
    final url = Uri.parse(
        "$baseUrl/appointment/slots?agencyCode=$agencyCode&serviceCode=$serviceCode");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => AppointmentModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Erreur GET RDV");
    }
  }
  Future<List<dynamic>> getCustomerAppointments(
      String customerNumber) async {

    final response = await http.get(
      Uri.parse(
          "$baseUrl/customer/$customerNumber"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
        "Erreur récupération rendez-vous");
  }
}