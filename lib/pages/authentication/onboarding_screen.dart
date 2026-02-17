import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  int currentIndex = 0;

  final List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: "Sekilas DarahTanyoe",
    description:
        "DarahTanyoe adalah aplikasi donor darah yang mengintegrasikan pendonor, PMI, dan rumah sakit dalam satu sistem terpadu.",
    image: "assets/images/onboarding_1.webp",
  ),
  OnboardingData(
    title: "Di Sekitar Anda",
    description:
        "Aplikasi menampilkan kebutuhan darah di sekitar lokasi pendonor serta mendukung proses pendonoran melalui PMI.",
    image: "assets/images/onboarding_2.webp",
  ),
  OnboardingData(
    title: "Dalam Genggaman",
    description:
        "Pantau pendonoran, transaksi, serta informasi stok darah dan PMI langsung melalui aplikasi.",
    image: "assets/images/onboarding_3.webp",
  ),
];
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await _storage.write(key: 'onboarding_completed', value: 'true');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _nextPage() {
    if (currentIndex == onboardingPages.length - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Background pattern (optional, atau putih polos)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                // Bisa tambah batik pattern seperti login jika mau
                image: DecorationImage(
                  image: AssetImage('assets/images/batik_pattern.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            Column(
              children: [
                // ── Top Bar: Logo ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Image.asset(
                    'assets/images/darah_tanyoe_logo.png',
                    height: 50,
                  ),
                ),
                
                // ── Top: Illustration Section ──
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => currentIndex = index);
                        },
                        itemCount: onboardingPages.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            onboardingPages[index].image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Placeholder jika gambar belum ada
                              return Icon(
                                _getIconForIndex(index),
                                size: 240,
                                color: AppTheme.brand_01.withValues(alpha: 0.3),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                // ── Bottom: Curved Content Section ──
                Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.brand_01,
                        Color(0xFFCC8888),
                        Color(0xFFF8F0F0),
                      ],
                      stops: [0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        onboardingPages[currentIndex].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Description
                      Text(
                        onboardingPages[currentIndex].description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 17,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingPages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: currentIndex == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Navigation Buttons
                      Row(
                        children: [
                          // Skip / Back button
                          if (currentIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 2),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Kembali',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: TextButton(
                                onPressed: _completeOnboarding,
                                child: Text(
                                  'Lewati',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(width: 12),
                          
                          // Next / Mulai button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _nextPage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.brand_01,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                currentIndex == onboardingPages.length - 1
                                    ? 'Mulai Sekarang'
                                    : 'Lanjut',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.volunteer_activism;
      case 1:
        return Icons.emergency;
      case 2:
        return Icons.notifications_active;
      default:
        return Icons.info;
    }
  }
}


class OnboardingData {
  final String title;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
  });
}