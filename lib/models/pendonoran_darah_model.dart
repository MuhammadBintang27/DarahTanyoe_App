class PendonoranDarahModel {
  final String id;
  final String status;
  final String healthNotes;
  final String fullName;
  final String phoneNumber;
  final String uniqueCode;
  final BloodRequest bloodRequest;
  final String? createdAt;

  PendonoranDarahModel({
    required this.id,
    required this.status,
    required this.healthNotes,
    required this.fullName,
    required this.phoneNumber,
    required this.uniqueCode,
    required this.bloodRequest,
    this.createdAt,
  });

  factory PendonoranDarahModel.fromJson(Map<String, dynamic> json) {
    return PendonoranDarahModel(
      id: json['id'],
      status: json['status'] ?? '',
      healthNotes: json['health_notes'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      uniqueCode: json['unique_code'] ?? '',
      bloodRequest: BloodRequest.fromJson(json['blood_requests']),
      createdAt: json['created_at'],
    );
  }
}

class BloodRequest {
  final String reason;
  final String status;
  final String bloodType;
  final int quantity;
  final int bloodBagsFulfilled;
  final String expiryDate;
  final Partner partner;
  final String? createdAt;

  BloodRequest({
    required this.reason,
    required this.status,
    required this.bloodType,
    required this.quantity,
    required this.bloodBagsFulfilled,
    required this.expiryDate,
    required this.partner,
    this.createdAt,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      bloodType: json['blood_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      bloodBagsFulfilled: json['blood_bags_fulfilled'] ?? 0,
      expiryDate: json['expiry_date'] ?? '',
      partner: Partner.fromJson(json['partners']),
      createdAt: json['created_at'],
    );
  }
}

class Partner {
  final String name;
  final double latitude;
  final double longitude;

  Partner({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    return Partner(
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
