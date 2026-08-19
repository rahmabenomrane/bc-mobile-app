import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/Appontment_model.dart';

class AppointmentService {
  static const String baseUrl = "http://127.0.0.1:5032/api";

  // ================= CREATE =================
  static Future<String?> createAppointment({
    required String agencyCode,
    required String serviceCode,
    required DateTime date,
    required int startTime,
    required int endTime,
    required String pontId,
    required String vehicleNumber,
    required String customerNumber,
    required String serviceDescription,
  }) async {

    final url = Uri.parse("$baseUrl/Appointment/create");

    final body = {
      "agencyCode": agencyCode,
      "serviceCode": serviceCode,
      "date": date.toIso8601String(),
      "StartTime": startTime,
      "EndTime": endTime,
      "pontId": pontId,
      "status": "Pending",
      "vehicleNumber": vehicleNumber,
      "customerNumber": customerNumber,
      "serviceDescription": serviceDescription,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["data"]["appointmentNo"];
    }

    throw Exception(response.body);
  }
  static Future<List<DateTime>> getNonworkingDays(
      String agencyCode, {
        DateTime? from,
        DateTime? to,
      }) async {
    final start = from ?? DateTime.now();
    final end = to ?? start.add(const Duration(days: 90));

    final uri = Uri.parse(
      "$baseUrl/Appointment/nonworking-days"
          "?agencyCode=$agencyCode"
          "&from=${_fmt(start)}"
          "&to=${_fmt(end)}",
    );

    print("GET NONWORKING DAYS => $uri");

    final resp = await http.get(uri);

    print("STATUS NONWORKING = ${resp.statusCode}");
    print("BODY NONWORKING = ${resp.body}");

    if (resp.statusCode != 200) {
      return [];
    }

    final List<dynamic> data = jsonDecode(resp.body);

    return data
        .map((d) => DateTime.parse(d.toString()))
        .toList();
  }


  static String _fmt(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  static Future<List<AppointmentModel>> getAppointments(
      String agencyCode,
      String serviceCode,
      ) async {
    final url = Uri.parse(
        "$baseUrl/appointment/slots?agencyCode=$agencyCode&serviceCode=$serviceCode");

    final response = await http.get(url);

    print("GET RDV STATUS = ${response.statusCode}");
    print("BODY = ${response.body}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      print("resppp du get rdv");
      print(response);
      return data.map((e) => AppointmentModel.fromJson(e)).toList();

    }


    return [];
  }
  // ================= CUSTOMER APPOINTMENTS =================
  Future<List<dynamic>> getCustomerAppointments(String customerNumber) async {
    final response = await http.get(
      Uri.parse("$baseUrl/Appointment/customer/$customerNumber"),
      headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      },
    );

    if (response.statusCode == 200) {
      print("resppp du get customer rdv");
      print("${response.body}");
      return jsonDecode(response.body);
    }

    throw Exception("Erreur récupération rendez-vous");
  }


  static Future<bool> rescheduleAppointment({
    required String appointmentNo,
    required DateTime date,
    required int startTime,
    required int endTime,
  }) async {

    final url = Uri.parse("$baseUrl/Appointment/reschedule");

    final body = {
      "appointmentNo": appointmentNo,
      "date": date.toIso8601String(),
      "startTime": startTime,
      "endTime": endTime,
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

    throw Exception("Erreur reschedule RDV");
  }

  static Future<void> cancelAppointment(String appointmentNo) async {
    final url = Uri.parse("$baseUrl/Appointment/cancel/$appointmentNo");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}