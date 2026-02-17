import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({super.key, this.message = "Memuat data ..."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          const CircularProgressIndicator(color: AppTheme.brand_01),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}
