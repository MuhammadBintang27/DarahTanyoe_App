import 'dart:async';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/service/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'login_page.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));

    try {
      // Check if access token exists in secure storage
      final String? accessToken = await storage.read(key: 'access_token');
      final String? expiryDateStr = await storage.read(key: 'expiry_date');

      if (!mounted) return;

      // Check if token exists and is not expired
      if (accessToken != null && accessToken.isNotEmpty && expiryDateStr != null) {
        // Parse expiry date
        final DateTime expiryDate = DateTime.parse(expiryDateStr);
        final DateTime now = DateTime.now();

        // If token exists and is not expired, navigate to main screen
        if (expiryDate.isAfter(now)) {
          // ✅ Register FCM token untuk existing user
          try {
            // Ambil user ID dari userData di secure storage
            final String? userDataStr = await storage.read(key: 'userData');
            if (userDataStr != null) {
              final Map<String, dynamic> userData = jsonDecode(userDataStr);
              final String? userId = userData['id'];
              
              if (userId != null) {
                final pushNotificationService = PushNotificationService();
                await pushNotificationService.registerFCMTokenForUser(userId);
              }
            }
          } catch (fcmError) {
            // Non-blocking error, continue navigation
          }
          
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
          return;
        }
      }

      // If no valid token or expired, check onboarding completion first
      final String? onboardingCompleted = await storage.read(key: 'onboarding_completed');
      
      if (!mounted) return;
      
      if (onboardingCompleted == null || onboardingCompleted != 'true') {
        // Show onboarding if not completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        // Show login page if onboarding completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      // On error, check onboarding completion first
      if (!mounted) return;
      
      final String? onboardingCompleted = await storage.read(key: 'onboarding_completed');
      
      if (!mounted) return;
      
      if (onboardingCompleted == null || onboardingCompleted != 'true') {
        // Show onboarding if not completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else {
        // Show login page if onboarding completed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
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
              AppTheme.brand_01, // Darker red at top
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
                      color: AppTheme.neutral_01,
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
