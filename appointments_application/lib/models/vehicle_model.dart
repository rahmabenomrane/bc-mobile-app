class Vehicle {
  final String id;
  final String numVehicle;
  final String numCustomer;
  final String makeCode;
  final String modelCode;
  final String motorisation;
  final String? registrationNumber;
  final String mileage;

  Vehicle({
    required this.id,
    required this.numVehicle,
    required this.numCustomer,
    required this.makeCode,
    required this.modelCode,
    required this.motorisation,
    this.registrationNumber,
    required this.mileage
  });


  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      numVehicle: json['numVehicle']?.toString() ?? json['NumVehicle']?.toString() ?? '',
      numCustomer: json['numCustomer']?.toString() ?? json['NumCustomer']?.toString() ?? '',
      makeCode: json['makeCode']?.toString() ?? '',
      modelCode: json['modelCode']?.toString() ?? '',
      motorisation: json['motorisation']?.toString() ?? '',
      registrationNumber: json['registrationNumber']?.toString() ?? json['Registration_number']?.toString(),
      mileage: (json['Mileage'] ?? json['mileage'] ?? 0).toString(),
    );
  }
  factory Vehicle.empty() {
    return Vehicle(
      id: '',
      numVehicle: '',
      numCustomer: '',
      makeCode: '',
      modelCode: '',
      motorisation: '',
      mileage: '',
    );
  }

  // Nom complet
  String get fullName => "$makeCode $modelCode";

  // Motorisation en texte
  String get motorisationText {
    switch (motorisation) {
      case 0: return 'Essence';
      case 1: return 'Diesel';
      case 2: return 'Hybride';
      case 3: return 'Électrique';
      default: return 'Inconnu';
    }
  }

}