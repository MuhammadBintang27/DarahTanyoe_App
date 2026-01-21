/// Permintaan Darah Model - Represents blood donation requests/campaigns from institutions
/// Based on blood_campaigns table from database schema
/// Maps 100% dengan GET /campaigns/:id API response
class PermintaanDarahModel {
  final String id;
  final String title;
  final String? description;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime startDate;
  final DateTime endDate;
  final int? targetDonors;
  final int currentDonors; // registrationsCount - from 'current_donors' field
  final int? targetQuantity;
  final int currentQuantity;
  final String status; // 'draft', 'active', 'completed', 'cancelled'
  final String? campaignImageUrl;
  final bool registrationRequired;
  final int? maxParticipants;
  final int currentParticipants;
  final Map<String, dynamic>? requirements;
  final Map<String, dynamic>? incentives;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Nested objects from API response
  final OrganiserData? organiser;
  final RelatedBloodRequest? relatedBloodRequest;
  final List<RegistrationData>? registrations;
  final double? distanceKm; // Jarak dari user dalam km (dari API nearby)

  PermintaanDarahModel({
    required this.id,
    required this.title,
    this.description,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.startDate,
    required this.endDate,
    this.targetDonors,
    required this.currentDonors,
    this.targetQuantity,
    required this.currentQuantity,
    required this.status,
    this.campaignImageUrl,
    required this.registrationRequired,
    this.maxParticipants,
    required this.currentParticipants,
    this.requirements,
    this.incentives,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.organiser,
    this.relatedBloodRequest,
    this.registrations,
    this.distanceKm,
  });

  /// Utility: Calculate remaining time until endDate
  Duration get timeRemaining {
    return endDate.difference(DateTime.now());
  }

  /// Utility: Check if campaign is expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Utility: Format time remaining in user-friendly format
  String get formattedTimeRemaining {
    final duration = timeRemaining;
    if (isExpired) return 'Kadaluarsa';

    if (duration.inDays > 0) {
      return '${duration.inDays} hari';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} jam';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} menit';
    } else {
      return 'Kadaluarsa';
    }
  }

  /// Utility: Check if campaign is still active
  bool get isActive {
    return status == 'active' && !isExpired;
  }

  /// Utility: Get blood type from related blood request
  String? get bloodType {
    return relatedBloodRequest?.bloodType;
  }

  /// Utility: Get patient name from related blood request
  String? get patientName {
    return relatedBloodRequest?.patientName;
  }

  /// Utility: Get urgency level from related blood request
  String? get urgencyLevel {
    return relatedBloodRequest?.urgencyLevel;
  }

  /// Parse from JSON API response - Maps 100% with GET /campaigns/:id
  factory PermintaanDarahModel.fromJson(Map<String, dynamic> json) {
    return PermintaanDarahModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.tryParse(json['start_date'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date'] ?? '') ?? DateTime.now(),
      targetDonors: json['target_donors'],
      currentDonors: json['current_donors'] ?? 0,
      targetQuantity: json['target_quantity'],
      currentQuantity: json['current_quantity'] ?? 0,
      status: json['status'] ?? 'active',
      campaignImageUrl: json['campaign_image_url'],
      registrationRequired: json['registration_required'] ?? true,
      maxParticipants: json['max_participants'],
      currentParticipants: json['current_participants'] ?? 0,
      requirements: json['requirements'] as Map<String, dynamic>?,
      incentives: json['incentives'] as Map<String, dynamic>?,
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      organiser: json['organizer'] != null
          ? OrganiserData.fromJson(json['organizer'] as Map<String, dynamic>)
          : null,
      relatedBloodRequest: json['related_blood_request'] != null
          ? RelatedBloodRequest.fromJson(
              json['related_blood_request'] as Map<String, dynamic>)
          : null,
      registrations: json['registrations'] != null
          ? List<RegistrationData>.from(
              (json['registrations'] as List).map(
                (x) => RegistrationData.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'target_donors': targetDonors,
      'current_donors': currentDonors,
      'target_quantity': targetQuantity,
      'current_quantity': currentQuantity,
      'status': status,
      'campaign_image_url': campaignImageUrl,
      'registration_required': registrationRequired,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'requirements': requirements,
      'incentives': incentives,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'organizer': organiser?.toJson(),
      'related_blood_request': relatedBloodRequest?.toJson(),
      'registrations': registrations?.map((x) => x.toJson()).toList(),
    };
  }

  /// Create a copy with modified fields
  PermintaanDarahModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? startDate,
    DateTime? endDate,
    int? targetDonors,
    int? currentDonors,
    int? targetQuantity,
    int? currentQuantity,
    String? status,
    String? campaignImageUrl,
    bool? registrationRequired,
    int? maxParticipants,
    int? currentParticipants,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? incentives,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    OrganiserData? organiser,
    RelatedBloodRequest? relatedBloodRequest,
    List<RegistrationData>? registrations,
    double? distanceKm,
  }) {
    return PermintaanDarahModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      targetDonors: targetDonors ?? this.targetDonors,
      currentDonors: currentDonors ?? this.currentDonors,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      status: status ?? this.status,
      campaignImageUrl: campaignImageUrl ?? this.campaignImageUrl,
      registrationRequired: registrationRequired ?? this.registrationRequired,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      requirements: requirements ?? this.requirements,
      incentives: incentives ?? this.incentives,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      organiser: organiser ?? this.organiser,
      relatedBloodRequest: relatedBloodRequest ?? this.relatedBloodRequest,
      registrations: registrations ?? this.registrations,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }

  @override
  String toString() {
    return 'PermintaanDarahModel(id: $id, title: $title, bloodType: $bloodType, status: $status)';
  }
}

/// Nested: Organiser/Institution data
class OrganiserData {
  final String id;
  final String institutionName;
  final String institutionType; // 'pmi', 'hospital'
  final String? phoneNumber;
  final String? address;

  OrganiserData({
    required this.id,
    required this.institutionName,
    required this.institutionType,
    this.phoneNumber,
    this.address,
  });

  factory OrganiserData.fromJson(Map<String, dynamic> json) {
    return OrganiserData(
      id: json['id'] ?? '',
      institutionName: json['institution_name'] ?? '',
      institutionType: json['institution_type'] ?? 'pmi',
      phoneNumber: json['phone_number'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institution_name': institutionName,
      'institution_type': institutionType,
      'phone_number': phoneNumber,
      'address': address,
    };
  }
}

/// Nested: Related Blood Request data
class RelatedBloodRequest {
  final String id;
  final String bloodType;
  final int quantity;
  final String patientName;
  final String urgencyLevel;
  final String status;

  RelatedBloodRequest({
    required this.id,
    required this.bloodType,
    required this.quantity,
    required this.patientName,
    required this.urgencyLevel,
    required this.status,
  });

  factory RelatedBloodRequest.fromJson(Map<String, dynamic> json) {
    return RelatedBloodRequest(
      id: json['id'] ?? '',
      bloodType: json['blood_type'] ?? '',
      quantity: json['quantity'] ?? 0,
      patientName: json['patient_name'] ?? '',
      urgencyLevel: json['urgency_level'] ?? 'medium',
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blood_type': bloodType,
      'quantity': quantity,
      'patient_name': patientName,
      'urgency_level': urgencyLevel,
      'status': status,
    };
  }
}

/// Nested: Registration/Donor Confirmation data
class RegistrationData {
  final String id;
  final bool attendanceConfirmed;
  final bool donationCompleted;
  final DonorData? donor;

  RegistrationData({
    required this.id,
    required this.attendanceConfirmed,
    required this.donationCompleted,
    this.donor,
  });

  factory RegistrationData.fromJson(Map<String, dynamic> json) {
    return RegistrationData(
      id: json['id'] ?? '',
      attendanceConfirmed: json['attendance_confirmed'] ?? false,
      donationCompleted: json['donation_completed'] ?? false,
      donor: json['user'] != null
          ? DonorData.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_confirmed': attendanceConfirmed,
      'donation_completed': donationCompleted,
      'user': donor?.toJson(),
    };
  }
}

/// Nested: Donor data (user)
class DonorData {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String bloodType;

  DonorData({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.bloodType,
  });

  factory DonorData.fromJson(Map<String, dynamic> json) {
    return DonorData(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      bloodType: json['blood_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'blood_type': bloodType,
    };
  }
}
