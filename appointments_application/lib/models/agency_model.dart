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

  factory Agency.fromJson(Map<String, dynamic> j) => Agency(
    name: j['name']?.toString() ?? '',
    code: j['code']?.toString() ?? '',
    address: j['address']?.toString() ?? '',
    phoneNo: j['phoneNo']?.toString() ?? '',
    email: j['email']?.toString() ?? '',
    capacity: int.tryParse(j['capacity'].toString()) ?? 0,
    officeHours: j['officeHours']?.toString() ?? '',

    latitude: j['latitude'] == null
        ?  36.819
        : double.tryParse(
      j['latitude'].toString().replaceAll(',', '.'),
    ),

    longitude: j['longitude'] == null
        ? 10.1658
        : double.tryParse(
      j['longitude'].toString().replaceAll(',', '.'),
    ),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'code': code,
    'address': address,
    'phoneNo': phoneNo,
    'email': email,
    'capacity': capacity,
    'officeHours': officeHours,
    'latitude':latitude,
    'longitude':longitude,
  };
}