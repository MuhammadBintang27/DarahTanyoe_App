/// Notification Model - Represents notifications for users/institutions
/// Based on notifications table from database schema
class NotificationModel {
  final String id;
  final String? userId;
  final String? institutionId;
  final String title;
  final String message;
  final String type; // 'donation', 'pickup', 'stock', 'campaign', 'request', 'system'
  final String priority; // 'low', 'medium', 'high', 'critical'
  final String? relatedId; // Reference to campaign/request/donation ID
  final String? relatedType; // 'campaign', 'request', 'donation', etc
  final bool isRead;
  final DateTime? readAt;
  final String? actionUrl;
  final String? actionLabel;
  final String? imageUrl;
  final bool pushSent;
  final bool emailSent;
  final bool smsSent;
  final DateTime? expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    this.userId,
    this.institutionId,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    this.relatedId,
    this.relatedType,
    required this.isRead,
    this.readAt,
    this.actionUrl,
    this.actionLabel,
    this.imageUrl,
    required this.pushSent,
    required this.emailSent,
    required this.smsSent,
    this.expiresAt,
    this.metadata,
    required this.createdAt,
  });

  /// Check if notification is still valid
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if notification is unread
  bool get isUnread {
    return !isRead;
  }

  /// Check if this is a campaign notification
  bool get isCampaignNotification {
    return type == 'campaign' && relatedType == 'campaign';
  }

  /// Get confirmation ID from metadata (if available)
  String? get confirmationId {
    return metadata?['confirmationId'] as String?;
  }

  /// Parse from JSON API response
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'],
      institutionId: json['institution_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'system',
      priority: json['priority'] ?? 'medium',
      relatedId: json['related_id'] ?? json['campaign_id'],
      relatedType: json['related_type'] ?? 'campaign',
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      actionUrl: json['action_url'],
      actionLabel: json['action_label'],
      imageUrl: json['image_url'],
      pushSent: json['push_sent'] ?? false,
      emailSent: json['email_sent'] ?? false,
      smsSent: json['sms_sent'] ?? false,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at']) : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'institution_id': institutionId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'related_id': relatedId,
      'related_type': relatedType,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'action_url': actionUrl,
      'action_label': actionLabel,
      'image_url': imageUrl,
      'push_sent': pushSent,
      'email_sent': emailSent,
      'sms_sent': smsSent,
      'expires_at': expiresAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    String? institutionId,
    String? title,
    String? message,
    String? type,
    String? priority,
    String? relatedId,
    String? relatedType,
    bool? isRead,
    DateTime? readAt,
    String? actionUrl,
    String? actionLabel,
    String? imageUrl,
    bool? pushSent,
    bool? emailSent,
    bool? smsSent,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      institutionId: institutionId ?? this.institutionId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      actionUrl: actionUrl ?? this.actionUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      imageUrl: imageUrl ?? this.imageUrl,
      pushSent: pushSent ?? this.pushSent,
      emailSent: emailSent ?? this.emailSent,
      smsSent: smsSent ?? this.smsSent,
      expiresAt: expiresAt ?? this.expiresAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}
