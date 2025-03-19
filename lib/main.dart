import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/authentication/splash_screen.dart';
import 'package:darahtanyoe_app/pages/authentication/address_page.dart';
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DarahTanyoe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'DMSans',
        useMaterial3: true,
      ),
      home: const NotifikasiScreen(), // Langsung merujuk ke halaman Notifikasi
    );
  }
}