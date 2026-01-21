/// Donor Confirmation Model - Tracks donor responses to fulfillment requests
/// Based on donor_confirmations table from database schema
class DonorConfirmationModel {
  final String id;
  final String fulfillmentRequestId;
  final String? campaignId;
  final String donorId;
  final String? donorName;
  final String? bloodType;
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

  DonorConfirmationModel({
    required this.id,
    required this.fulfillmentRequestId,
    this.campaignId,
    required this.donorId,
    this.donorName,
    this.bloodType,
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
  });

  /// Check if code is still valid
  bool get isCodeValid {
    if (codeExpiresAt == null) return false;
    if (codeVerified) return false; // Code invalid after verification
    return DateTime.now().isBefore(codeExpiresAt!);
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

  /// Check if code expired
  bool get isCodeExpired {
    if (codeExpiresAt == null) return false;
    return DateTime.now().isAfter(codeExpiresAt!);
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
    );
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
  }) {
    return DonorConfirmationModel(
      id: id ?? this.id,
      fulfillmentRequestId: fulfillmentRequestId ?? this.fulfillmentRequestId,
      campaignId: campaignId ?? this.campaignId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      bloodType: bloodType ?? this.bloodType,
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
    );
  }

  @override
  String toString() {
    return 'DonorConfirmationModel(id: $id, donorId: $donorId, status: $status, uniqueCode: $uniqueCode)';
  }
}
