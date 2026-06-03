class AppointmentModel {
  final String agencyCode;
  final String serviceCode;
  final String date;
  final String? pontId;
  final String? status;
  final String StartTime;
  final String EndTime;


  AppointmentModel({
    required this.agencyCode,
    required this.serviceCode,
    required this.date,
    this.pontId,
    this.status,
    required this.StartTime,
    required this.EndTime,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      agencyCode: json['agencyCode'] ?? '',
      serviceCode: json['serviceCode'] ?? '',
      date: json['date'] ?? '',
      pontId: json['pontId'],
      status: json['status'],
      StartTime: json['StartTime'] ?? '',
      EndTime: json['EndTime'] ?? '',
    );
  }
}