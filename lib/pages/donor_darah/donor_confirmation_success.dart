import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonorConfirmationSuccess extends StatefulWidget {
  final String uniqueCode;
  final String donorName;
  final String bloodType;
  final String instructions;
  final String codeExpiresAt;

  const DonorConfirmationSuccess({
    Key? key,
    required this.uniqueCode,
    required this.donorName,
    required this.bloodType,
    required this.instructions,
    required this.codeExpiresAt,
  }) : super(key: key);

  @override
  State<DonorConfirmationSuccess> createState() => _DonorConfirmationSuccessState();
}

class _DonorConfirmationSuccessState extends State<DonorConfirmationSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          AppBarWithLogo(
            title: 'Konfirmasi Berhasil',
            onBackPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.withOpacity(0.2),
                            Colors.green.withOpacity(0.05),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Konfirmasi Berhasil!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neutral_01,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Terima kasih atas kesediaan Anda',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),                    

                    // Unique Code Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFAB4545).withOpacity(0.2),
                            Colors.white.withOpacity(0.01),
                          ],
                          stops: const [0.37, 0.81],
                        ),
                        border: Border.all(
                          color: const Color(0xFF565656).withOpacity(0.26),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_2,
                                size: 20,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Kode Unik Anda',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.uniqueCode,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.brand_01,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tunjukkan kode ini saat donor darah',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: widget.uniqueCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                                      SizedBox(width: 8),
                                      Text('Kode berhasil disalin!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text(
                              'Salin Kode',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.brand_01,
                              side: const BorderSide(
                                color: AppTheme.brand_01,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brand_01,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('selectedIndex', 0);
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.home, size: 20),
                  label: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.brand_01,
                    side: const BorderSide(
                      color: AppTheme.brand_01,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('selectedIndex', 3 );
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(initialIndex: 3),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.history, size: 20),
                  label: const Text(
                    'Lihat Riwayat Donasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
