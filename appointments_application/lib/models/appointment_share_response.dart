class AppointmentShareResponse {
  final String shareUrl;
  final DateTime expiresAt;

  const AppointmentShareResponse({
    required this.shareUrl,
    required this.expiresAt,
  });

  factory AppointmentShareResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return AppointmentShareResponse(
      shareUrl:
      json['shareUrl']?.toString() ?? '',
      expiresAt: DateTime.parse(
        json['expiresAt'].toString(),
      ),
    );
  }
}