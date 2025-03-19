import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CopyrightWidget extends StatelessWidget {
  final String owner;
  final Color textColor;

  const CopyrightWidget({
    Key? key,
    this.owner = "Beyond",
    this.textColor = const Color(0xFFCC5555),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© ${DateTime.now().year} $owner. Hak Cipta Dilindungi.',
        style: GoogleFonts.dmSans(
          textStyle: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
