class AppointmentModel {
  final String agencyCode;
  final String serviceCode;
  final String date;
  final String? pontId;
  final String? status;
  final String StartTime;
  final String EndTime;
  final String AgencyName;
  final String? appointmentNo;
  final String? numVehicle;

  AppointmentModel({
    required this.agencyCode,
    required this.serviceCode,
    required this.date,
    this.pontId,
    this.status,
    required this.StartTime,
    required this.EndTime,
    required this.AgencyName,
    this.appointmentNo,
    this.numVehicle,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      agencyCode: json['agencyCode'] ?? '',
      serviceCode: json['serviceCode'] ?? '',
      date: json['date'] ?? '',
      pontId: json['pontId'],
      status: json['status'],
      StartTime: json['startTime'] ?? '',
      EndTime: json['endTime'] ?? '',
      AgencyName: json['agencyName'] ?? '',
      appointmentNo: json['appointmentNo'],
      numVehicle: json['numVehicle'],
    );
  }
}