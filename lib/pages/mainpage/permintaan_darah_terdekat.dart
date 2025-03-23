import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Model untuk Permintaan Darah
class PermintaanDarahModel {
  final String id;
  final String partner_id; // Dalam kode Anda, ini tampaknya digunakan sebagai nama rumah sakit
  final String bloodType;
  final String bloodBagsNeeded;
  final int bloodBagsFulfilled;
  final String description;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String uniqueCode;

  PermintaanDarahModel({
    required this.id,
    required this.partner_id,
    required this.bloodType,
    required this.bloodBagsNeeded,
    required this.bloodBagsFulfilled,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.uniqueCode,
  });

  factory PermintaanDarahModel.fromJson(Map<String, dynamic> json) {
    return PermintaanDarahModel(
      id: json['id'] ?? '',
      partner_id: json['partner_id'] ?? '',
      bloodType: json['bloodType'] ?? '',
      bloodBagsNeeded: json['bloodBagsNeeded'] ?? '0',
      bloodBagsFulfilled: json['bloodBagsFulfilled'] ?? 0,
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] ?? DateTime.now().toString(),
      updatedAt: json['updatedAt'] ?? DateTime.now().toString(),
      uniqueCode: json['uniqueCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partner_id': partner_id,
      'bloodType': bloodType,
      'bloodBagsNeeded': bloodBagsNeeded,
      'bloodBagsFulfilled': bloodBagsFulfilled,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'uniqueCode': uniqueCode,
    };
  }
}

class NearestBloodDonation extends StatefulWidget {
  final String? uniqueCode;
  
  const NearestBloodDonation({Key? key, this.uniqueCode}) : super(key: key);

  @override
  State<NearestBloodDonation> createState() => _NearestBloodDonationState();
}

class _NearestBloodDonationState extends State<NearestBloodDonation> {
  bool isLoading = true;
  List<PermintaanDarahModel> permintaanList = [];

  @override
  void initState() {
    super.initState();
    _loadPermintaan();
  }

  // API call to fetch nearby blood requests
  static Future<List<PermintaanDarahModel>> getAllPermintaan(String userId) async {
    final url = Uri.parse('https://3a3c-103-47-133-149.ngrok-free.app/bloodReq/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => PermintaanDarahModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Load dummy data for testing
  void _loadDummyData() {
    // Buat beberapa objek PermintaanDarahModel untuk testing
    List<PermintaanDarahModel> dummyData = [
      PermintaanDarahModel(
        id: '1',
        partner_id: 'RSUD Dr. Soetomo',
        bloodType: 'A+',
        bloodBagsNeeded: '3',
        bloodBagsFulfilled: 1,
        description: 'Dibutuhkan untuk pasien kecelakaan lalu lintas',
        status: 'active',
        createdAt: DateTime.now().subtract(Duration(days: 1)).toString(),
        updatedAt: DateTime.now().toString(),
        uniqueCode: 'BD001',
      ),
      PermintaanDarahModel(
        id: '2',
        partner_id: 'RS Mitra Keluarga',
        bloodType: 'O-',
        bloodBagsNeeded: '5',
        bloodBagsFulfilled: 2,
        description: 'Dibutuhkan untuk operasi jantung',
        status: 'active',
        createdAt: DateTime.now().subtract(Duration(days: 2)).toString(),
        updatedAt: DateTime.now().toString(),
        uniqueCode: 'BD002',
      ),
      PermintaanDarahModel(
        id: '3',
        partner_id: 'RS Premier Surabaya',
        bloodType: 'B+',
        bloodBagsNeeded: '2',
        bloodBagsFulfilled: 0,
        description: 'Dibutuhkan untuk pasien melahirkan',
        status: 'active',
        createdAt: DateTime.now().subtract(Duration(days: 1)).toString(),
        updatedAt: DateTime.now().toString(),
        uniqueCode: 'BD003',
      ),
    ];

    setState(() {
      permintaanList = dummyData;
      isLoading = false;
    });
  }

  // Load empty data for testing empty state
  void _loadEmptyData() {
    setState(() {
      permintaanList = [];
      isLoading = false;
    });
  }

  // Load blood requests data
  Future<void> _loadPermintaan() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Delay 2 detik untuk simulasi loading dari network
      await Future.delayed(Duration(seconds: 2));
      
      if (mounted) {
        // Pilih salah satu dari method di bawah ini untuk menguji tampilan yang berbeda
        
        // 1. Untuk menampilkan data dummy dengan beberapa permintaan darah:
        _loadDummyData();
        
        // 2. Untuk menampilkan state kosong "Belum ada permintaan darah":
        // _loadEmptyData();
        
        // 3. Untuk menggunakan data asli dari API (uncomment kode di bawah):
        // String userId = "87a286ba-1dcd-4f63-ae5a-5433e190b3c8";
        // List<PermintaanDarahModel> data = await getAllPermintaan(userId);
        // setState(() {
        //   permintaanList = data;
        //   isLoading = false;
        // });

        // Jika uniqueCode diberikan, highlight permintaan tersebut
        if (widget.uniqueCode != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _highlightRequest(widget.uniqueCode!);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  // Highlight a specific blood request
  void _highlightRequest(String uniqueCode) {
    for (var i = 0; i < permintaanList.length; i++) {
      if (permintaanList[i].uniqueCode == uniqueCode) {
        // TODO: Implement highlighting (scroll to item or show dialog)
        print("Highlighting request with code: $uniqueCode");
        break;
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // Tidak menggunakan appBar standard
    body: SafeArea(
      child: Column(
        children: [
          // Pasang HeaderWidget sebagai widget biasa di bagian atas
          HeaderWidget(),
          
          // Konten utama menggunakan Expanded agar mengisi sisa ruang
          Expanded(
            child: isLoading 
              ? _buildLoadingIndicator() 
              : _buildContent(),
          ),
        ],
      ),
    ),
  );
}
  
  // Loading indicator widget
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFFAB4545)),
          SizedBox(height: 16),
          Text("Memuat data permintaan darah...")
        ],
      ),
    );
  }
  
  // Main content widget
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permintaan Darah Terdekat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Show blood request list
            _buildRequestContent(),
          ],
        ),
      ),
    );
  }

  // Widget to display blood requests
  Widget _buildRequestContent() {
    if (permintaanList.isEmpty) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6, // Beri tinggi agar konten berada di tengah layar
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Posisikan di tengah vertikal
            crossAxisAlignment: CrossAxisAlignment.center, // Posisikan di tengah horizontal
            children: [
              Icon(Icons.bloodtype_outlined, size: 80, color: Colors.grey[400]),
              SizedBox(height: 24),
              Text(
                "Belum ada permintaan darah terdekat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Container(
                width: MediaQuery.of(context).size.width * 0.8, // Batasi lebar teks
                child: Text(
                  "Permintaan darah disekitar Anda akan muncul di sini",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: permintaanList.map((permintaan) {
        // Format date for display
        String formattedDate = _formatDate(permintaan.partner_id);
        
        // Calculate filled blood bags
        int bagCount = permintaan.bloodBagsFulfilled;
        int totalBags = int.tryParse(permintaan.bloodBagsNeeded) ?? 5;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBloodCard(
            bloodType: permintaan.bloodType,
            date: formattedDate,
            hospital: permintaan.partner_id,
            description: permintaan.description,
            distance: _calculateDistance(permintaan.partner_id),
            bagCount: bagCount,
            totalBags: totalBags,
            uniqueCode: permintaan.uniqueCode,
            permintaan: permintaan,
          ),
        );
      }).toList(),
    );
  }

  // Widget for individual blood request card
  Widget _buildBloodCard({
    required String bloodType,
    required String date,
    required String hospital,
    required String description,
    required String distance,
    required int bagCount,
    required int totalBags,
    required String uniqueCode,
    required PermintaanDarahModel permintaan,
  }) {
    // Set colors - using red theme for donor view
    Color titleColor = Color(0xFFAB4545);
    Color borderColor = Color(0xFFE0E0E0);
    Color backgroundColor = Colors.white;

    return GestureDetector(
      onTap: () {
        // Handle navigation to detail
        // Since you mentioned not to integrate with detail page, 
        // we'll just make this a placeholder
        print("Navigate to detail for request: $uniqueCode");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 245, 223, 157).withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Permintaan Darah',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFAB4545),
                    ),
                  )
                ],
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
              SizedBox(height: 12),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.local_hospital, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          distance,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFAB4545),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      bloodType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFFAB4545),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.note_alt_outlined, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(Icons.bloodtype, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Telah terisi $bagCount dari $totalBags kantong yang dibutuhkan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAB4545),
                    ),
                  ),
                ],
              ),
              // No status row for donor view - donors don't need to see status
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper function to format date
  String _formatDate(String dateString) {
    try {
      // Parse the input date string
      DateTime date;
      if (dateString.contains('-')) {
        // Format: DD-MM-YYYY HH:MM
        List<String> parts = dateString.split(' ');
        List<String> dateParts = parts[0].split('-');
        List<String> timeParts = parts.length > 1 ? parts[1].split(':') : ['00', '00'];
        
        date = DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } else {
        // Assume ISO format
        date = DateTime.parse(dateString);
      }
      
      // Format the date
      return DateFormat('dd MMM yyyy HH:mm').format(date);
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }
  
  // Helper function to calculate distance (dummy implementation)
  String _calculateDistance(String location) {
    // Ini hanya implementasi dummy
    // Di aplikasi nyata, gunakan geolokasi untuk menghitung jarak sesungguhnya
    double randomDistance = (2 + (location.length % 8)) / 10.0 * 10;
    return '${randomDistance.toStringAsFixed(1)} km dari lokasi Anda';
  }
  
  // Helper function untuk parse expiry_date
  DateTime _parseExpiry_date(String partner_id) {
    try {
      if (partner_id.contains('-')) {
        // Format: DD-MM-YYYY HH:MM
        List<String> parts = partner_id.split(' ');
        List<String> dateParts = parts[0].split('-');
        List<String> timeParts = parts.length > 1 ? parts[1].split(':') : ['00', '00'];
        
        return DateTime(
          int.parse(dateParts[2]),
          int.parse(dateParts[1]),
          int.parse(dateParts[0]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } else {
        // Coba parse sebagai ISO string
        return DateTime.parse(partner_id);
      }
    } catch (e) {
      print('Error parsing expiry_date: $e');
      // Kembalikan waktu default jika parsing gagal
      return DateTime.now().add(const Duration(days: 1));
    }
  }
}