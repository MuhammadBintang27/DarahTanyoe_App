import 'package:flutter/material.dart';

class KembaliButton extends StatelessWidget {
  final VoidCallback onPressed;

  const KembaliButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0), // ⬅️ Padding vertical
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), // ⬅️ Shadow ringan
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(30), // biar shadow-nya ikut bentuk button
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE9B824), // Warna kuning untuk kembali
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.zero, // biar nggak dobel padding
            ),
            onPressed: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("<",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  Text("Kembali",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
