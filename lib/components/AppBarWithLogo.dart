import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';

class AppBarWithLogo extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const AppBarWithLogo({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Memastikan elemen di luar AppBar tetap terlihat
      children: [
        Container(
          height: 76, // Tinggi default AppBar
          decoration: BoxDecoration(
            color: AppTheme.brand_01,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, // Memastikan semua item vertikal center
            children: [
              // Tombol Back
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () {
                  Navigator.pop(context);
                },
              ),

              // Judul di tengah
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),

              // Tombol Notifikasi
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    // Navigasi ke NotificationPage saat ikon notifikasi ditekan
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationPage()),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFCC33),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Logo di bawah AppBar
        Positioned(
          top: 60, // Sesuaikan dengan tinggi AppBar agar pas di bawahnya
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade300), // Garis tepi merah
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png', // Pastikan path benar
                height: 16, // Sesuaikan tinggi logo
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}