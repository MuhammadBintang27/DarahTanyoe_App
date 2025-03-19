import 'package:darahtanyoe_app/components/action_button.dart';
import 'package:flutter/material.dart';

import '../components/article_slider.dart';
import '../components/my_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Container(
        // Tambahkan decoration di sini
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/images/batik_pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header di luar scroll
            _buildHeader(),

            // Expanded agar sisanya bisa di-scroll
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: CustomBottomNavBar(
      selectedIndex: _selectedIndex,
      onItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
  );
}


  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/darah_tanyoe_logo.png',
              width: 200,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(8),
            child: Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/images/profil.png'),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo - Bintang!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            // Jarak sedikit
            SizedBox(height: 4),
            // Garis pemisah
            Container(
              height: 1,
              width: 240, // Atur lebar sesuai kebutuhan
              color: Colors.grey[500],
            ),
            // Jarak sedikit
            SizedBox(height: 4),
            Text(
              'Setetes Darah, Sejuta Harapan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      child: Row(
        children: [
          ActionButton(
            text: 'Minta Darah',
            color: Color(0xFFAB4545),
            textColor: Colors.white,
            icon: Icons.water_drop,
            onPressed: () {},
          ),
          SizedBox(width: 12),
          ActionButton(
            text: 'Donor Darah',
            color: Color(0xFF359B5E),
            textColor: Colors.white,
            icon: Icons.local_hospital,
            onPressed: () {},
            isOutlined: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingDonations() {
  List<Map<String, dynamic>> donationData = [
    {
      "hospital": "RSUD Zainal Abidin",
      "desc": "Ibu melahirkan, butuh darah cepat",
      "bloodType": "A+",
      "filled": 2,
      "needed": 5,
      "date": "26 Juli 2024, 16.30 WIB",
    },
    {
      "hospital": "RSUD Zainal Abidin",
      "desc": "Darurat, membutuhkan darah segera",
      "bloodType": "A+",
      "filled": 1,
      "needed": 4,
      "date": "26 Juli 2024, 16.30 WIB",
    },
    // Bisa tambahkan lebih banyak data di sini
  ];

  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: Color(0x40E9B824), width: 2),
      boxShadow: [
        BoxShadow(
          color: Color(0x40E9B824),
          blurRadius: 4,
          spreadRadius: 5,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Permintaan Darah\nTerdekat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF565656),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {},
              child: Text('Lihat Semuanya', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Menggunakan ListView.builder untuk daftar yang panjang
        SizedBox(
          height: 200, // Atur tinggi list agar bisa discroll
          child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: donationData.length,
            itemBuilder: (context, index) {
              var data = donationData[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: _buildDonationCard(
                  data["hospital"],
                  data["desc"],
                  data["bloodType"],
                  data["filled"],
                  data["needed"],
                  data["date"],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}


  Widget _buildDonationCard(
  String hospital,
  String description,
  String bloodType,
  int filled,
  int required,
  String lastDonation,
) {
  return Container(
    padding: EdgeInsets.all(12.0),
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 245, 223, 157), // Background putih
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Rumah Sakit & Ikon
        Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.black54), // Ikon rumah sakit
            SizedBox(width: 8),
            Expanded(
              child: Text(
                hospital,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4),

        // Deskripsi Permintaan Darah
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.black54, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Row Golongan Darah & Donor Sebelum
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Donor Sebelum',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                SizedBox(height: 2),
                Text(
                  lastDonation,
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
            Text(
              bloodType,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),

        // Status Kantong Darah
        Row(
          children: [
            Icon(Icons.bloodtype, color: Colors.black54, size: 18),
            SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(text: 'Telah terisi '),
                  TextSpan(
                    text: '$filled',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' dari '),
                  TextSpan(
                    text: '$required Kantong',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  TextSpan(text: ' yang dibutuhkan'),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  

  Widget _buildPromotionCards() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildPromotionCard('SEMBAKO GRATIS',
                    'Poin > Manfaat Donor', 'Kupon Kesehatan'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildPromotionCard('SEMBAKO GRATIS',
                    'Poin > Manfaat Donor', 'Kupon Kesehatan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(
      String title, String subtitle, String description) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

