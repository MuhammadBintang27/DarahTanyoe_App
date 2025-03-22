import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/mainpage/peta_darah.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';

import '../../components/my_navbar.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    LoginPage(),
    BloodMap(),
    TransactionBlood(),
    BloodInfo(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped, // Tambahkan callback
      ),
    );
  }
}
