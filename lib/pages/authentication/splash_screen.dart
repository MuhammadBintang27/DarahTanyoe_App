import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart'; // Pastikan ini ada

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFCC5555), // Darker red at top
              Color(0xFFF8F0F0), // Light color at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background pattern image
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/batik_pattern.png',
                  repeat: ImageRepeat.repeat,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Main illustration (blood donation with tubes, bag and handshake)
                Center(
                  child: Image.asset(
                    'assets/images/donation_illustration.png',
                    width: 700,
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(flex: 1),

                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Image.asset(
                    'assets/images/darah_tanyoe_logo.png',
                    width: 300,
                  ),
                ),

                const SizedBox(height: 16),

                const Spacer(flex: 2),

                // Copyright text
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    '© ${DateTime.now().year} Beyond. Hak Cipta Dilindungi.',
                    style: const TextStyle(
                      color: Color(0xFF555555),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
