// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
// FlutterLocalNotificationsPlugin();
//
// Future<void> setupFCM() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//
//   // Request permission
//   await messaging.requestPermission();
//
//   // Get token (kirim ke backend kalau perlu)
//   final fcmToken = await messaging.getToken();
//   print("FCM Token: $fcmToken");
//
//   // Foreground handler
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//
//     if (notification != null && android != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'default_channel',
//             'Default',
//             channelDescription: 'Default channel for FCM',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//       );
//     }
//   });
//
//   // Background & Terminated
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     // Navigate if needed
//     print("User tapped notification: ${message.data}");
//   });
//
//   // Local notification config
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//
//   const InitializationSettings initializationSettings =
//   InitializationSettings(android: initializationSettingsAndroid);
//
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
// }
