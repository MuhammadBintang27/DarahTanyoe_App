import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/batik_pattern.png'),
          opacity: 0.6,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Layer hitam dengan opacity 6%
          Container(
            color: Colors.black.withOpacity(0.06),
          ),
          child,
        ],
      ),
    );
  }
}
