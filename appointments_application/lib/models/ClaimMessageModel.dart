class ClaimMessageModel {
  final int entryNo;
  final String claimNo;
  final String message;
  final String senderType;
  final String senderName;
  final DateTime? messageDateTime;

  ClaimMessageModel({
    required this.entryNo,
    required this.claimNo,
    required this.message,
    required this.senderType,
    required this.senderName,
    this.messageDateTime,
  });

  factory ClaimMessageModel.fromJson(Map<String, dynamic> json) {
    return ClaimMessageModel(
      entryNo: json['entryNo'] ?? 0,
      claimNo: json['claimNo']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      senderType: json['senderType']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      messageDateTime: json['messageDateTime'] != null
          ? DateTime.tryParse(json['messageDateTime'].toString())
          : null,
    );
  }
}