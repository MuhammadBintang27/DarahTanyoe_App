import 'dart:typed_data';

/// Donor Confirmation Model - Tracks donor responses to fulfillment requests
/// Based on donor_confirmations table from database schema
class DonorConfirmationModel {
  final String id;
  final String fulfillmentRequestId;
  final String? campaignId;
  final String donorId;
  final String? donorName;
  final String? bloodType;
  final String? patientBloodType; // ✅ NEW: Blood type needed for patient
  final String status; // 'pending', 'confirmed', 'code_verified', 'completed', 'rejected', 'expired', 'failed'
  final String? uniqueCode;
  final DateTime? codeGeneratedAt;
  final DateTime? codeExpiresAt;
  final bool codeVerified;
  final DateTime? codeVerifiedAt;
  final String? verifiedBy; // Institution ID
  final String? donationId;
  final DateTime? donationCompletedAt;
  final String? rejectionReason;
  final String? failureReason;
  final DateTime? notifiedAt;
  final String? notificationId;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  // ✅ NEW: Origin and PMI info for donor biasa
  final String? confirmationOrigin; // 'donor_biasa' or 'fulfillment'
  final String? pmiId; // target PMI for donor biasa
  final DateTime? scheduledAt; // donor biasa scheduled time if present
  
  // ✅ NEW: Patient info from fulfillment request
  final String? patientName;
  final String? campaignLocation; // ✅ NEW: Location of campaign (donation place)
  final String? campaignAddress; // ✅ NEW: Full address of campaign
  final double? campaignLatitude; // ✅ NEW: Extracted from campaign_location GEOGRAPHY
  final double? campaignLongitude; // ✅ NEW: Extracted from campaign_location GEOGRAPHY
  final double? distanceKm; // ✅ NEW: Distance to donation location in km
  
  // ✅ NEW: Nested objects from API response
  final FulfillmentRequestData? fulfillmentRequest;
  final CampaignData? campaign;

  DonorConfirmationModel({
    required this.id,
    required this.fulfillmentRequestId,
    this.campaignId,
    required this.donorId,
    this.donorName,
    this.bloodType,
    this.patientBloodType, // ✅ NEW
    required this.status,
    this.uniqueCode,
    this.codeGeneratedAt,
    this.codeExpiresAt,
    required this.codeVerified,
    this.codeVerifiedAt,
    this.verifiedBy,
    this.donationId,
    this.donationCompletedAt,
    this.rejectionReason,
    this.failureReason,
    this.notifiedAt,
    this.notificationId,
    this.checkInTime,
    this.checkOutTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.patientName,
    this.campaignLocation,
    this.campaignAddress,
    this.campaignLatitude,
    this.campaignLongitude,
    this.distanceKm,
    this.fulfillmentRequest,
    this.campaign,
    this.confirmationOrigin,
    this.pmiId,
    this.scheduledAt,
  });

  /// Check if code is still valid
  bool get isCodeValid {
    if (codeExpiresAt == null) return false;
    if (codeVerified) return false; // Code invalid after verification
    return DateTime.now().isBefore(codeExpiresAt!);
  }

  /// ✅ NEW: Get human-readable status display
  String get statusDisplay {
    switch (status) {
      case 'pending_notification':
        return 'Menunggu Konfirmasi';
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      case 'expired':
        return 'Kadaluarsa';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }

  /// ✅ NEW: Get formatted time remaining for code
  String get formattedTimeRemaining {
    if (codeExpiresAt == null) return 'N/A';
    
    final now = DateTime.now();
    if (now.isAfter(codeExpiresAt!)) return 'Sudah Kadaluarsa';
    
    final remaining = codeExpiresAt!.difference(now);
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    
    if (days > 0) {
      return '$days HARI, ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  /// ✅ NEW: Check if code is expired
  bool get isCodeExpired {
    if (codeExpiresAt == null) return false;
    return DateTime.now().isAfter(codeExpiresAt!);
  }

  /// Check if confirmation is still pending
  bool get isPending {
    return status == 'pending';
  }

  /// Check if confirmation is confirmed
  bool get isConfirmed {
    return status == 'confirmed';
  }

  /// Check if donation is completed
  bool get isCompleted {
    return status == 'completed';
  }

  /// Check if confirmation is rejected
  bool get isRejected {
    return status == 'rejected';
  }

  /// Calculate days remaining for code
  int? get daysRemainingForCode {
    if (codeExpiresAt == null) return null;
    return codeExpiresAt!.difference(DateTime.now()).inDays;
  }

  /// Parse from JSON API response
  factory DonorConfirmationModel.fromJson(Map<String, dynamic> json) {
    return DonorConfirmationModel(
      id: json['id'] ?? '',
      fulfillmentRequestId: json['fulfillment_request_id'] ?? '',
      campaignId: json['campaign_id'],
      donorId: json['donor_id'] ?? '',
      donorName: json['donor_name'] ?? json['donor']?['full_name'],
      bloodType: json['blood_type'] ?? json['donor']?['blood_type'],
      patientBloodType: json['fulfillment_request']?['blood_type'], // ✅ NEW: Get from fulfillment_request
      status: json['status'] ?? 'pending',
      uniqueCode: json['unique_code'],
      codeGeneratedAt: json['code_generated_at'] != null 
          ? DateTime.tryParse(json['code_generated_at']) 
          : null,
      codeExpiresAt: json['code_expires_at'] != null 
          ? DateTime.tryParse(json['code_expires_at']) 
          : null,
      codeVerified: json['code_verified'] ?? false,
      codeVerifiedAt: json['code_verified_at'] != null 
          ? DateTime.tryParse(json['code_verified_at']) 
          : null,
      verifiedBy: json['verified_by'],
      donationId: json['donation_id'],
      donationCompletedAt: json['donation_completed_at'] != null 
          ? DateTime.tryParse(json['donation_completed_at']) 
          : null,
      rejectionReason: json['rejection_reason'],
      failureReason: json['failure_reason'],
      notifiedAt: json['notified_at'] != null 
          ? DateTime.tryParse(json['notified_at']) 
          : null,
      notificationId: json['notification_id'],
      checkInTime: json['check_in_time'] != null 
          ? DateTime.tryParse(json['check_in_time']) 
          : null,
      checkOutTime: json['check_out_time'] != null 
          ? DateTime.tryParse(json['check_out_time']) 
          : null,
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      // ✅ NEW: Extract patient info from nested fulfillment_request
      patientName: json['fulfillment_request']?['patient_name'] ?? json['patient_name'],
      // ✅ UPDATED: Try to get campaign data from fulfillment_request.campaign first, then fallback to direct campaign
      campaignLocation: json['fulfillment_request']?['campaign']?['location'] ?? json['campaign']?['location'],
      campaignAddress: json['fulfillment_request']?['campaign']?['address'] ?? json['campaign']?['address'],
      campaignLatitude: _extractLatitudeFromGeography(
        json['fulfillment_request']?['campaign']?['campaign_location'] ?? 
        json['campaign']?['campaign_location']
      ),
      campaignLongitude: _extractLongitudeFromGeography(
        json['fulfillment_request']?['campaign']?['campaign_location'] ?? 
        json['campaign']?['campaign_location']
      ),
      distanceKm: json['distance_km'] is num ? (json['distance_km'] as num).toDouble() : null,
      fulfillmentRequest: json['fulfillment_request'] != null
          ? FulfillmentRequestData.fromJson(json['fulfillment_request'])
          : null,
      // ✅ UPDATED: Use campaign from fulfillment_request if available, otherwise use direct campaign
      campaign: json['fulfillment_request']?['campaign'] != null
          ? CampaignData.fromJson(json['fulfillment_request']['campaign'])
          : (json['campaign'] != null ? CampaignData.fromJson(json['campaign']) : null),
      // ✅ NEW: origin + PMI info
      confirmationOrigin: json['confirmation_origin'],
      pmiId: json['pmi_id'],
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at']) : null,
    );
  }

  /// ✅ NEW: Extract latitude from GEOGRAPHY/EWKB format
  static double? _extractLatitudeFromGeography(dynamic geoData) {
    if (geoData == null) return null;
    
    try {
      // Handle EWKB format (hexadecimal string)
      if (geoData is String) {
        return _parseEWKBLatitude(geoData);
      }
      
      // Handle GeoJSON format (Map)
      if (geoData is Map<String, dynamic>) {
        final coordinates = geoData['coordinates'];
        
        if (coordinates is List && coordinates.length >= 2) {
          final lat = coordinates[1] as double; // [longitude, latitude]
          return lat;
        }
      }
    } catch (e) {
      // Intentionally empty - latitude extraction error is handled by fallback
    }
    return null;
  }

  /// Extract longitude from coordinates array
  static double? _extractLongitudeFromGeography(dynamic geoData) {
    if (geoData == null) return null;
    
    try {
      // Handle EWKB format (hexadecimal string)
      if (geoData is String) {
        return _parseEWKBLongitude(geoData);
      }
      
      // Handle GeoJSON format (Map)
      if (geoData is Map<String, dynamic>) {
        final coordinates = geoData['coordinates'];
        
        if (coordinates is List && coordinates.length >= 2) {
          final lng = coordinates[0] as double; // [longitude, latitude]
          return lng;
        }
      }
    } catch (e) {
      // Intentionally empty - longitude extraction error is handled by fallback
    }
    return null;
  }
  
  /// Parse EWKB hexadecimal string to extract latitude (Y coordinate)
  static double? _parseEWKBLatitude(String ewkbHex) {
    try {
      // EWKB format: 01 (byte order) + 01000020 (type) + E6100000 (SRID) + 8 bytes (X/longitude) + 8 bytes (Y/latitude)
      // Positions: 0-2 (byte order), 2-10 (type), 10-18 (SRID), 18-34 (longitude), 34-50 (latitude)
      
      if (ewkbHex.length < 50) {
        return null;
      }
      
      // Extract latitude (Y coordinate) - last 16 characters (8 bytes as hex)
      final latHex = ewkbHex.substring(34, 50);
      
      // Convert hex string to double (little-endian)
      final latBytes = _hexToBytes(latHex);
      final latitude = _bytesToDouble(latBytes);
      
      return latitude;
    } catch (e) {
      return null;
    }
  }
  
  /// ✅ NEW: Parse EWKB hexadecimal string to extract longitude (X coordinate)
  static double? _parseEWKBLongitude(String ewkbHex) {
    try {
      // EWKB format: 01 (byte order) + 01000020 (type) + E6100000 (SRID) + 8 bytes (X/longitude) + 8 bytes (Y/latitude)
      // Positions: 0-2 (byte order), 2-10 (type), 10-18 (SRID), 18-34 (longitude), 34-50 (latitude)
      
      if (ewkbHex.length < 50) {
        return null;
      }
      
      // Extract longitude (X coordinate) - characters 18-34 (8 bytes as hex)
      final lngHex = ewkbHex.substring(18, 34);
      
      // Convert hex string to double (little-endian)
      final lngBytes = _hexToBytes(lngHex);
      final longitude = _bytesToDouble(lngBytes);
      
      return longitude;
    } catch (e) {
      return null;
    }
  }
  
  /// ✅ NEW: Convert hex string to bytes
  static List<int> _hexToBytes(String hex) {
    final List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      final hexPair = hex.substring(i, i + 2);
      bytes.add(int.parse(hexPair, radix: 16));
    }
    return bytes;
  }
  
  /// ✅ NEW: Convert bytes to double (little-endian)
  static double _bytesToDouble(List<int> bytes) {
    final ByteData bd = ByteData.view(Uint8List.fromList(bytes).buffer);
    return bd.getFloat64(0, Endian.little);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fulfillment_request_id': fulfillmentRequestId,
      'campaign_id': campaignId,
      'donor_id': donorId,
      'donor_name': donorName,
      'blood_type': bloodType,
      'patient_blood_type': patientBloodType, // ✅ NEW
      'status': status,
      'unique_code': uniqueCode,
      'code_generated_at': codeGeneratedAt?.toIso8601String(),
      'code_expires_at': codeExpiresAt?.toIso8601String(),
      'code_verified': codeVerified,
      'code_verified_at': codeVerifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'donation_id': donationId,
      'donation_completed_at': donationCompletedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'failure_reason': failureReason,
      'notified_at': notifiedAt?.toIso8601String(),
      'notification_id': notificationId,
      'check_in_time': checkInTime?.toIso8601String(),
      'check_out_time': checkOutTime?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'patient_name': patientName,
      'campaign_location': campaignLocation,
      'campaign_address': campaignAddress,
      'campaign_latitude': campaignLatitude,
      'campaign_longitude': campaignLongitude,
      'confirmation_origin': confirmationOrigin,
      'pmi_id': pmiId,
      'scheduled_at': scheduledAt?.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  DonorConfirmationModel copyWith({
    String? id,
    String? fulfillmentRequestId,
    String? campaignId,
    String? donorId,
    String? donorName,
    String? bloodType,
    String? patientBloodType,
    String? status,
    String? uniqueCode,
    DateTime? codeGeneratedAt,
    DateTime? codeExpiresAt,
    bool? codeVerified,
    DateTime? codeVerifiedAt,
    String? verifiedBy,
    String? donationId,
    DateTime? donationCompletedAt,
    String? rejectionReason,
    String? failureReason,
    DateTime? notifiedAt,
    String? notificationId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? patientName,
    String? campaignLocation,
    String? campaignAddress,
    double? campaignLatitude,
    double? campaignLongitude,
    String? confirmationOrigin,
    String? pmiId,
    DateTime? scheduledAt,
  }) {
    return DonorConfirmationModel(
      id: id ?? this.id,
      fulfillmentRequestId: fulfillmentRequestId ?? this.fulfillmentRequestId,
      campaignId: campaignId ?? this.campaignId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      bloodType: bloodType ?? this.bloodType,
      patientBloodType: patientBloodType ?? this.patientBloodType,
      status: status ?? this.status,
      uniqueCode: uniqueCode ?? this.uniqueCode,
      codeGeneratedAt: codeGeneratedAt ?? this.codeGeneratedAt,
      codeExpiresAt: codeExpiresAt ?? this.codeExpiresAt,
      codeVerified: codeVerified ?? this.codeVerified,
      codeVerifiedAt: codeVerifiedAt ?? this.codeVerifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      donationId: donationId ?? this.donationId,
      donationCompletedAt: donationCompletedAt ?? this.donationCompletedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      failureReason: failureReason ?? this.failureReason,
      notifiedAt: notifiedAt ?? this.notifiedAt,
      notificationId: notificationId ?? this.notificationId,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      patientName: patientName ?? this.patientName,
      campaignLocation: campaignLocation ?? this.campaignLocation,
      campaignAddress: campaignAddress ?? this.campaignAddress,
      campaignLatitude: campaignLatitude ?? this.campaignLatitude,
      campaignLongitude: campaignLongitude ?? this.campaignLongitude,
      confirmationOrigin: confirmationOrigin ?? this.confirmationOrigin,
      pmiId: pmiId ?? this.pmiId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  @override
  String toString() {
    return 'DonorConfirmationModel(id: $id, donorId: $donorId, status: $status, uniqueCode: $uniqueCode)';
  }
}

/// ✅ NEW: Nested model for fulfillment_request data
class FulfillmentRequestData {
  final String? id;
  final String? campaignId;
  final String? patientName;
  final String? bloodType;
  final DateTime? createdAt;
  final int? quantityNeeded;
  final int? quantityCollected;
  final CampaignData? campaign; // ✅ NEW: Nested campaign data

  FulfillmentRequestData({
    this.id,
    this.campaignId,
    this.patientName,
    this.bloodType,
    this.createdAt,
    this.quantityNeeded,
    this.quantityCollected,
    this.campaign, // ✅ NEW
  });

  factory FulfillmentRequestData.fromJson(Map<String, dynamic> json) {
    return FulfillmentRequestData(
      id: json['id'],
      campaignId: json['campaign_id'],
      patientName: json['patient_name'],
      bloodType: json['blood_type'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      quantityNeeded: json['quantity_needed'] is int
          ? json['quantity_needed']
          : int.tryParse(json['quantity_needed']?.toString() ?? '0'),
      quantityCollected: json['quantity_collected'] is int
          ? json['quantity_collected']
          : int.tryParse(json['quantity_collected']?.toString() ?? '0'),
      // ✅ NEW: Parse nested campaign data
      campaign: json['campaign'] != null
          ? CampaignData.fromJson(json['campaign'])
          : null,
    );
  }
}

/// ✅ NEW: Nested model for campaign/blood_campaign data
class CampaignData {
  final String? id;
  final String? title;
  final String? location;
  final String? address;
  final dynamic campaignLocation; // GEOGRAPHY type
  final String? description;

  CampaignData({
    this.id,
    this.title,
    this.location,
    this.address,
    this.campaignLocation,
    this.description,
  });

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      id: json['id'],
      title: json['title'],
      location: json['location'],
      address: json['address'],
      campaignLocation: json['campaign_location'],
      description: json['description'],
    );
  }
}
