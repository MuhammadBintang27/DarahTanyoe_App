import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isOutlined;

  const ActionButton({
    Key? key,
    required this.text,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onPressed,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        // Tambahkan boxShadow di Container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              // Gunakan warna tombol untuk shadow
              color: color,
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ],
        ),
        child: isOutlined
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, color: textColor),
                label: Text(
                  text,
                  style: TextStyle(color: textColor),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, color: Colors.white),
                label: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
      ),
    );
  }
}
