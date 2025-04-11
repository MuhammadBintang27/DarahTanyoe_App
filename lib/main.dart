import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AuthService.init();
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