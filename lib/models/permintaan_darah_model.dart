class PermintaanDarahModel {
  final String patientName;
  final String patientAge;
  final String phoneNumber;
  final String bloodType;
  final String bloodBagsNeeded;
  final String description;
  final String partner_id;
  final String expiry_date;
  final String uniqueCode;
  final int bloodBagsFulfilled;
  final String status;
  

  PermintaanDarahModel({
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
    this.status = "Pending",
  });

  Map<String, dynamic> toJson() {
    return {
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
      
    };
  }

  factory PermintaanDarahModel.fromJson(Map<String, dynamic> json) {
    return PermintaanDarahModel(
      patientName: json['patientName'] ?? '',
      patientAge: json['patientAge'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bloodType: json['bloodType'] ?? '',
      bloodBagsNeeded: json['bloodBagsNeeded'] ?? '',
      description: json['description'] ?? '',
      partner_id: json['partner_id'] ?? '',
      expiry_date: json['expiry_date'] ?? '',
      uniqueCode: json['uniqueCode'] ?? '',
      bloodBagsFulfilled: json['bloodBagsFulfilled'] ?? 0,
      status: json['status'] ?? 'Pending',
    );
  }

  PermintaanDarahModel copyWith({
    String? patientName,
    String? patientAge,
    String? phoneNumber,
    String? bloodType,
    String? bloodBagsNeeded,
    String? description,
    String? partner_id,
    String? expiry_date,
    String? uniqueCode,
    int? bloodBagsFulfilled,
    String? status,
  }) {
    return PermintaanDarahModel(
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
    );
  }

  // Konstanta untuk status
  static const String STATUS_PENDING = "pending";
  static const String STATUS_WAITING = "waiting";
  static const String STATUS_ACCEPTED = "accepted";
  static const String STATUS_COMPLETED = "completed";
  static const String STATUS_CANCELLED = "cancelled";
}