import 'package:flutter/material.dart';
class ServiceModel {
  final String code;
  final String name;
  final String? description;
  final String? type;
  final String? duration;
  final IconData icon;

  ServiceModel({
    required this.code,
    required this.name,
    this.description,
    this.type,
    this.duration,
    required this.icon,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      icon: _getIcon(json['type']?.toString() ?? ''),
      duration: json['duration']?.toString() ?? '',

    );
  }
  static IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'Diagnostic électronique':
        return Icons.opacity_rounded;

      case 'Entretien périodique':
        return Icons.developer_board_rounded;

      case 'pneumatiques':
        return Icons.tire_repair_rounded;

      case 'climatisation':
        return Icons.ac_unit_rounded;

      default:
        return Icons.miscellaneous_services_rounded;
    }
  }
 

}