import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/helpers/formatDateTime.dart';
import 'package:darahtanyoe_app/helpers/timeRemaining.dart';
import 'package:darahtanyoe_app/models/pendonoran_darah_model.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPendonoranDarah extends StatefulWidget {
  final PendonoranDarahModel pendonoran;

  const DetailPendonoranDarah({
    Key? key,
    required this.pendonoran,
  }) : super(key: key);

  @override
  State<DetailPendonoranDarah> createState() => _DetailPendonoranDarahState();
}

class _DetailPendonoranDarahState extends State<DetailPendonoranDarah> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Detail Permintaan Darah',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BackgroundWidget(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      )
                    ]
                ),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(20),
                  dashPattern: [16, 12],
                  color: AppTheme.neutral_01.withOpacity(0.26),
                  strokeWidth: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE1CCCC),
                          Colors.white70,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // tingginya mengikuti konten
                        children: [
                          Row(
                            children: [
                              _buildInfoCard(
                                title: 'Nama Pendonor',
                                value: widget.pendonoran.fullName,
                                expandedHeight: 65,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildInfoCard(
                                title: 'Nomor Handphone (WhatsApp)',
                                value: widget.pendonoran.phoneNumber,
                                expandedHeight: 65,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildInfoCard(
                                title: 'Golongan Darah',
                                value: widget.pendonoran.bloodRequest.bloodType,
                                expandedHeight: 65,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildInfoCard(
                                title: 'Riwayat Penyakit',
                                value: widget.pendonoran.healthNotes,
                                expandedHeight: 65,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildInfoCard(
                                title: 'Lokasi\nPendonoran',
                                value: widget.pendonoran.bloodRequest.partner.name,
                                expandedHeight: 100,
                              ),
                              const SizedBox(width: 10),
                              _buildInfoCard(
                                title: 'Pendonoran\nSebelum',
                                value: formatDateTime(widget.pendonoran.bloodRequest.expiryDate),
                                fontSize: 12,
                                expandedHeight: 100,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: IntrinsicHeight( // <--- Tambahkan ini
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // <--- Penting agar anak ikut tinggi
                    children: [
                      // Kolom kiri
                      Expanded(
                        child: DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(12),
                          dashPattern: [8, 4],
                          color: AppTheme.brand_04.withOpacity(0.4),
                          strokeWidth: 1.5,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFFCFD3DE),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Kode Unik",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                      fontFamily: 'DM Sans',
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    widget.pendonoran.uniqueCode,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'DM Sans',
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Kolom kanan
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final latitude = widget.pendonoran.bloodRequest.partner.latitude;
                            final longitude = widget.pendonoran.bloodRequest.partner.longitude;
                            final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
                            launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                          },
                          child: DottedBorder(
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(12),
                            dashPattern: [8, 4],
                            color: AppTheme.brand_04.withOpacity(0.4),
                            strokeWidth: 1.5,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCFD3DE),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: AppTheme.brand_04,
                                      size: 40,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          style: const TextStyle(
                                            fontFamily: 'DM Sans',
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                          children: const [
                                            TextSpan(text: 'Lihat lokasi pendonoran pada '),
                                            TextSpan(
                                              text: 'Google Maps',
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              widget.pendonoran.status == 'on_progress'
                  ? Text.rich(
                TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.brand_01,
                    fontFamily: 'DM Sans',
                  ),
                  children: const [
                    TextSpan(text: 'Akan ada '),
                    TextSpan(
                      text: 'pemeriksaan kesehatan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' di lokasi pendonoran, pastikan diri anda dalam '),
                    TextSpan(
                      text: 'kondisi fit dan siap donor!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ) : const SizedBox.shrink(),
              const SizedBox(height: 20),
              Divider(
                color: Colors.black26,
                thickness: 1,
              ),
              const SizedBox(height: 12),
              _footerByStatus(
                status: widget.pendonoran.status,
                expiryDate: widget.pendonoran.bloodRequest.expiryDate,
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '© 2025 Beyond. Hak Cipta Dilindungi.',
                  style: TextStyle(
                    color: AppTheme.neutral_01.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerByStatus({
    required String status,
    String? expiryDate
  }) {
    return Container(
      width: double.infinity,
        child: status == "on_progress" ?
        Column(
          children: [
            Text('SISA WAKTU SEBELUM PENDONORAN BERAKHIR',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.brand_01,
                // fontFamily: 'DM Sans',
              ),
            ),
            const SizedBox(height: 12),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(getTimeRemainingText(expiryDate ?? ""),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.brand_01,
                      // fontFamily: 'DM Sans',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        )
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.brand_01,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () async {
                          final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
                          final String donorId = widget.pendonoran.id; // pastikan ini sesuai struktur data kamu
                          final String url = "$baseUrl/donor/$donorId/status";
                          print(donorId);
                          print(url);

                          try {
                            final response = await http.patch(
                              Uri.parse(url),
                              headers: {
                                'Content-Type': 'application/json',
                              },
                              body: jsonEncode({'status': 'cancelled'}),
                            );

                            if (response.statusCode == 200) {
                              // Berhasil
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Donor berhasil dibatalkan')),
                              );
                              SharedPreferences.getInstance().then((prefs) {
                                prefs.setString('transaksiTab', "donor");
                                prefs.setInt('selectedIndex', 3);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => MainScreen()),
                                      (route) => false,
                                );
                              });
                            } else {
                              // Gagal
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal membatalkan donor: ${response.body}')),
                              );
                            }
                          } catch (e) {
                            // Error saat koneksi
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Terjadi kesalahan: $e')),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: const Text(
                            "Batalkan",
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                    ),
                  )
                ]
            ),
          ]
        ) : status == "cancelled" ?
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.cancel_rounded,
              color: AppTheme.brand_01,
              size: 40,
            ),
            const SizedBox(width: 8), // jarak antara ikon dan teks
            Expanded(
              child:
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'PENDONORAN DARAH DIBATALKAN, Jika berkenan lakukan ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.brand_01,
                      ),
                    ),
                    TextSpan(
                      text: 'Pendonoran Ulang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.brand_01,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.brand_01,
                        decorationStyle: TextDecorationStyle.solid,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setString('transaksiTab', "donor");
                            prefs.setInt('selectedIndex', 0);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen()),
                                  (route) => false,
                            );
                          });
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ) :
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.brand_03,
              size: 40,
            ),
            const SizedBox(width: 8), // jarak antara ikon dan teks
            Expanded(
              child: Text(
                'PENDONORAN DARAH SELESAI',
                style: TextStyle(
                  fontSize: 21.4,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.brand_03,
                ),
                overflow: TextOverflow.ellipsis, // bisa juga TextOverflow.fade
                softWrap: true,
                maxLines: 1, // batas 1 baris, bisa ubah sesuai kebutuhan
              ),
            ),
          ],
        )
    );
  }


  Widget _buildInfoCard({
    required String title,
    required String value,
    double? fontSize,
    required double expandedHeight,
  }) {
    return Expanded(
      child: Container(
        height: expandedHeight,
        decoration: BoxDecoration(
          color: AppTheme.brand_01.withOpacity(0.16),
          border: Border.all(color: AppTheme.brand_01.withOpacity(0.37)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ini juga penting
          children: [
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral_01,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: fontSize ?? 14,
                  color: AppTheme.neutral_01,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}