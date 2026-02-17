import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/service/campaign_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/pages/detail_permintaan/detail_permintaan_darah.dart';
import 'package:darahtanyoe_app/main.dart';
import 'package:flutter/cupertino.dart';

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
          await androidImplementation.requestNotificationsPermission();
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
            'darahtanyoe_channel_v2', // New channel ID to force recreation
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

      // Get FCM token but don't save yet - wait until user logs in
      // Token akan disimpan di registerFCMTokenForUser() setelah login
      await _firebaseMessaging.getToken();

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

      // Handle background notifications (when app is in background/terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle token refresh - update backend when token changes
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _updateFCMTokenForCurrentUser(newToken);
      });

    } catch (e) {
      // Intentionally empty - non-blocking error
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
      // Intentionally empty - token registration error is non-blocking
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
        // Token registered successfully
      } else {
        // API error - non-blocking
      }
    } catch (e) {
      // Intentionally empty - non-blocking error
    }
  }

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
        // Token updated successfully
      } else {
        // API error - non-blocking
      }
    } catch (e) {
      // Intentionally empty - non-blocking error
    }
  }

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
        // Token unregistered successfully
      } else {
        // API error - non-blocking
      }
    } catch (e) {
      // Intentionally empty - non-blocking error
    }
  }
  void _handleForegroundNotification(RemoteMessage message) {
    // Add to received notifications list
    receivedNotifications.add({
      'title': message.notification?.title ?? 'Notifikasi',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'timestamp': DateTime.now(),
    });

    // Show local notification with heads-up (requires android.priority: 'high' from backend)
    _showLocalNotification(
      title: message.notification?.title ?? 'Notifikasi',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle notification tap (both foreground and background)
  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation - this will use direct navigation if possible,
    // or fallback to callback if context not ready yet
    _handleNotificationNavigation(message.data);
  }

  /// Handle local notification response (Android click)
  void _handleNotificationResponse(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final data = jsonDecode(response.payload!);
        // Handle navigation - this will use direct navigation if possible,
        // or fallback to callback if context not ready yet
        _handleNotificationNavigation(data);
      }
    } catch (e) {
      // Intentionally empty - notification tap handling error is non-blocking
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Handle both camelCase and snake_case field names from Firebase
    final String? referenceId = data['relatedId'] ?? data['related_id'] ?? data['referenceId'];
    final String? type = data['type'] ?? data['relatedType'];

    if (referenceId == null) {
      return;
    }

    // Try direct navigation first (for app opened from background/killed state)
    final context = MyApp.navigatorKey.currentContext;
    if (context != null) {
      _navigateToDetail(context, type, referenceId);
      return;
    }

    // Fallback to callback if context not available yet
    if (onNotificationTapped != null) {
      onNotificationTapped!(data);
    }
  }

  /// Direct navigation to detail page based on notification type
  void _navigateToDetail(BuildContext context, String? type, String campaignId) async {
    try {
      // For campaign/blood_campaign type, navigate to detail page
      if (type == 'campaign' || type == 'blood_campaign') {
        // Fetch campaign data
        final campaign = await CampaignService.getCampaignById(campaignId);
        
        if (campaign == null) {
          return;
        }
        
        // Navigate to detail page using global navigator
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => DetailPermintaanDarah(permintaan: campaign),
          ),
        );
      }
    } catch (e) {
      // Intentionally empty - navigation error is non-blocking, fallback to callback
      if (onNotificationTapped != null) {
        onNotificationTapped!({
          'relatedId': campaignId,
          'type': type,
        });
      }
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
        'darahtanyoe_channel_v2', // New channel ID to force recreation
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
      // Intentionally empty - notification display error is non-blocking
    }
  }

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
      // Intentionally empty - non-blocking error
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Intentionally empty - non-blocking error
    }
  }
}