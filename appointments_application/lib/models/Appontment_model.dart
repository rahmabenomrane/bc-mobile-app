class AppointmentModel {
  final String appointmentNo;
  final String numVehicle;
  final String date;
  final String StartTime;
  final String EndTime;
  final String status;
  final String AgencyName;
  final String serviceCode;
  final String serviceDescription;

  AppointmentModel({
    required this.appointmentNo,
    required this.numVehicle,
    required this.date,
    required this.StartTime,
    required this.EndTime,
    required this.status,
    required this.AgencyName,
    required this.serviceCode,
    required this.serviceDescription,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      appointmentNo: json['appointmentNo'] ?? '',
      numVehicle: json['numVehicle'] ?? '',
      date: json['date'] ?? '',
      StartTime: json['startTime'] ?? '',
      EndTime: json['endTime'] ?? '',
      status: json['status'] ?? '',
      AgencyName: json['agencyName'] ?? '',
      serviceCode: json['serviceCode'] ?? '',
      serviceDescription: json['serviceDescription'] ?? json['ServiceDescription'] ?? '',
    );
  }
}