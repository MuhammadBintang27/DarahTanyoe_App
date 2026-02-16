import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';

/// Push Notification Service untuk menangani FCM notifications
/// Digunakan untuk menampilkan notifikasi real-time saat campaign dikirim
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  
  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;
  
  // Callback untuk handle notification tap
  Function(Map<String, dynamic>)? onNotificationTapped;
  
  // List untuk track received notifications
  List<Map<String, dynamic>> receivedNotifications = [];

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _localNotifications = FlutterLocalNotificationsPlugin();
  }

  /// Initialize push notifications
  /// Call this once on app startup
  Future<void> initialize() async {
    try {
      // Request notification permissions (iOS)
      if (Platform.isIOS) {
        await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          provisional: false,
          sound: true,
        );
      }

      // Request notification permissions (Android 13+)
      if (Platform.isAndroid) {
        final androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidImplementation != null) {
          final granted = await androidImplementation.requestNotificationsPermission();
        }
      }

      // Setup local notifications for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('ic_notification');

      // Create notification channel for Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          AndroidNotificationChannel(
            'darahtanyoe_channel',
            'DarahTanyoe Notifications',
            description: 'Notifikasi untuk kampanye dan permintaan darah',
            importance: Importance.max,
            enableVibration: true,
            enableLights: true,
            playSound: true,
            sound: const RawResourceAndroidNotificationSound('notification_sound'),
          ),
        );
      }

      final DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();

      // DON'T save token yet - wait until user logs in
      // Token akan disimpan di verifyOTP() atau savePersonalInfo()

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

      // Handle background notifications (when app is in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle token refresh - update backend when token changes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _updateFCMTokenForCurrentUser(newToken);
      });

    } catch (e) {
    }
  }

  /// Save FCM token to backend (internal, for backward compat)
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        return;
      }

      final userId = user['id'];
      final String apiUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';

      final response = await http.post(
        Uri.parse('$apiUrl/notifications/push-token/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  /// Register FCM token for specific user (called after login/profile complete)
  Future<void> registerFCMTokenForUser(String userId) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        return;
      }

      final String apiUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';
      
      final response = await http.post(
        Uri.parse('$apiUrl/notifications/push-token/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  /// Update FCM token for current logged-in user (when token is refreshed)
  Future<void> _updateFCMTokenForCurrentUser(String newToken) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        return;
      }

      final userId = user['id'];
      final String apiUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';

      final response = await http.post(
        Uri.parse('$apiUrl/notifications/push-token/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'fcm_token': newToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  /// Unregister FCM token (called on logout)
  Future<void> unregisterFCMTokenForUser(String userId) async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token == null) {
        return;
      }

      final String apiUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';

      // Delete push token from backend
      final response = await http.post(
        Uri.parse('$apiUrl/notifications/push-token/unregister'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  /// Handle foreground notifications (when app is open)
  void _handleForegroundNotification(RemoteMessage message) {
    // Add to received notifications list
    receivedNotifications.add({
      'title': message.notification?.title ?? 'Notifikasi',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now(),
    });

    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'Notifikasi',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap (both foreground and background)
  void _handleNotificationTap(RemoteMessage message) {
    // Call callback if set
    if (onNotificationTapped != null) {
      onNotificationTapped!(message.data);
    }

    // Handle navigation based on notification type
    _handleNotificationNavigation(message.data);
  }

  /// Handle local notification response (Android click)
  void _handleNotificationResponse(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        if (onNotificationTapped != null) {
          onNotificationTapped!(data);
        }
        _handleNotificationNavigation(data);
      }
    } catch (e) {
    }
  }

  /// Navigate based on notification type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle both camelCase and snake_case field names from Firebase
    final String? type = data['type'] ?? data['relatedType'];
    final String? referenceId = data['relatedId'] ?? data['related_id'] ?? data['referenceId'];

    if (referenceId == null) {
      return;
    }

    // Call callback - let the screen/app handle navigation
    if (onNotificationTapped != null) {
      onNotificationTapped!(data);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'darahtanyoe_channel',
        'DarahTanyoe Notifications',
        channelDescription: 'Notifikasi untuk kampanye dan permintaan darah',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        color: AppTheme.brand_01, // Warna brand merah DarahTanyoe
        icon: 'ic_notification',
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.caf',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      
    } catch (e) {
    }
  }

  /// Get all received notifications
  List<Map<String, dynamic>> getReceivedNotifications() {
    return receivedNotifications;
  }

  /// Clear received notifications
  void clearReceivedNotifications() {
    receivedNotifications.clear();
  }

  /// Subscribe to notification topic
  /// Useful for targeting groups of users
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
    }
  }
}
