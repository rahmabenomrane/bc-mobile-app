// Service/claim_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/claim_model.dart';
import '../models/Appontment_model.dart';

class ClaimService {
  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = "http://127.0.0.1:5032";

  // Récupérer toutes les réclamations
  static Future<List<ClaimModel>> fetchClaims() async {
    try {
      final token = await _storage.read(key: "token");
      final customerNumber = await _storage.read(key: "customerNumber");
      if (token == null || customerNumber == null) throw Exception("Session expirée");

      print('=== FETCHING CLAIMS ===');

      final response = await http.get(
        Uri.parse("$_baseUrl/api/claims"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Claims Status: ${response.statusCode}');
      print('Claims Body: ${response.body}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body) as List;

        if (data.isEmpty) {
          return [];
        }

        // Récupérer TOUS les rendez-vous du client
        List<AppointmentModel> appointments = [];
        try {
          appointments = await _fetchAllAppointments(customerNumber);
          print('Found ${appointments.length} appointments');
        } catch (e) {
          print('Error fetching appointments: $e');
        }

        List<ClaimModel> claims = [];
        for (var item in data) {
          final Map<String, dynamic> claimJson = item as Map<String, dynamic>;

          String vehicleNo = claimJson['vehicleNo']?.toString() ?? '';
          String appointmentRef = claimJson['appointmentRef']?.toString() ?? '';

          String serviceName = 'Service non spécifié';
          String agencyName = 'Agence non spécifiée';

          // Méthode 1: Chercher par appointmentRef (si existe)
          if (appointmentRef.isNotEmpty) {
            print('Looking for appointment by ref: $appointmentRef');
            final matchingAppointment = appointments.firstWhere(
                  (app) => app.appointmentNo == appointmentRef,
              orElse: () => AppointmentModel(
                appointmentNo: '',
                numVehicle: '',
                date: '',
                StartTime: '',
                EndTime: '',
                status: '',
                AgencyName: '',
                serviceCode: '',
                serviceDescription: '',
              ),
            );

            if (matchingAppointment.appointmentNo.isNotEmpty) {
              serviceName = matchingAppointment.serviceDescription.isNotEmpty
                  ? matchingAppointment.serviceDescription
                  : (matchingAppointment.serviceCode.isNotEmpty
                  ? matchingAppointment.serviceCode
                  : 'Service non spécifié');
              agencyName = matchingAppointment.AgencyName.isNotEmpty
                  ? matchingAppointment.AgencyName
                  : 'Agence non spécifiée';
              print('Found appointment by ref: ${matchingAppointment.appointmentNo} - Service: $serviceName, Agency: $agencyName');
            }
          }
          // Méthode 2: Chercher par numéro de véhicule (si appointmentRef est vide)
          else if (vehicleNo.isNotEmpty) {
            print('Looking for appointment by vehicle: $vehicleNo');
            // Chercher le rendez-vous le plus récent pour ce véhicule
            final vehicleAppointments = appointments.where(
                    (app) => app.numVehicle == vehicleNo
            ).toList();

            if (vehicleAppointments.isNotEmpty) {
              // Prendre le rendez-vous le plus récent (ou le premier)
              final latestAppointment = vehicleAppointments.first;
              serviceName = latestAppointment.serviceDescription.isNotEmpty
                  ? latestAppointment.serviceDescription
                  : (latestAppointment.serviceCode.isNotEmpty
                  ? latestAppointment.serviceCode
                  : 'Service non spécifié');
              agencyName = latestAppointment.AgencyName.isNotEmpty
                  ? latestAppointment.AgencyName
                  : 'Agence non spécifiée';
              print('Found appointment by vehicle: ${latestAppointment.appointmentNo} - Service: $serviceName, Agency: $agencyName');
            } else {
              print('No appointment found for vehicle: $vehicleNo');
            }
          } else {
            print('No vehicleNo or appointmentRef for claim ${claimJson['claimNumber']}');
          }

          // Créer la réclamation avec les données
          claims.add(ClaimModel(
            claimNumber: claimJson['claimNumber']?.toString() ?? '0',
            vehicleNo: vehicleNo,
            registrationNumber: claimJson['registrationNumber']?.toString() ?? '',
            description: claimJson['description']?.toString() ?? '',
            priority: _toInt(claimJson['priority']),
            status: _toInt(claimJson['status']),
            creationDate: claimJson['creationDate']?.toString() ?? '',
            appointmentRef: appointmentRef.isNotEmpty ? appointmentRef : null,
            serviceName: serviceName,
            agencyName: agencyName,
          ));
        }

        return claims;
      } else if (response.statusCode == 401) {
        throw Exception("Session expirée");
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      print('Error in fetchClaims: $e');
      rethrow;
    }
  }

  // Récupérer tous les rendez-vous du client
  static Future<List<AppointmentModel>> _fetchAllAppointments(String customerNumber) async {
    try {
      final token = await _storage.read(key: "token");
      if (token == null) return [];

      print('=== FETCHING ALL APPOINTMENTS ===');

      final response = await http.get(
        Uri.parse("$_baseUrl/api/Appointment/customer/$customerNumber"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Appointments Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body) as List;
        print('Appointments count: ${data.length}');
        if (data.isNotEmpty) {
          print('Appointment keys: ${(data.first as Map).keys}');
        }
        return data
            .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  // Créer une réclamation
  static Future<ClaimModel> createClaim({
    required String vehicleNo,
    required String registrationNumber,
    required String description,
    required int priority,
    String? appointmentRef,
  }) async {
    try {
      final token = await _storage.read(key: "token");
      if (token == null) throw Exception("Session expirée");

      final body = jsonEncode({
        'vehicleNo': vehicleNo,
        'registrationNumber': registrationNumber,
        'description': description,
        'priority': priority,
        'appointmentRef': appointmentRef ?? '',
      });

      print('Creating claim: $body');

      final response = await http.post(
        Uri.parse("$_baseUrl/api/claims"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('Create claim status: ${response.statusCode}');
      print('Create claim response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic> json = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : decoded as Map<String, dynamic>;
        return ClaimModel.fromJson(json);
      } else if (response.statusCode == 401) {
        throw Exception("Session expirée");
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      print('Error creating claim: $e');
      rethrow;
    }
  }
}