import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/mainpage/peta_darah.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:darahtanyoe_app/pages/authentication/blood_info.dart';

import '../../components/my_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String? _uniqueCode;

  void changeTab(int index, {String? code}) {
  debugPrint("changeTab dipanggil: index = $index, code = $code");
  
  setState(() {
    _selectedIndex = index;
    _uniqueCode = (index == 2) ? code : null;
  });

  Future.delayed(Duration(milliseconds: 50), () {
    setState(() {});
  });

  debugPrint("Setelah setState gfhdsg: _selectedIndex = $_selectedIndex, _uniqueCode = $_uniqueCode");
}




  
  
@override
Widget build(BuildContext context) {
  debugPrint("============================================");
  debugPrint("MainScreen rebuild: _selectedIndex = $_selectedIndex, _uniqueCode = $_uniqueCode");
  
  return Scaffold(
    body: _selectedIndex == 0
    ? HomeScreen()
    : _selectedIndex == 1
        ? LoginPage()
        : _selectedIndex == 2
            ? TransactionBlood(uniqueCode: _uniqueCode)
            : _selectedIndex == 3
                ? BloodMap()
                : BloodInfo(),

    bottomNavigationBar: CustomBottomNavBar(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) => changeTab(index),
    ),
  );
}


}
