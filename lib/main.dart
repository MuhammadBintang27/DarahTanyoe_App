import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:flutter/material.dart';

import 'pages/authentication/address_page.dart';

void main() {
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
        fontFamily: 'DMSans',
        useMaterial3: true,
      ),
      home: const LoginPage(), // Ganti ke SplashScreen dulu
    );
  }
}
