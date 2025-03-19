import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const MyButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF476EB6), // Default warna biru
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Gunakan warna yang bisa diubah
          foregroundColor: Colors.white, // Warna teks saat tombol ditekan
          minimumSize: const Size(120, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color.fromARGB(255, 222, 216, 216), width: 1),
          ),
          elevation: 8, // Tambahkan elevasi agar ada shadow
          shadowColor: Colors.black.withOpacity(0.9), // Warna shadow
        ),
        child: Text(
          text,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
