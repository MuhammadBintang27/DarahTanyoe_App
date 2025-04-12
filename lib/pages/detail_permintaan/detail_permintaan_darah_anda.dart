import 'package:darahtanyoe_app/components/allSvg.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/helpers/formatDateTime.dart';
import 'package:darahtanyoe_app/helpers/timeRemaining.dart';
import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailPermintaanDarah extends StatefulWidget {
  final PermintaanDarahModel permintaan;

  const DetailPermintaanDarah({
    Key? key,
    required this.permintaan,
  }) : super(key: key);

  @override
  State<DetailPermintaanDarah> createState() => _DetailPermintaanDarahState();
}

class _DetailPermintaanDarahState extends State<DetailPermintaanDarah> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Detail Permintaan Darah Anda',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BackgroundWidget(
        child: Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    child: IntrinsicHeight(
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
                                        widget.permintaan.uniqueCode.isNotEmpty ? widget.permintaan.uniqueCode : "BELUM ADA",
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
                              child: DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(12),
                                dashPattern: [8, 4],
                                color: AppTheme.neutral_01.withOpacity(0.4),
                                strokeWidth: 1.5,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5DADA),
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
                                        SvgPicture.string(bloodFilledDescSvg, width: 40, height: 40, color: AppTheme.brand_01),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              style: const TextStyle(
                                                fontFamily: 'DM Sans',
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                              children: [
                                                const TextSpan(text: 'Telah terisi '),
                                                TextSpan(
                                                  text: widget.permintaan.bloodBagsFulfilled.toString(),
                                                  style: const TextStyle(
                                                    color: AppTheme.brand_01,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(text: ' dari '),
                                                TextSpan(
                                                  text: '${widget.permintaan.bloodBagsNeeded} Kantong',
                                                  style: const TextStyle(
                                                    color: AppTheme.brand_01,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const TextSpan(text: ' yang Dibutuhkan'),
                                              ],
                                            ),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                        )
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
                  const SizedBox(height: 36),
                  Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          color: Colors.black26,
                          thickness: 1,
                          height: 1,
                        ),
                        SizedBox(height: 16),
                        _footerByStatus(
                          status: widget.permintaan.status,
                          expiryDate: widget.permintaan.expiry_date,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24, bottom: 0),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(20),
      dashPattern: [16, 12],
      color: AppTheme.neutral_01.withOpacity(0.26),
      strokeWidth: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ],
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEDE7D5),
              Colors.white70,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _buildRow(
              _buildLabeledField("Nama Pasien", widget.permintaan.patientName),
              _buildLabeledField("Usia Pasien", "${widget.permintaan.patientAge} Tahun"),
            ),
            _buildLabeledField("Nomor Handphone (WhatsApp)", widget.permintaan.phoneNumber),
            _buildLabeledField("Golongan Darah", widget.permintaan.bloodType),
            _buildLabeledField("Jumlah Kebutuhan Kantong", "${widget.permintaan.bloodBagsNeeded} Kantong"),
            _buildLabeledField("Deskripsi Kebutuhan", widget.permintaan.description, maxLines: 3),
            _buildRow(
              _buildLabeledField("Lokasi Pendonoran", widget.permintaan.partner_name),
              _buildLabeledField("Jadwal Berakhir Permintaan", formatDateTime(widget.permintaan.expiry_date)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledField(String label, String value, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 4),
          )
        ],
        color: const Color(0xFFEDE8D8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.brand_02.withOpacity(0.37),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.neutral_01,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            softWrap: true,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: AppTheme.neutral_01),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    );
  }

  Widget _footerByStatus({
    required String status,
    String? expiryDate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: status == "pending"
          ?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              "MENUNGGU KONFIRMASI RS/PMI TERKAIT",
              style: TextStyle(
                fontSize: 20, // Reduced from 26 to 20 for a smaller size
                fontWeight: FontWeight.bold,
                color: AppTheme.brand_02,
              ),
              softWrap: true, // Allows text to wrap to the next line
              overflow: TextOverflow.visible, // Ensures wrapping instead of clipping
            ),
          ),
          const SizedBox(width: 20),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
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
                final String requestId = widget.permintaan.id ?? '';
                final String url = "$baseUrl/bloodReq/status/$requestId";
                try {
                  final response = await http.patch(
                    Uri.parse(url),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'status': PermintaanDarahModel.STATUS_CANCELLED}),
                  );
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Permintaan berhasil dibatalkan')),
                    );
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('transaksiTab', "minta");
                      prefs.setInt('selectedIndex', 3);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                            (route) => false,
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membatalkan permintaan: ${response.body}')),
                    );
                  }
                } catch (e) {
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
              ),
            ),
          ),
        ],
      ) : status == "confirmed" ?
      Column(
          children: [
            Text(
              'SISA WAKTU SEBELUM PERMINTAAN BERAKHIR',
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
                          color: Colors.black.withOpacity(0.10),
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
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                      ),
                      onPressed: () async {
                        final String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
                        final String requestId = widget.permintaan.id ?? '';
                        final String url = "$baseUrl/bloodReq/status/$requestId";
                        try {
                          final response = await http.patch(
                            Uri.parse(url),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({'status': PermintaanDarahModel.STATUS_CANCELLED}),
                          );
                          if (response.statusCode == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Permintaan berhasil dibatalkan')),
                            );
                            SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('transaksiTab', "minta");
                              prefs.setInt('selectedIndex', 3);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => MainScreen()),
                                    (route) => false,
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Gagal membatalkan permintaan: ${response.body}')),
                            );
                          }
                        } catch (e) {
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
                      ),
                    ),
                  ),
                ]
            ),
          ]
      )
          : status == "cancelled"
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.cancel_rounded,
            color: AppTheme.brand_01,
            size: 40,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'PERMINTAAN DARAH DIBATALKAN, Jika berkenan buat ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: AppTheme.brand_01,
                    ),
                  ),
                  TextSpan(
                    text: 'Permintaan Ulang',
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
                          prefs.setString('transaksiTab', "minta");
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
      )
          : status == "ready" ?
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              "SILAHKAN DATANG KE LOKASI PENDONORAN",
              style: TextStyle(
                fontSize: 20, // Reduced from 26 to 20 for a smaller size
                fontWeight: FontWeight.bold,
                color: AppTheme.brand_04,
              ),
              softWrap: true, // Allows text to wrap to the next line
              overflow: TextOverflow.visible, // Ensures wrapping instead of clipping
            ),
          ),
          const SizedBox(width: 20),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
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
                final String requestId = widget.permintaan.id ?? '';
                final String url = "$baseUrl/bloodReq/status/$requestId";
                try {
                  final response = await http.patch(
                    Uri.parse(url),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({'status': PermintaanDarahModel.STATUS_CANCELLED}),
                  );
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Permintaan berhasil dibatalkan')),
                    );
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('transaksiTab', "minta");
                      prefs.setInt('selectedIndex', 3);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                            (route) => false,
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal membatalkan permintaan: ${response.body}')),
                    );
                  }
                } catch (e) {
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
              ),
            ),
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.brand_03,
            size: 40,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'PERMINTAAN DARAH SELESAI',
              style: TextStyle(
                fontSize: 21.4,
                fontWeight: FontWeight.bold,
                color: AppTheme.brand_03,
              ),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}