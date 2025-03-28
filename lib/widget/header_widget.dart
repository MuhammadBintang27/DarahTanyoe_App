import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart'; // Sesuaikan dengan path yang benar

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
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
                color: Colors.amber,
                shape: BoxShape.circle,
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