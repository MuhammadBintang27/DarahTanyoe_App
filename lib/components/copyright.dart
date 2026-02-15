import 'package:flutter/material.dart';

class CopyrightWidget extends StatelessWidget {
  final String owner;
  final Color textColor;

  const CopyrightWidget({
    super.key,
    this.owner = "Beyond",
    this.textColor = const Color(0xFFCC5555),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© ${DateTime.now().year} $owner. Hak Cipta Dilindungi.',
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
