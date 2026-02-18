import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'service/auth_service.dart';
import 'service/push_notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';

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
    // Intentionally empty - Firebase initialization error is non-blocking
  }
  
  await AuthService.init();
  
  // Initialize push notifications
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();
  
  runApp(const MyApp());
}

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription? _sub;
  
  static void initialize() {
    // Handle initial deep link when app is opened from terminated state
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
    
    // Handle deep links when app is already running
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });
  }
  
  static void _handleDeepLink(Uri uri) {
    // Handle: darahtanyoe://confirmation/{confirmation_id}
    if (uri.scheme == 'darahtanyoe' && uri.host == 'confirmation') {
      final confirmationId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (confirmationId != null) {
        // Navigate to Transaksi page with confirmation ID for auto-navigation
        MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => TransactionBlood(
              defaultTab: 'berlangsung',
              confirmationId: confirmationId,
            ),
          ),
          (route) => false,
        );
      }
    }
  }
  
  static void dispose() {
    _sub?.cancel();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<MainScreenState> mainScreenKey = GlobalKey();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.initialize();
  }

  @override
  void dispose() {
    DeepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
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