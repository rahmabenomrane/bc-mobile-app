class Agency {
  final String name;
  final String code;
  final String address;
  final String phoneNo;
  final String email;
  final int capacity;
  final String officeHours;
  double? latitude;
  double? longitude;

  Agency({
    required this.name,
    required this.code,
    required this.address,
    required this.phoneNo,
    required this.email,
    required this.capacity,
    required this.officeHours,
    this.latitude,
    this.longitude,
  });

  factory Agency.fromJson(Map<String, dynamic> j) {
    print('🔍 === FROMJSON ===');
    print('📦 Données reçues: $j');


    double? lat;
    double? lng;
    // Latitude
    try {
      final latValue = j['latitude'];
      print('📍 Latitude brute: $latValue (type: ${latValue.runtimeType})');

      if (latValue != null) {
        if (latValue is String) {
          String cleaned = latValue.replaceAll(',', '.').trim();
          print('   Nettoyée: $cleaned');
          lat = double.tryParse(cleaned);
        } else if (latValue is num) {
          lat = latValue.toDouble();
        } else if (latValue is int) {
          lat = latValue.toDouble();
        }
        print('   Latitude parsée: $lat');
      } else {
        print('⚠️ Latitude est null');
      }
    } catch (e) {
      print('❌ Erreur latitude: $e');
      lat = null;
    }

    // Longitude
    try {
      final lngValue = j['longitude'];
      print('📍 Longitude brute: $lngValue (type: ${lngValue.runtimeType})');

      if (lngValue != null) {
        if (lngValue is String) {
          String cleaned = lngValue.replaceAll(',', '.').trim();
          print('   Nettoyée: $cleaned');
          lng = double.tryParse(cleaned);
        } else if (lngValue is num) {
          lng = lngValue.toDouble();
        } else if (lngValue is int) {
          lng = lngValue.toDouble();
        }
        print('   Longitude parsée: $lng');
      } else {
        print('⚠️ Longitude est null');
      }
    } catch (e) {
      print('❌ Erreur longitude: $e');
      lng = null;
    }


    if (lat == null) {
      print('⚠️ Latitude null, utilisation valeur par défaut');
      lat = 36.8147629863945;
    }
    if (lng == null) {
      print('⚠️ Longitude null, utilisation valeur par défaut');
      lng = 10.1533690813572;
    }

    print('✅ COORDONNÉES FINALES: $lat, $lng');

    return Agency(
      name: j['name']?.toString() ?? '',
      code: j['code']?.toString() ?? '',
      address: j['address']?.toString() ?? '',
      phoneNo: j['phoneNo']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      capacity: int.tryParse(j['capacity'].toString()) ?? 0,
      officeHours: j['officeHours']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'code': code,
    'address': address,
    'phoneNo': phoneNo,
    'email': email,
    'capacity': capacity,
    'officeHours': officeHours,
    'latitude': latitude,
    'longitude': longitude,
  };
}