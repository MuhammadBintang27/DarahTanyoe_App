import 'package:darahtanyoe_app/pages/mainpage/profil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:darahtanyoe_app/pages/mainpage/home_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/informasi_pmi.dart';
import 'package:darahtanyoe_app/pages/mainpage/permintaan_darah_terdekat.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:darahtanyoe_app/service/push_notification_service.dart';
import 'package:darahtanyoe_app/pages/detail_permintaan/detail_permintaan_darah.dart';
import 'package:flutter/cupertino.dart';
import 'package:darahtanyoe_app/service/campaign_service.dart';
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
    _setupNotificationCallback();
  }

  /// Setup notification tap callback - handle like permintaan_darah_terdekat onTap
  void _setupNotificationCallback() {
    final pushService = PushNotificationService();
    pushService.onNotificationTapped = (data) {
      final String? type = data['type'] ?? data['relatedType'];
      final String? id = data['relatedId'] ?? data['related_id'];

      print('🔔 Notification tapped in MainScreen: type=$type, id=$id');

      if (id == null) return;

      // Direct Navigator.push like permintaan_darah_terdekat
      if (type == 'campaign' || type == 'blood_campaign') {
        _navigateToCampaignDetail(id);
      } else if (type == 'request' || type == 'blood_request') {
        _navigateToRequestDetail(id);
      }
    };
  }

  /// Fetch campaign data and navigate to detail
  void _navigateToCampaignDetail(String campaignId) async {
    try {
      print('📡 Fetching campaign detail: $campaignId');
      final campaign = await CampaignService.getCampaignById(campaignId);
      
      if (campaign == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kampanye tidak ditemukan'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      
      if (mounted) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DetailPermintaanDarah(permintaan: campaign),
          ),
        );
      }
    } catch (e) {
      print('❌ Error fetching campaign: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail kampanye'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Fetch blood request data and navigate to detail
  /// Now uses getCampaignById (unified endpoint /campaigns/:id)
  void _navigateToRequestDetail(String requestId) async {
    try {
      print('📡 Fetching request detail: $requestId');
      final request = await CampaignService.getCampaignById(requestId);
      
      if (request == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permintaan darah tidak ditemukan'), backgroundColor: Colors.red),
          );
        }
        return;
      }
      
      if (mounted) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => DetailPermintaanDarah(permintaan: request),
          ),
        );
      }
    } catch (e) {
      print('❌ Error fetching request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail permintaan'), backgroundColor: Colors.red),
        );
      }
    }
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