class PermintaanDarahModel {
  final String? id;
  final String patientName;
  final String patientAge;
  final String phoneNumber;
  final String bloodType;
  final int bloodBagsNeeded;
  final String description;
  final String partner_id;
  final String expiry_date;
  final String uniqueCode;
  final int bloodBagsFulfilled;
  final String status;
  final String partner_name;
  final double partner_latitude;
  final double partner_longitude;
  final double? distance;
  final String? createdAt;

  PermintaanDarahModel({
    this.id = "id",
    required this.patientName,
    required this.patientAge,
    required this.phoneNumber,
    required this.bloodType,
    required this.bloodBagsNeeded,
    required this.description,
    required this.partner_id,
    required this.expiry_date,
    required this.uniqueCode,
    this.bloodBagsFulfilled = 0,
    this.status = "pending",
    this.partner_name = "",
    this.partner_latitude = 0.0,
    this.partner_longitude = 0.0,
    this.distance,
    this.createdAt, // ✅ Tambahan baru
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'patientAge': patientAge,
      'phoneNumber': phoneNumber,
      'bloodType': bloodType,
      'bloodBagsNeeded': bloodBagsNeeded,
      'description': description,
      'partner_id': partner_id,
      'expiry_date': expiry_date,
      'uniqueCode': uniqueCode,
      'bloodBagsFulfilled': bloodBagsFulfilled,
      'status': status,
      'partner_name': partner_name,
      'partner_latitude': partner_latitude,
      'partner_longitude': partner_longitude,
      'distance': distance,
      'created_at': createdAt, // ✅ Tambahan baru
    };
  }

  factory PermintaanDarahModel.fromJson(Map<String, dynamic> json) {
    return PermintaanDarahModel(
      id: json['id'] ?? '',
      patientName: json['patient_name'] ?? '',
      patientAge: json['patient_age']?.toString() ?? '',
      phoneNumber: json['phone_number'] ?? '',
      bloodType: json['blood_type'] ?? '',
      bloodBagsNeeded: json['quantity'] ?? 0,
      description: json['reason'] ?? '',
      partner_id: json['partner_id'] ?? '',
      expiry_date: json['expiry_date'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      bloodBagsFulfilled: json['blood_bags_fulfilled'] ?? 0,
      status: json['status'] ?? 'Pending',
      partner_name: json['partners']?['name'] ?? '',
      partner_latitude: json['partners']?['latitude'] ?? 0.0,
      partner_longitude: json['partners']?['longitude'] ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble(),
      createdAt: json['created_at'], // ✅ Tambahan baru
    );
  }

  PermintaanDarahModel copyWith({
    String? id,
    String? patientName,
    String? patientAge,
    String? phoneNumber,
    String? bloodType,
    int? bloodBagsNeeded,
    String? description,
    String? partner_id,
    String? expiry_date,
    String? uniqueCode,
    int? bloodBagsFulfilled,
    String? status,
    String? partner_name,
    double? partner_latitude,
    double? partner_longitude,
    double? distance,
    String? createdAt, // ✅ Tambahan baru
  }) {
    return PermintaanDarahModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodType: bloodType ?? this.bloodType,
      bloodBagsNeeded: bloodBagsNeeded ?? this.bloodBagsNeeded,
      description: description ?? this.description,
      partner_id: partner_id ?? this.partner_id,
      expiry_date: expiry_date ?? this.expiry_date,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      bloodBagsFulfilled: bloodBagsFulfilled ?? this.bloodBagsFulfilled,
      status: status ?? this.status,
      partner_name: partner_name ?? this.partner_name,
      partner_latitude: partner_latitude ?? this.partner_latitude,
      partner_longitude: partner_longitude ?? this.partner_longitude,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Status constants
  static const String STATUS_PENDING = "pending";
  static const String STATUS_CONFIRMED = "confirmed";
  static const String STATUS_READY = "ready";
  static const String STATUS_COMPLETED = "completed";
  static const String STATUS_CANCELLED = "cancelled";
}
