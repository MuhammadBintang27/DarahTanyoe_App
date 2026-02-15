import 'dart:convert';
import 'package:darahtanyoe_app/models/notification_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service untuk mengelola notifikasi donor
/// Maps langsung ke /notifications endpoints
class NotificationService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

  /// Get semua notifikasi untuk donor
  /// Maps: GET /notifications/user/:userId
  static Future<List<NotificationModel>> getNotifications(String userId,
      {bool includeRead = false}) async {
    try {
      final query = includeRead ? '?include_read=true' : '';
      final url = '$_baseUrl/notifications/user/$userId$query';
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend return structure: {status, code, message, data: [...]}
        final List<dynamic> notifications = data['data'] ?? [];
        
        return notifications
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get notifikasi yang belum dibaca saja
  /// Maps: GET /notifications/:userId?unread=true
  static Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/$userId?unread=true'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> notifications = data['data'] ?? [];
        return notifications
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get jumlah notifikasi yang belum dibaca
  /// Maps: GET /notifications/:userId/unread/count
  static Future<int> getUnreadCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/notifications/$userId/unread/count'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Mark notifikasi sebagai dibaca
  /// Maps: PATCH /notifications/:notificationId/read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      final url = '$_baseUrl/notifications/$notificationId/read';
      
      final response = await http.patch(
        Uri.parse(url),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Mark semua notifikasi sebagai dibaca
  /// Maps: PATCH /notifications/user/:userId/read-all
  static Future<bool> markAllAsRead(String userId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/notifications/user/$userId/read-all'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Delete notifikasi
  /// Maps: DELETE /notifications/:notificationId
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/$notificationId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Delete semua notifikasi yang expired
  /// Maps: DELETE /notifications/user/:userId/expired
  static Future<bool> deleteExpiredNotifications(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/notifications/user/$userId/expired'),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
