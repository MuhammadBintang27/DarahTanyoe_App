import 'dart:convert';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/bloodCard.dart';
import 'package:darahtanyoe_app/components/loadingIndicator.dart';
import 'package:darahtanyoe_app/helpers/formatDateTime.dart';
import 'package:darahtanyoe_app/pages/detail_permintaan/detail_permintaan_darah.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/permintaan_darah_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransactionBlood extends StatefulWidget {
  final String? defaultTab;
  final String? uniqueCode;

  const TransactionBlood({super.key, this.uniqueCode, this.defaultTab});

  @override
  State<TransactionBlood> createState() => _TransactionBloodState();
}

class _TransactionBloodState extends State<TransactionBlood> {
  // Track which tab is selected
  bool isRequestTab = true; // Default to request tab
  bool isLoading = false;

  // Lists for storing actual data from the service
  List<PermintaanDarahModel> permintaanList = [];

  @override
  void initState() {
    super.initState();
    _loadDefaultTab();
  }

  Future<void> _loadDefaultTab() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTab = prefs.getString('transaksiTab') ?? widget.defaultTab;
    final savedTab = (rawTab == null || rawTab.trim().isEmpty) ? "minta" : rawTab;


    setState(() {
      isRequestTab = savedTab == "minta";
    });

    if (isRequestTab) {
      _loadPermintaan();
    } else {
      _loadPendonoran();
    }
  }


  static Future<List<PermintaanDarahModel>> fetchPermintaanData(String userId) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

    final url = Uri.parse('$baseUrl/bloodReq/$userId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> jsonData = jsonResponse['data'];
        return jsonData
            .map((item) => PermintaanDarahModel.fromJson(item))
            .toList();
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> _loadPermintaan() async {
    setState(() => isLoading = true);

    try {
      final user = await AuthService().getCurrentUser();

      if (user?['id'] == null) {
        _showError("Anda belum login atau pengguna tidak ditemukan.");
        setState(() => isLoading = false);
        return;
      }

      final userId = user!['id'] as String;
      final data = await fetchPermintaanData(userId);

      if (!mounted) return;

      setState(() {
        permintaanList = data;
        isLoading = false;
      });

      // Scroll ke permintaan berdasarkan kode unik jika tersedia
      if (widget.uniqueCode != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _highlightRequest(widget.uniqueCode!);
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showError("Gagal memuat data permintaan: $e");
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }


  Future<void> _loadPendonoran() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();
      if (user?['id'] == null) {
        _showError("Anda belum login atau pengguna tidak ditemukan.");
        setState(() => isLoading = false);
        return;
      }

      // DEPRECATED: Donor history feature no longer available
      // Will be replaced with DonorConfirmationService in future update
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Fitur sedang diperbarui: $e"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _highlightRequest(String uniqueCode) {
    // DEPRECATED: uniqueCode feature removed from new schema
    // In new architecture: DonorConfirmationModel tracks confirmation status instead
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundWidget(
          child: Column(
            children: [
              HeaderWidget(),
              Expanded(
                child: _buildTransactionBody(),
              ),
            ],
          ),
        ),
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral_01,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
              child: Divider(color: Colors.black26, thickness: 0.8),
            ),

            // Toggle buttons for switching between request and donation
            Container(
              margin: const EdgeInsets.only(bottom: 14.0),
              padding: const EdgeInsets.symmetric(horizontal: 2.6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87.withValues(alpha: 0.25),
                    blurRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isRequestTab = true;
                          _loadPermintaan();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        backgroundColor: isRequestTab
                            ? AppTheme.brand_01
                            : Colors.transparent,
                        foregroundColor: isRequestTab
                            ? Colors.white
                            : Colors.black.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(9),
                            right: Radius.circular(9),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Permintaan Darah',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isRequestTab = false;
                          _loadPendonoran();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        backgroundColor: !isRequestTab
                            ? AppTheme.brand_01
                            : Colors.transparent,
                        foregroundColor: !isRequestTab
                            ? Colors.white
                            : Colors.black.withValues(alpha: 0.5),
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(9),
                            right: Radius.circular(9),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Pendonoran Darah',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
    if (isLoading) {
      return const LoadingIndicator();
    }
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ...permintaanList.map((permintaan) {
            String formattedDate = formatDateTime(permintaan.endDate.toIso8601String());

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: BloodCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPermintaanDarah(permintaan: permintaan),
                    ),
                  );
                },
                status: permintaan.status,
                bloodType: permintaan.bloodType ?? '-',
                date: formattedDate,
                hospital: permintaan.organiser?.institutionName ?? 'N/A',
                createdAt: formatDateTime(permintaan.createdAt.toIso8601String()),
                bagCount: permintaan.currentQuantity,
                totalBags: permintaan.relatedBloodRequest?.quantity ?? 0,
                isRequest: true,
                uniqueCode: permintaan.id,
                description: (permintaan.description?.isNotEmpty == true)
                    ? permintaan.description ?? '-'
                    : '-',
              ),
            );
          }).toList(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildDonationContent() {
    // DEPRECATED: Donation history feature uses old PendonoranDarahModel which no longer exists
    // In new architecture: notifications → donor confirms → DonorConfirmationModel tracks status
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Belum ada pendonoran darah",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              "Fitur riwayat pendonaran sedang diperbarui",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBloodCard({
  //   required String status,
  //   required String bloodType,
  //   required String date,
  //   required String hospital,
  //   String distance = "",
  //   required int bagCount,
  //   required int totalBags,
  //   required bool isRequest,
  //   required String uniqueCode,
  //   PermintaanDarahModel? permintaan,
  //   PendonoranDarahModel? pendonoran,
  //   required String description,
  // }) {
  //   // Warna berdasarkan status
  //   Color statusColor;
  //   Color titleColor;
  //   Color borderColor;
  //   Color backgroundColor;
  //   String statusText;
  //
  //   if (status == "cancelled") {
  //     statusColor = Color(0xFFAB4545);
  //     titleColor = Color(0xFFAB4545);
  //     borderColor = Color(0xFFAB4545);
  //     backgroundColor = Color(0xFFEAE2E2);
  //     statusText = isRequest ? "Permintaan Darah Dibatalkan" : "Pendonoran Dibatalkan";
  //   } else if (status == "completed") {
  //     statusColor = Color(0xFF359B5E);
  //     titleColor = Color(0xFF359B5E);
  //     borderColor = Color(0xFF359B5E);
  //     backgroundColor = Color(0xFFDBE6DF);
  //     statusText = isRequest ? "Permintaan Darah Selesai" : "Pendonoran Selesai";
  //   } else {
  //     // Menggunakan warna kuning sesuai dengan gambar
  //     statusColor = Color(0xFFCB9B0A);
  //     titleColor = Color(0xFFCB9B0A);
  //     borderColor = AppTheme.brand_02;
  //     backgroundColor = Color(0xFFF1EEE5);
  //
  //     if (isRequest) {
  //       status == "pending"
  //           ? statusText = "Menunggu Konfirmasi RS/PMI"
  //           : status == "confirmed"
  //           ? statusText = "Menunggu Kantong Darah Terpenuhi"
  //           : statusText = "Kantong Darah Terpenuhi";
  //     } else {
  //       statusText = "Menunggu Proses Donor";
  //     }
  //   }
  //
  //   return GestureDetector(
  //     onTap: () {
  //       if (isRequest && permintaan != null) {
  //         print("detail permintaan");
  //         // _navigateToDetailScreen(permintaan);
  //       } else if (!isRequest && pendonoran != null) {
  //         print("Klik detail donor");
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => DetailPendonoranDarah(pendonoran: pendonoran),
  //           ),
  //         );
  //       }
  //     },
  //     child: Stack(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.only(top: 12, bottom: 12, left: 14, right: 14),
  //           decoration: BoxDecoration(
  //             color: backgroundColor,
  //             borderRadius: BorderRadius.circular(20),
  //             border: Border.all(color: borderColor, width: 1.5),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: Colors.black.withOpacity(0.25),
  //                 blurRadius: 4,
  //                 offset: Offset(0, 4),
  //               ),
  //             ],
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.all(0),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Header with title and deadline
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Text(
  //                       isRequest ? 'Permintaan Darah Anda' : 'Pendonoran Darah Anda',
  //                       style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w600,
  //                         color: titleColor,
  //                       ),
  //                     ),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           isRequest ? 'Permintaan Berakhir' : 'Donor Sebelum',
  //                           style: TextStyle(
  //                             fontSize: 10,
  //                             fontWeight: FontWeight.w600,
  //                             color: titleColor,
  //                           ),
  //                         ),
  //                         Text(
  //                           date,
  //                           style: TextStyle(
  //                             fontSize: 10,
  //                             fontWeight: FontWeight.w500,
  //                             color: titleColor,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 0, top: 2),
  //                   child: Divider(
  //                     color: Color(0xFFA3A3A3).withOpacity(0.4),
  //                     thickness: 1,
  //                     height: 24,
  //                   ),
  //                 ),
  //
  //                 // Using LayoutGrid for the middle section
  //                 LayoutGrid(
  //                   columnSizes: [1.fr, 1.fr],
  //                   rowSizes: [auto, auto, auto],
  //                   rowGap: 8,
  //                   children: [
  //                     // Hospital section (top-left)
  //                     Row(
  //                       children: [
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             color: Colors.transparent,
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: SvgPicture.string(
  //                             hospitalSvg,
  //                             width: 24,
  //                             height: 24,
  //                           ),
  //                         ),
  //                         SizedBox(width: 8),
  //                         Expanded(
  //                           child: Text(
  //                             hospital,
  //                             style: TextStyle(
  //                               fontSize: 13,
  //                               fontWeight: FontWeight.bold,
  //                               color: AppTheme.neutral_01,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ).withGridPlacement(
  //                       columnStart: 0,
  //                       columnSpan: 1,
  //                       rowStart: 0,
  //                       rowSpan: 1,
  //                     ),
  //
  //                     // Blood type section (top-right)
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             color: Colors.transparent,
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: SvgPicture.string(
  //                             bloodTypeSvg,
  //                             width: 24,
  //                             height: 24,
  //                           ),
  //                         ),
  //                         SizedBox(width: 8),
  //                         Text(
  //                           bloodType,
  //                           style: TextStyle(
  //                             fontSize: 22,
  //                             fontWeight: FontWeight.bold,
  //                             color: titleColor,
  //                           ),
  //                         ),
  //                       ],
  //                     ).withGridPlacement(
  //                       columnStart: 1,
  //                       columnSpan: 1,
  //                       rowStart: 0,
  //                       rowSpan: 1,
  //                     ),
  //
  //                     // Description section
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: SvgPicture.string(
  //                             descriptionSvg,
  //                             width: 24,
  //                             height: 24,
  //                           ),
  //                         ),
  //                         SizedBox(width: 8),
  //                         Expanded(
  //                           child: Text(
  //                             description,
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               color: AppTheme.neutral_01,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ).withGridPlacement(
  //                       columnStart: 0,
  //                       columnSpan: 1,
  //                       rowStart: 1,
  //                       rowSpan: 1,
  //                     ),
  //
  //                     // Progress indicator
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           child: SvgPicture.string(
  //                             bloodFilledDescSvg,
  //                             width: 24,
  //                             height: 24,
  //                           ),
  //                         ),
  //                         SizedBox(width: 8),
  //                         RichText(
  //                           text: TextSpan(
  //                             style: TextStyle(
  //                               fontSize: 11,
  //                               color: AppTheme.neutral_01,
  //                               fontFamily: 'DM Sans',
  //                             ),
  //                             children: [
  //                               TextSpan(text: 'Telah terisi '),
  //                               TextSpan(
  //                                 text: '$bagCount',
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: titleColor,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                               TextSpan(text: ' dari '),
  //                               TextSpan(
  //                                 text: '$totalBags',
  //                                 style: TextStyle(
  //                                   fontWeight: FontWeight.bold,
  //                                   color: titleColor,
  //                                   fontSize: 11,
  //                                 ),
  //                               ),
  //                               TextSpan(text: '\nKantong'),
  //                               TextSpan(
  //                                 text: ' yang dibutuhkan',
  //                                 style: TextStyle(
  //                                   color: Colors.grey[600],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ).withGridPlacement(
  //                       columnStart: 1,
  //                       columnSpan: 1,
  //                       rowStart: 1,
  //                       rowSpan: 1,
  //                     ),
  //                   ],
  //                 ),
  //
  //                 SizedBox(height: 10),
  //
  //                 // Status indicator
  //                 Row(
  //                   children: [
  //                     Container(
  //                       height: 16,
  //                       width: 16,
  //                       decoration: BoxDecoration(
  //                         color: statusColor,
  //                         shape: BoxShape.circle,
  //                       ),
  //                     ),
  //                     SizedBox(width: 8),
  //                     Text(
  //                       statusText,
  //                       style: TextStyle(
  //                         color: statusColor,
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 12,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //
  //         // Positioned arrow
  //         Positioned(
  //           right: 12,
  //           top: 0,
  //           bottom: 0,
  //           child: Center(
  //             child: Icon(
  //               Icons.arrow_forward_ios,
  //               color: Colors.grey[400],
  //               size: 16,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Helper function untuk navigasi ke halaman detail
  // void _navigateToDetailScreen(PermintaanDarahModel permintaan) {
  //   // Konversi dari PermintaanDarahModel ke PatientDonationData
  //   final patientData = PatientDonationData(
  //     patientName: permintaan.patientName,
  //     patientAge: int.tryParse(permintaan.patientAge) ?? 0,
  //     phoneNumber: permintaan.phoneNumber,
  //     bloodType: permintaan.bloodType,
  //     bloodBagsNeeded: permintaan.bloodBagsNeeded,
  //     description: permintaan.description,
  //     partner_id: permintaan.partner_id,
  //     expiry_date: permintaan.expiry_date,
  //   );
  //
  //   // Tentukan status berdasarkan status permintaan
  //   DonationStatus donationStatus;
  //   DonationStatusType statusType;
  //
  //   switch (permintaan.status) {
  //     case PermintaanDarahModel.STATUS_PENDING:
  //       statusType = DonationStatusType.pending;
  //       break;
  //     case PermintaanDarahModel.STATUS_CONFIRMED:
  //       statusType = DonationStatusType.countdown;
  //       break;
  //     case PermintaanDarahModel.STATUS_COMPLETED:
  //       statusType = DonationStatusType.completed;
  //       break;
  //     case PermintaanDarahModel.STATUS_CANCELLED:
  //       statusType = DonationStatusType.rejected;
  //       break;
  //     default:
  //       statusType = DonationStatusType.pending;
  //   }
  //
  //   donationStatus = DonationStatus(
  //     uniqueCode: permintaan.uniqueCode,
  //     filledBags: permintaan.bloodBagsFulfilled,
  //     status: statusType,
  //     remainingTime: statusType == DonationStatusType.countdown
  //         ? _parseexpiry_date(permintaan.expiry_date)
  //         : null,
  //     onCancelRequest: () async {
  //       // Implementasi pembatalan permintaan
  //       final updatedPermintaan = permintaan.copyWith(
  //         status: PermintaanDarahModel.STATUS_CANCELLED,
  //       );
  //
  //       bool success =
  //       await PermintaanDarahService.updatePermintaan(updatedPermintaan);
  //
  //       if (success) {
  //         MainScreen.navigateToTab(context, 3); // Tutup halaman detail
  //
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Permintaan berhasil dibatalkan"),
  //             backgroundColor: Colors.green,
  //           ),
  //         );
  //
  //         // Refresh data permintaan
  //         _loadPermintaan();
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text("Gagal membatalkan permintaan"),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     },
  //   );
  //
  //   // Navigasi ke halaman detail
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => BloodDonationDetailScreen(
  //         patientData: patientData,
  //         donationStatus: donationStatus,
  //       ),
  //     ),
  //   );
  // }

  // Helper function to calculate distance (dummy implementation)
  // String _calculateDistance(String location) {
  //   // Ini hanya implementasi dummy
  //   // Di aplikasi nyata, gunakan geolokasi untuk menghitung jarak sesungguhnya
  //   double randomDistance = (2 + (location.length % 8)) / 10.0 * 10;
  //   return '${randomDistance.toStringAsFixed(1)} km dari lokasi Anda';
  // }
  //
  // // Helper function untuk parse expiry_date
  // DateTime _parseexpiry_date(String partnerId) {
  //   try {
  //     if (partnerId.contains('-')) {
  //       // Format: DD-MM-YYYY HH:MM
  //       List<String> parts = partnerId.split(' ');
  //       List<String> dateParts = parts[0].split('-');
  //       List<String> timeParts =
  //       parts.length > 1 ? parts[1].split(':') : ['00', '00'];
  //
  //       return DateTime(
  //         int.parse(dateParts[2]),
  //         int.parse(dateParts[1]),
  //         int.parse(dateParts[0]),
  //         int.parse(timeParts[0]),
  //         int.parse(timeParts[1]),
  //       );
  //     } else {
  //       // Coba parse sebagai ISO string
  //       return DateTime.parse(partnerId);
  //     }
  //   } catch (e) {
  //     print('Error parsing expiry_date: $e');
  //     // Kembalikan waktu default jika parsing gagal
  //     return DateTime.now().add(const Duration(days: 1));
  //   }
  // }
}
