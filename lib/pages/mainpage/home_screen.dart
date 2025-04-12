import 'dart:ui';

import 'package:darahtanyoe_app/components/action_button.dart';
import 'package:darahtanyoe_app/components/bloodCard.dart';
import 'package:darahtanyoe_app/helpers/formatDateTime.dart';
import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/pages/data_permintaan/data_diri.dart';
import 'package:darahtanyoe_app/pages/authentication/personal_info.dart';
import 'package:darahtanyoe_app/pages/detail_permintaan/detail_permintaan_darah.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/service/permintaan_terdekat.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/article_slider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea( // SafeArea di dalam BackgroundWidget
          child: Column(
            children: [
              HeaderWidget(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserProfile(),
                      _buildActionButtons(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: _buildPendingDonations(),
                      ),
                      buildArticleSlider(),
                      _buildPromotionCards(),
                      SizedBox(height: 90)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildUserProfile() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        String userName = 'User';

        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
          userName = snapshot.data!['full_name'] ?? 'User';
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.brand_03,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/profil.png'),
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo - $userName!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.neutral_01,
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    height: 1,
                    width: 240, // Atur lebar sesuai kebutuhan
                    color: AppTheme.neutral_03,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Setetes Darah, Sejuta Harapan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral_01,
                      shadows: [
                        Shadow(
                          color: AppTheme.brand_03.withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: 16, top: 8), // Atur jarak hanya di Wallet
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DataPemintaanDarah()),
                    );
                  },
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.brand_02,
                    size: 30,
                  ),
                ),
                SizedBox(height: 4),
                // Gunakan FutureBuilder untuk mendapatkan total_points
                FutureBuilder<Map<String, dynamic>?>(
                  future:
                  AuthService().getCurrentUser(), // Mengambil data pengguna
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Loading
                    } else if (snapshot.hasError) {
                      return Text("Error fetching points");
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text("Data pengguna tidak ditemukan");
                    }

                    var userData = snapshot.data;
                    int totalPoints = userData?["total_points"] ?? 2;

                    return Text(
                      '$totalPoints Poin', // Menampilkan jumlah poin
                      style: TextStyle(
                        color: AppTheme.brand_02,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ActionButton(
            text: 'Minta Darah',
            color: AppTheme.brand_01,
            textColor: Colors.white,
            icon: Icons.water_drop,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DataPemintaanDarah()),
              );
            },
          ),
          SizedBox(width: 12),
          ActionButton(
            text: 'Donor Darah',
            color: AppTheme.brand_03,
            textColor: Colors.white,
            icon: Icons.local_hospital,
            onPressed: () {
              SharedPreferences.getInstance().then((prefs) {
                prefs.setInt('selectedIndex', 1);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false,
                );
              });
            },
            isOutlined: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingDonations() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brand_02,
            blurRadius: 11,
          ),
        ],
      ),
      child: FutureBuilder<List<PermintaanDarahModel>>(
        future: _getNearbyBloodRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingContent(); // Menampilkan loading di dalam container
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${snapshot.error.toString()}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Tutup',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            });

            // Tampilkan konten kosong ketika error
            return _buildEmptyContent();
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyContent(); // Menampilkan teks jika data kosong
          }

          List<PermintaanDarahModel> donationData = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(),
              SizedBox(height: 3),
              SizedBox(
                height: 200, // Atur tinggi list agar bisa discroll
                child: ListView.builder(
                  padding: EdgeInsets.all(16), // Tambahkan padding di sini
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics(),
                  itemCount: donationData.length,
                  itemBuilder: (context, index) {
                    var data = donationData[index];
                    String formattedDate = formatDateTime(data.expiry_date);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BloodCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => DetailPermintaanDarah(
                                permintaan: data,
                              ),
                            ),
                          );
                        },
                        createdAt: data.createdAt!,
                        status: data.status,
                        bloodType: data.bloodType,
                        date: formattedDate,
                        hospital: data.partner_name,
                        isNearest: true,
                        isHomeScreen: true,
                        distance: data.distance,
                        bagCount: data.bloodBagsFulfilled,
                        totalBags: data.bloodBagsNeeded,
                        isRequest: true,
                        uniqueCode: data.uniqueCode,
                        description: (data.description.isNotEmpty) ? data.description : '-',
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// Fungsi helper untuk mendapatkan userId terlebih dahulu kemudian memanggil service
  Future<List<PermintaanDarahModel>> _getNearbyBloodRequests() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User tidak ditemukan atau belum login');
      }

      final String userId = user['id'];
      return await PermintaanTerdekat().fetchBloodRequests(userId);
    } catch (e) {
      throw Exception('Gagal mengambil data permintaan darah: $e');
    }
  }

// Judul bagian atas container
  Widget _buildSectionTitle() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF1EEE5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.brand_02.withOpacity(0.4),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8), // padding teks saja
                child: Text(
                  'Permintaan Darah\nTerdekat',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.neutral_01,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neutral_01,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setInt('selectedIndex', 1);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                        (route) => false,
                  );
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semuanya',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Tampilan saat loading data
  Widget _buildLoadingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.brand_01,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Memuat data...',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              )
          ),
        ),
      ],
    );
  }

// Tampilan saat data kosong
  Widget _buildEmptyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 50, color: Colors.grey[400]),
                SizedBox(height: 4),
                Text(
                  "Tidak ada permintaan darah terdekat saat ini",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(
      String title, String description, int points, String backgroundImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8), // Agar efek blur mengikuti border
      child: Stack(
        children: [
          // Background Image dengan Blur
          Positioned.fill(
            child: ImageFiltered(
              imageFilter:
              ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Blur latar belakang
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Overlay dengan efek gelap agar teks tetap terbaca
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Konten Kartu
          Container(
            padding: EdgeInsets.all(12),
            width: 200,
            height: 210,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.white.withOpacity(0.5)), // Border tipis
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (ellipsis jika panjang)
                Text(
                  title,
                  maxLines: 2, // Batasi 1 baris
                  overflow:
                  TextOverflow.ellipsis, // Tambahkan titik-titik (...)
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),

                // Deskripsi (ellipsis jika panjang)
                Text(
                  description,
                  maxLines: 5, // Batasi 3 baris
                  overflow:
                  TextOverflow.ellipsis, // Tambahkan titik-titik (...)
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Spacer(),

                // Poin dengan Icon (posisi kanan)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 20,
                        color: const Color.fromARGB(255, 245, 203, 79),
                      ),
                    ),
                    Text(
                      '$points Poin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 245, 203, 79),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCards() {
    List<Map<String, dynamic>> promotions = [
      {
        "title": "SEMBAKO GRATIS",
        "description":
        "Palang Merah Indonesia menyediakan Sembako gratis pendonor yang telah mengumpulkan cukup poin.",
        "points": 50,
        "backgroundImage": "assets/images/sembako.png"
      },
      {
        "title": "Ayo Donor Sekarang",
        "description": "Bantu sesama dan raih hadiah menarik!",
        "points": 30,
        "backgroundImage": "assets/images/sembako.png"
      },
      {
        "title": "Hadiah Menarik!",
        "description": "Kumpulkan poin dan tukarkan dengan hadiah eksklusif.",
        "points": 75,
        "backgroundImage": "assets/images/sembako.png"
      }
    ];

    return SizedBox(
      height: 210, // Sesuaikan dengan ukuran card

      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll ke kiri-kanan
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          var promo = promotions[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16 : 8, right: 8),
            child: _buildPromotionCard(
              promo["title"],
              promo["description"],
              promo["points"],
              promo["backgroundImage"],
            ),
          );
        },
      ),
    );
  }
}
