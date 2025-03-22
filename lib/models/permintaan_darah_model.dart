class PermintaanDarahModel {
  final String patientName;
  final String patientAge;
  final String phoneNumber;
  final String bloodType;
  final String rhesus;
  final String bloodBagsNeeded;
  final String description;
  final String donationLocation;
  final String deadlineFormatted;
  final String uniqueCode;
  final int bloodBagsFulfilled;
  final String status;
  final String createdAt;
  final String updatedAt;

  PermintaanDarahModel({
    required this.patientName,
    required this.patientAge,
    required this.phoneNumber,
    required this.bloodType,
    required this.rhesus,
    required this.bloodBagsNeeded,
    required this.description,
    required this.donationLocation,
    required this.deadlineFormatted,
    required this.uniqueCode,
    this.bloodBagsFulfilled = 0,
    this.status = "Pending",
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'patientAge': patientAge,
      'phoneNumber': phoneNumber,
      'bloodType': bloodType,
      'rhesus': rhesus,
      'bloodBagsNeeded': bloodBagsNeeded,
      'description': description,
      'donationLocation': donationLocation,
      'deadlineFormatted': deadlineFormatted,
      'uniqueCode': uniqueCode,
      'bloodBagsFulfilled': bloodBagsFulfilled,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PermintaanDarahModel.fromJson(Map<String, dynamic> json) {
    return PermintaanDarahModel(
      patientName: json['patientName'] ?? '',
      patientAge: json['patientAge'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bloodType: json['bloodType'] ?? '',
      rhesus: json['rhesus'] ?? '',
      bloodBagsNeeded: json['bloodBagsNeeded'] ?? '',
      description: json['description'] ?? '',
      donationLocation: json['donationLocation'] ?? '',
      deadlineFormatted: json['deadlineFormatted'] ?? '',
      uniqueCode: json['uniqueCode'] ?? '',
      bloodBagsFulfilled: json['bloodBagsFulfilled'] ?? 0,
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toIso8601String(),
    );
  }

  PermintaanDarahModel copyWith({
    String? patientName,
    String? patientAge,
    String? phoneNumber,
    String? bloodType,
    String? rhesus,
    String? bloodBagsNeeded,
    String? description,
    String? donationLocation,
    String? deadlineFormatted,
    String? uniqueCode,
    int? bloodBagsFulfilled,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return PermintaanDarahModel(
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodType: bloodType ?? this.bloodType,
      rhesus: rhesus ?? this.rhesus,
      bloodBagsNeeded: bloodBagsNeeded ?? this.bloodBagsNeeded,
      description: description ?? this.description,
      donationLocation: donationLocation ?? this.donationLocation,
      deadlineFormatted: deadlineFormatted ?? this.deadlineFormatted,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      bloodBagsFulfilled: bloodBagsFulfilled ?? this.bloodBagsFulfilled,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  // Konstanta untuk status
  static const String STATUS_PENDING = "Pending";
  static const String STATUS_WAITING = "Waiting";
  static const String STATUS_ACCEPTED = "Accepted";
  static const String STATUS_COMPLETED = "Completed";
  static const String STATUS_CANCELLED = "Cancelled";
}