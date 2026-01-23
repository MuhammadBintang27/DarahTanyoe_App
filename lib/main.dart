import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'service/auth_service.dart';
import 'service/push_notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase already initialized: $e');
  }
  
  await AuthService.init();
  
  // Initialize push notifications
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<MainScreenState> mainScreenKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DarahTanyoe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}