import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart'; // Sesuaikan dengan path yang benar

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/darah_tanyoe_logo.png',
              width: 200,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const  NotificationPage()),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.brand_02,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.brand_02
                        .withOpacity(0.5), // Warna kuning lebih pekat
                    spreadRadius:
                    6, // Lebih luas agar efek bercahaya lebih terlihat
                    blurRadius: 15, // Glow lebih soft
                    offset: Offset(0, 0), // Efek merata
                  ),
                ],
              ),
              padding: EdgeInsets.all(8),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}