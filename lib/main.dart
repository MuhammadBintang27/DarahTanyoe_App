

import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart';
import 'package:darahtanyoe_app/pages/detail_permintaan/detail_permintaan_darah.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final GlobalKey<MainScreenState> mainScreenKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),

home: MainScreen(key: MyApp.mainScreenKey),
    );
  }
}
