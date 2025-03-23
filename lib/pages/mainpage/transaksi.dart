import 'dart:convert';

import 'package:darahtanyoe_app/widget/header_widget.dart';
import '../../models/permintaan_darah_model.dart';
import '../../service/permintaan_darah_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// Tambahkan import untuk BloodDonationDetailScreen
import '../detail_permintaan/detail_permintaan_darah.dart'; // Sesuaikan dengan lokasi file yang benar

class TransactionBlood extends StatefulWidget {
  final String? uniqueCode;
  
  const TransactionBlood({Key? key, this.uniqueCode}) : super(key: key);

  @override
  State<TransactionBlood> createState() => _TransactionBloodState();
}

class _TransactionBloodState extends State<TransactionBlood> {
  // Track which tab is selected
  
  bool isRequestTab = true;
  bool isLoading = true;
  
  // Lists for storing actual data from the service
  List<PermintaanDarahModel> permintaanList = [];

  @override
  void initState() {
    super.initState();
    _loadPermintaan();
  }
  static Future<List<PermintaanDarahModel>> getAllPermintaan(String userId) async {
    final url = Uri.parse('https://3a3c-103-47-133-149.ngrok-free.app/bloodReq/$userId');

    try {
      final response = await http.get(url);
      print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print(jsonData);
        return jsonData.map((item) => PermintaanDarahModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> _loadPermintaan() async {
  setState(() {
    isLoading = true;
  });

  try {
    String userId = "87a286ba-1dcd-4f63-ae5a-5433e190b3c8"; // Gantilah dengan userId yang sesuai
    List<PermintaanDarahModel> data = await getAllPermintaan(userId);

    if (mounted) {
      setState(() {
        permintaanList = data;
        isLoading = false;
      });

      // Jika ada kode unik yang diberikan, scroll ke permintaan tersebut
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

  
  void _highlightRequest(String uniqueCode) {
    // Implementasi untuk menyoroti permintaan dengan uniqueCode tertentu
    // Misalnya dengan menampilkan dialog atau scroll ke item tersebut
    for (var i = 0; i < permintaanList.length; i++) {
      if (permintaanList[i].uniqueCode == uniqueCode) {
        // Implementasi highlight
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HeaderWidget(),
      ),
      body: isLoading 
        ? _buildLoadingIndicator() 
        : _buildTransactionBody(),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFFAB4545)),
          SizedBox(height: 16),
          Text("Memuat data transaksi...")
        ],
      ),
    );
  }
  
  Widget _buildTransactionBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Anda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Toggle buttons for switching between request and donation
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isRequestTab = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRequestTab
                            ? Colors.red.shade700
                            : Colors.transparent,
                        foregroundColor:
                            isRequestTab ? Colors.white : Colors.black,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Text('Permintaan Darah'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isRequestTab = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isRequestTab
                            ? Colors.red.shade700
                            : Colors.transparent,
                        foregroundColor:
                            !isRequestTab ? Colors.white : Colors.black,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Text('Pendonoran Darah'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Display different content based on selected tab
            isRequestTab ? _buildRequestContent() : _buildDonationContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestContent() {
    if (permintaanList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bloodtype_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Belum ada permintaan darah",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Permintaan darah yang Anda buat akan muncul di sini",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: permintaanList.map((permintaan) {
        // Konversi string tanggal ke format yang lebih mudah dibaca
        String formattedDate = _formatDate(permintaan.partner_id);
        
        // Hitung kantong darah yang telah terpenuhi
        int bagCount = permintaan.bloodBagsFulfilled;
        int totalBags = int.tryParse(permintaan.bloodBagsNeeded) ?? 5;
        
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBloodCard(
            status: _getStatusText(permintaan.status),
            bloodType: "${permintaan.bloodType}",
            date: formattedDate,
            hospital: permintaan.partner_id,
            distance: _calculateDistance(permintaan.partner_id),
            bagCount: bagCount,
            totalBags: totalBags,
            isCompleted: permintaan.status == PermintaanDarahModel.STATUS_COMPLETED,
            isCancelled: permintaan.status == PermintaanDarahModel.STATUS_CANCELLED,
            isRequest: true,
            uniqueCode: permintaan.uniqueCode,
            permintaan: permintaan, // Meneruskan permintaan ke card
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDonationContent() {
    // Untuk saat ini, tampilkan pesan bahwa fitur pendonoran belum tersedia
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Fitur Pendonoran Darah",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Fitur ini akan segera hadir. Anda akan dapat melihat riwayat donasi darah Anda di sini.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodCard({
    required String status,
    required String bloodType,
    required String date,
    required String hospital,
    required String distance,
    required int bagCount,
    required int totalBags,
    required bool isCompleted,
    required bool isCancelled,
    required bool isRequest,
    required String uniqueCode,
    required PermintaanDarahModel permintaan, // Tambahkan parameter permintaan
    bool isUrgent = false,
  }) {
    // Warna berdasarkan status
    Color statusColor;
    Color titleColor;
    Color borderColor;
    Color backgroundColor;

    if (isCancelled) {
      statusColor = Color(0xFFAB4545);
      titleColor = Color(0xFFAB4545);
      borderColor = Color(0xFFAB4545);
      backgroundColor = Color.fromRGBO(171, 69, 69, 0.08);
    } else if (isCompleted) {
      statusColor = Color(0xFF359B5E);
      titleColor = Color(0xFF359B5E);
      borderColor = Color(0xFF359B5E);
      backgroundColor = Color.fromRGBO(53, 155, 94, 0.10);
    } else {
      statusColor = Color(0xFFCB9B0A);
      titleColor = Color(0xFFCB9B0A);
      borderColor = Color(0xFFE9B824);
      backgroundColor = Color.fromRGBO(233, 184, 36, 0.06);
    }

    return GestureDetector(
      onTap: () {
        _navigateToDetailScreen(permintaan);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
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
                    isRequest ? 'Permintaan Darah Anda' : 'Pendonoran Darah Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: titleColor),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Kode: $uniqueCode',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.local_hospital, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hospital,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(distance,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: titleColor, width: 2),
                    ),
                    child: Text(
                      bloodType,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: titleColor,
                      ),
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
                    'Telah terisi $bagCount dari $totalBags Kantong yang dibutuhkan',
                    style: TextStyle(fontSize: 12, color: titleColor),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (isUrgent && !isCompleted && !isCancelled)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper function untuk navigasi ke halaman detail
  void _navigateToDetailScreen(PermintaanDarahModel permintaan) {
    // Konversi dari PermintaanDarahModel ke PatientDonationData
    final patientData = PatientDonationData(
      patientName: permintaan.patientName,
      patientAge: int.tryParse(permintaan.patientAge) ?? 0,
      phoneNumber: permintaan.phoneNumber,
      bloodType: permintaan.bloodType,
      bloodBagsNeeded: int.tryParse(permintaan.bloodBagsNeeded) ?? 0,
      description: permintaan.description,
      partner_id: permintaan.partner_id,
      expiry_date: permintaan.expiry_date,
    );
    
    // Tentukan status berdasarkan status permintaan
    DonationStatus donationStatus;
    DonationStatusType statusType;
    
    switch(permintaan.status) {
      case PermintaanDarahModel.STATUS_PENDING:
        statusType = DonationStatusType.pending;
        break;
      case PermintaanDarahModel.STATUS_WAITING:
        statusType = DonationStatusType.countdown;
        break;
      case PermintaanDarahModel.STATUS_ACCEPTED:
        statusType = DonationStatusType.confirmed;
        break;
      case PermintaanDarahModel.STATUS_COMPLETED:
        statusType = DonationStatusType.completed;
        break;
      case PermintaanDarahModel.STATUS_CANCELLED:
        statusType = DonationStatusType.rejected;
        break;
      default:
        statusType = DonationStatusType.pending;
    }
    
    donationStatus = DonationStatus(
      uniqueCode: permintaan.uniqueCode,
      filledBags: permintaan.bloodBagsFulfilled,
      status: statusType,
      remainingTime: statusType == DonationStatusType.countdown ? _parseexpiry_date(permintaan.partner_id) : null,
      onCancelRequest: () async {
        // Implementasi pembatalan permintaan
        final updatedPermintaan = permintaan.copyWith(
          status: PermintaanDarahModel.STATUS_CANCELLED,
        );
        
        bool success = await PermintaanDarahService.updatePermintaan(updatedPermintaan);
        
        if (success) {
          Navigator.pop(context); // Tutup halaman detail
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Permintaan berhasil dibatalkan"),
              backgroundColor: Colors.green,
            ),
          );
          
          // Refresh data permintaan
          _loadPermintaan();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal membatalkan permintaan"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
    
    // Navigasi ke halaman detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BloodDonationDetailScreen(
          patientData: patientData,
          donationStatus: donationStatus,
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
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }
  
  // Helper function to determine if a request is urgent
 
  
  // Helper function to get status text
  String _getStatusText(String statusCode) {
    switch (statusCode) {
      case PermintaanDarahModel.STATUS_PENDING:
        return 'Menunggu Konfirmasi';
      case PermintaanDarahModel.STATUS_WAITING:
        return 'Menunggu Donor';
      case PermintaanDarahModel.STATUS_ACCEPTED:
        return 'Dalam Proses';
      case PermintaanDarahModel.STATUS_COMPLETED:
        return 'Telah Selesai';
      case PermintaanDarahModel.STATUS_CANCELLED:
        return 'Dibatalkan';
      default:
        return statusCode;
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
  DateTime _parseexpiry_date(String partner_id) {
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