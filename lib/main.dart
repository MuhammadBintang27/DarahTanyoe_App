
import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/data_permintaan/data_diri.dart';
import 'package:flutter/material.dart';

import 'service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init(); // Inisialisasi Hive
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: DataDiri(), // Ganti ke SplashScreen dulu
    );
  }
}