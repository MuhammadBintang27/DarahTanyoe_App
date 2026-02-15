import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF476EB6), // Default warna biru
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Gunakan warna yang bisa diubah
          foregroundColor: Colors.white, // Warna teks saat tombol ditekan
          minimumSize: const Size(120, 48), // Tambah tinggi dengan ubah nilai height
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Padding vertikal lebih besar
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Colors.white, // Warna border putih
              width: 0.3, // Ketebalan border 0.5
            ),
          ),
          elevation: 8, // Tambahkan elevasi agar ada shadow
          shadowColor: Colors.black.withOpacity(0.9), // Warna shadow
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2), // Padding tambahan di dalam button
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
