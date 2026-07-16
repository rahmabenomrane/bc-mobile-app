// models/claim_model.dart
class ClaimModel {
  final String claimNumber;
  final String vehicleNo;
  final String registrationNumber;
  final String description;
  final int priority;
  final int status;
  final String creationDate;
  final String? appointmentRef;
  final String serviceName;
  final String agencyName;

  ClaimModel({
    required this.claimNumber,
    required this.vehicleNo,
    required this.registrationNumber,
    required this.description,
    required this.priority,
    required this.status,
    required this.creationDate,
    this.appointmentRef,
    required this.serviceName,
    required this.agencyName,
  });

  String get vehicleDisplay =>
      '$vehicleNo${registrationNumber.isNotEmpty ? ' ($registrationNumber)' : ''}';

  String get statusLabel {
    switch (status) {
      case 0: return 'En attente';
      case 1: return 'En cours';
      case 2: return 'Résolue';
      case 3: return 'Rejetée';
      default: return 'Inconnu';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 0: return 'Faible';
      case 1: return 'Moyen';
      case 2: return 'Élevé';
      default: return 'Inconnu';
    }
  }

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic value) => value?.toString() ?? '';
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Récupérer le serviceName (même s'il est vide)
    String serviceName = safeString(json['serviceName']);
    if (serviceName.isEmpty) {
      serviceName = safeString(json['serviceDescription']);
    }

    // Récupérer l'agencyName (même s'il est vide)
    String agencyName = safeString(json['agencyName']);
    if (agencyName.isEmpty) {
      agencyName = safeString(json['AgencyName']);
    }

    // Récupérer l'appointmentRef
    String appointmentRef = safeString(json['appointmentRef']);
    if (appointmentRef.isEmpty) {
      appointmentRef = safeString(json['appointmentRef']);
    }

    return ClaimModel(
      claimNumber: safeString(json['claimNumber']),
      vehicleNo: safeString(json['vehicleNo']),
      registrationNumber: safeString(json['registrationNumber']),
      description: safeString(json['description']),
      priority: safeInt(json['priority']),
      status: safeInt(json['status']),
      creationDate: safeString(json['creationDate']),
      appointmentRef: appointmentRef.isNotEmpty ? appointmentRef : null,
      serviceName: serviceName.isNotEmpty ? serviceName : 'Service non spécifié',
      agencyName: agencyName.isNotEmpty ? agencyName : 'Agence non spécifiée',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'claimNumber': claimNumber,
      'vehicleNo': vehicleNo,
      'registrationNumber': registrationNumber,
      'description': description,
      'priority': priority,
      'status': status,
      'creationDate': creationDate,
      'appointmentRef': appointmentRef,
      'serviceName': serviceName,
      'agencyName': agencyName,
    };
  }

  ClaimModel copyWith({
    String? claimNumber,
    String? vehicleNo,
    String? registrationNumber,
    String? description,
    int? priority,
    int? status,
    String? creationDate,
    String? appointmentRef,
    String? serviceName,
    String? agencyName,
  }) {
    return ClaimModel(
      claimNumber: claimNumber ?? this.claimNumber,
      vehicleNo: vehicleNo ?? this.vehicleNo,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      appointmentRef: appointmentRef ?? this.appointmentRef,
      serviceName: serviceName ?? this.serviceName,
      agencyName: agencyName ?? this.agencyName,
    );
  }
}