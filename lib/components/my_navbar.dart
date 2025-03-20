import 'package:darahtanyoe_app/pages/authentication/address_page.dart';
import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/authentication/personal_info.dart';
import 'package:darahtanyoe_app/pages/data_permintaan/data_darah.dart';
import 'package:darahtanyoe_app/pages/data_permintaan/jadwal_lokasi.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';


class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
  }) : super(key: key);

  void _navigateToPage(BuildContext context, int index) {
    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = HomeScreen();
        break;
      case 1:
        nextPage = LoginPage();
        break;
      case 2:
        nextPage = TransactionBlood();
        break;
      case 3:
        nextPage = AddressPage();
        break;
      case 4:
        nextPage = BloodInfo();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Color(0xFFBE3A3A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, 0, 'assets/logo/logo_home_nav.png', 'Beranda'),
              _buildNavItem(context, 1, 'assets/logo/logo_nearby_nav.png', 'Terdekat'),
              _buildNavItem(context, 2, 'assets/logo/logo_map_nav.png', 'Peta Darah'),
              _buildNavItem(context, 3, 'assets/logo/logo_transaction_nav.png', 'Transaksi'),
              _buildNavItem(context, 4, 'assets/logo/logo_account_nav.png', 'Akun'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String iconPath, String label) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => _navigateToPage(context, index),
      child: Container(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isSelected)
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Color(0xFFECB23E),
                  shape: BoxShape.circle,
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
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
