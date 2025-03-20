import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:darahtanyoe_app/pages/data_permintaan/data_diri.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:flutter/material.dart';

import 'pages/authentication/address_page.dart';
import 'pages/detail_permintaan/detail_permintaan_darah.dart';

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
        fontFamily: 'DM Sans',
        useMaterial3: true,
      ),
      home: LoginPage(), // Ganti ke SplashScreen dulu
    );
  }
}
