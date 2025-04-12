// import 'dart:convert';
// import 'dart:io';
//
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;
//
// class NotificationService {
//   // Instance dari FlutterLocalNotificationsPlugin
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // Channel untuk Android notifications
//   final AndroidNotificationChannel channel = const AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//   );
//
//   // Constructor
//   NotificationService();
//
//   // Inisialisasi FCM dan Local Notifications
//   Future<void> initialize() async {
//     // Inisialisasi FCM
//     await _initFirebaseMessaging();
//
//     // Inisialisasi Local Notifications
//     await _initLocalNotifications();
//
//     // Setup handler untuk pesan FCM
//     _setupFCMHandlers();
//   }
//
//   // Inisialisasi Firebase Messaging
//   Future<void> _initFirebaseMessaging() async {
//     // Request permission untuk notifikasi
//     await _requestNotificationPermissions();
//
//     // Get FCM token
//     String? token = await FirebaseMessaging.instance.getToken();
//     if (kDebugMode) {
//       print("FCM TOKEN: $token");
//     }
//
//     // Setup token refresh listener
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
//       // Simpan token baru ke server Anda
//       if (kDebugMode) {
//         print("Token diperbarui: $newToken");
//       }
//     });
//   }
//
//   // Request permission notifikasi
//   Future<void> _requestNotificationPermissions() async {
//     if (Platform.isIOS) {
//       // iOS permission
//       await FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );
//     } else if (Platform.isAndroid) {
//       // Android permission for API 33+ (Tiramisu)
//       flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();
//     }
//   }
//
//   // Inisialisasi Local Notifications
//   Future<void> _initLocalNotifications() async {
//     // Konfigurasi untuk Android
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/launcher_icon');
//
//     // Konfigurasi untuk iOS
//     const DarwinInitializationSettings initializationSettingsIOS =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     // Gabungkan konfigurasi
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     // Inisialisasi plugin
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
//     );
//
//     // Create notification channel for Android
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }
//
//   // Handler untuk ketika notifikasi ditekan
//   void _onDidReceiveNotificationResponse(NotificationResponse details) {
//     // Handle notification tap
//     if (details.payload != null) {
//       try {
//         final Map<String, dynamic> data = jsonDecode(details.payload!);
//         _handleNotificationTap(data);
//       } catch (e) {
//         if (kDebugMode) {
//           print("Error parsing notification payload: $e");
//         }
//       }
//     }
//   }
//
//   // Setup FCM handlers
//   void _setupFCMHandlers() {
//     // Handler ketika aplikasi di foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (kDebugMode) {
//         print('Pesan diterima di foreground: ${message.notification?.title}');
//       }
//
//       // Tampilkan notifikasi lokal
//       _showLocalNotification(message);
//     });
//
//     // Handler ketika aplikasi di background atau terminated
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       if (kDebugMode) {
//         print('Aplikasi dibuka dari notifikasi: ${message.notification?.title}');
//       }
//
//       // Handle notification tap
//       if (message.data.isNotEmpty) {
//         _handleNotificationTap(message.data);
//       }
//     });
//
//     // Setup background handler
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   }
//
//   // Menampilkan notifikasi lokal
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     // Only show notification if it has notification data and on Android
//     if (notification != null && android != null) {
//       await flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channelDescription: channel.description,
//             icon: '@mipmap/launcher_icon',
//           ),
//           iOS: const DarwinNotificationDetails(),
//         ),
//         payload: jsonEncode(message.data),
//       );
//     }
//   }
//
//   // Handle tap notifikasi
//   void _handleNotificationTap(Map<String, dynamic> data) {
//     // Implementasikan navigasi berdasarkan data yang diterima
//     // Contoh:
//     if (data.containsKey('screen')) {
//       String? routeName = data['screen'];
//       // Navigate to specific screen
//       if (kDebugMode) {
//         print("Navigate to: $routeName");
//       }
//
//       // Implementasikan navigasi Anda di sini
//       // Contoh: Navigator.of(context).pushNamed(routeName);
//     }
//   }
//
//   // Mengirim notifikasi lokal
//   Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     await flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channelDescription: channel.description,
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/launcher_icon',
//         ),
//         iOS: const DarwinNotificationDetails(),
//       ),
//       payload: payload,
//     );
//   }
//
//   // Menjadwalkan notifikasi lokal
//   Future<void> scheduleLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//     String? payload,
//   }) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, local),
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channelDescription: channel.description,
//           importance: Importance.high,
//           priority: Priority.high,
//           icon: '@mipmap/launcher_icon',
//         ),
//         iOS: const DarwinNotificationDetails(),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       uiLocalNotificationDateInterpretation:
//       UILocalNotificationDateInterpretation.absoluteTime,
//       payload: payload,
//     );
//   }
//
//   // Get zona waktu untuk notifikasi terjadwal
//   static final local = getLocalTimeZone();
//
//   // Helper method untuk mendapatkan zona waktu lokal
//   static getLocalTimeZone() {
//     return tz.TZDateTime.now(local);
//   }
// }
//
// // Handler untuk pesan yang diterima saat aplikasi di background
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Inisialisasi Firebase terlebih dahulu
//   await Firebase.initializeApp();
//
//   if (kDebugMode) {
//     print("Background message received: ${message.notification?.title}");
//   }
// }