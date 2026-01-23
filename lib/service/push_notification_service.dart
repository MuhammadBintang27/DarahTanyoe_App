import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';

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
          print('📱 Notification permission granted: $granted');
        }
      }

      // Setup local notifications for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

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
          ),
        );
        print('✅ Android notification channel created');
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
      print('✅ FCM Token: $token');

      // Save token to backend
      if (token != null) {
        await _saveFCMToken(token);
      }

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

      // Handle background notifications (when app is in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen(_saveFCMToken);

      print('✅ Push Notification Service initialized');
    } catch (e) {
      print('❌ Error initializing push notifications: $e');
    }
  }

  /// Save FCM token to backend
  Future<void> _saveFCMToken(String token) async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null) {
        print('⚠️ User not authenticated, cannot save FCM token');
        return;
      }

      final userId = user['id'];
      final String apiUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:4000';

      final response = await http.post(
        Uri.parse('$apiUrl/notification/save-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token saved to backend');
      } else {
        print('❌ Failed to save FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error saving FCM token: $e');
    }
  }

  /// Handle foreground notifications (when app is open)
  void _handleForegroundNotification(RemoteMessage message) {
    print('📬 Foreground notification received');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

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
    print('👆 Notification tapped');
    print('Data: ${message.data}');

    // Call callback if set
    if (onNotificationTapped != null) {
      onNotificationTapped!(message.data);
    }

    // Handle navigation based on notification type
    _handleNotificationNavigation(message.data);
  }

  /// Handle local notification response (Android click)
  void _handleNotificationResponse(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');

    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        if (onNotificationTapped != null) {
          onNotificationTapped!(data);
        }
        _handleNotificationNavigation(data);
      }
    } catch (e) {
      print('Error parsing notification payload: $e');
    }
  }

  /// Navigate based on notification type
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle both camelCase and snake_case field names from Firebase
    final String? type = data['type'] ?? data['relatedType'];
    final String? referenceId = data['relatedId'] ?? data['related_id'] ?? data['referenceId'];

    print('📍 Notification data: type=$type, id=$referenceId');

    if (referenceId == null) {
      print('⚠️ No referenceId/relatedId/related_id in notification data');
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
      print('🔔 Attempting to show local notification: $title');
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'darahtanyoe_channel',
        'DarahTanyoe Notifications',
        channelDescription: 'Notifikasi untuk kampanye dan permintaan darah',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        color: Color.fromARGB(255, 220, 20, 60), // Crimson red (darah)
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      print('📤 Showing notification with ID: $notificationId');
      
      await _localNotifications.show(
        notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
      
      print('✅ Local notification shown successfully');
    } catch (e) {
      print('❌ Error showing local notification: $e');
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
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }
}
