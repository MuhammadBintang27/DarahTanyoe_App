import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/theme/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate safe area bottom padding (for notches/home indicators)
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: MediaQuery.of(context).size.width,
      // Apply bottomPadding to ensure nav items don't get covered by device UI
      height: 80 + bottomPadding,
      decoration: BoxDecoration(
        color: AppTheme.brand_01,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset(0, -4)
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                  context, 0, 'assets/logo/logo_home_nav.png', 'Beranda'),
              _buildNavItem(
                  context, 1, 'assets/logo/logo_nearby_nav.png', 'Terdekat'),
              _buildNavItem(
                  context, 2, 'assets/logo/logo_map_nav.png', 'Info PMI'),
              _buildNavItem(context, 3, 'assets/logo/logo_transaction_nav.png',
                  'Transaksi'),
              _buildNavItem(
                  context, 4, 'assets/logo/logo_account_nav.png', 'Akun'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, int index, String iconPath, String label) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: SizedBox(
        height: 80, // Fixed height for nav items
        width: MediaQuery.of(context).size.width / 5, // Evenly distribute width
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.neutral_03.withValues(alpha: 0.2),
                      AppTheme.neutral_03.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: (label == 'Beranda')
                      ? BorderRadius.only(topLeft: Radius.circular(20))
                      : (label == 'Akun')
                      ? BorderRadius.only(topRight: Radius.circular(20))
                      : BorderRadius.zero,
                  border: Border(
                    top: BorderSide(width: 3, color: Colors.white70),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  width: 30,
                  height: 30,
                  color: Colors.white,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}