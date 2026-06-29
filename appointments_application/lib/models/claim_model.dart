class ClaimModel {
  final int claimNumber;
  final String creationDate;
  final String customerNo;
  final String vehicleNo;
  final String description;
  final String registrationNumber;
  final int status;
  final int priority;

  ClaimModel({
    required this.claimNumber,
    required this.creationDate,
    required this.customerNo,
    required this.vehicleNo,
    required this.description,
    required this.status,
    required this.priority,
    this.registrationNumber = '',
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      claimNumber:  (json['claimNumber']  as num?)?.toInt() ?? 0,
      creationDate: json['creationDate']  as String? ?? '',
      customerNo:   json['customerNo']   as String? ?? '',
      vehicleNo:    json['vehicleNo']    as String? ?? '',
      description:  json['description']  as String? ?? '',
      registrationNumber:  json['registrationNumber'] as String? ?? '',
      status:       (json['status']       as num?)?.toInt() ?? 0,
      priority:     (json['priority']     as num?)?.toInt() ?? 0,
    );
  }

  String get statusLabel {
    switch (status) {
      case 0: return 'Envoyé';
      case 1: return 'Résolu';
      case 2: return 'Clôturé';
      case 3: return 'Annulé';
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
  String get vehicleDisplay =>
      registrationNumber.isNotEmpty ? registrationNumber : vehicleNo;

}
