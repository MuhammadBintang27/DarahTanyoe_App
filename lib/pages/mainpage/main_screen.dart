import 'package:darahtanyoe_app/pages/mainpage/profil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/informasi_pmi.dart';
import 'package:darahtanyoe_app/pages/mainpage/permintaan_darah_terdekat.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import '../../components/my_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();

  static Future<void> navigateToTab(BuildContext context, int index, {String? transaksiTab}) async {
    final prefs = await SharedPreferences.getInstance();
    if (transaksiTab != null) {
      await prefs.setString('transaksiTab', transaksiTab);
    }

    await prefs.setInt('selectedIndex', index);
  }

}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _uniqueCode;

  @override
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  Future<void> _loadSelectedIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedIndex = prefs.getInt('selectedIndex') ?? 0;
    });
  }

  Future<void> changeTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint("changeTab dipanggil: index = $index");

    setState(() {
      _selectedIndex = index;
      _uniqueCode = (index == 3) ? prefs.getString('uniqueCode') : null;
    });

    await prefs.setInt('selectedIndex', _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Content area
          IndexedStack(
            index: _selectedIndex,
            children: [
              _wrapWithScrollableContainer(HomeScreen()),
              _wrapWithScrollableContainer(NearestBloodDonation()),
              _wrapWithScrollableContainer(InformasiPMI()),
              _wrapWithScrollableContainer(TransactionBlood(uniqueCode: _uniqueCode)),
              _wrapWithScrollableContainer(ProfileScreen()),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: (index) => changeTab(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrapWithScrollableContainer(Widget screen) {
    return SafeArea(
      bottom: false,
      child: screen,
    );
  }
}