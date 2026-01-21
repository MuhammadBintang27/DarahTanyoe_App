import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/allSvg.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/kembali_button.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'package:dotted_border/dotted_border.dart';

/// DEPRECATED: Fitur membuat permintaan darah dari donor sudah tidak ada di flow baru
/// Dalam sistem notification-driven, hanya PMI yang membuat campaign
/// Donor hanya merespons notifikasi yang diterima

class Validasi extends StatefulWidget {
  final String nama;
  final String usia;
  final String nomorHP;
  final String golDarah;
  final String jumlahKantong;
  final String deskripsi;
  final String lokasi;
  final String idLokasi;
  final String tanggal;
  final String tanggalDatabase;

  const Validasi({
    super.key,
    required this.nama,
    required this.usia,
    required this.nomorHP,
    required this.golDarah,
    required this.jumlahKantong,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggal,
    required this.idLokasi,
    required this.tanggalDatabase,
  });

  @override
  _ValidasiState createState() => _ValidasiState();
}

class _ValidasiState extends State<Validasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Data Permintaan Darah Anda',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BackgroundWidget(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Image.asset(
                          'assets/images/alur_permintaan_4.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(),
                      const SizedBox(height: 20),
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
                                            "BELUM ADA",
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
                                                      text: '0',
                                                      style: const TextStyle(
                                                        color: AppTheme.brand_01,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    const TextSpan(text: ' dari '),
                                                    TextSpan(
                                                      text: '${widget.jumlahKantong} Kantong',
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
                      SizedBox(height: 32),
                      Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child:  Column(
                            children: [
                              _navigationButtons(context),
                              SizedBox(height: 20,),
                              Text(
                                '© 2025 Beyond. Hak Cipta Dilindungi.',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                      ),
                    ],
                  ),
                ),

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
      dashPattern: [16, 12], // Dash length: 16, gap length: 12
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
              Color(0xFFEDE7D5), // Top color: EDE7D5
              Colors.white70,    // Bottom color: white70
            ],
          ),
          borderRadius: BorderRadius.circular(20), // Match the DottedBorder radius
        ),
        child: Column(
          children: [
            _buildRow(
              _buildLabeledField("Nama Pasien", widget.nama),
              _buildLabeledField("Usia Pasien", "${widget.usia} Tahun"),
            ),
            _buildLabeledField("Nomor Handphone (WhatsApp)", widget.nomorHP),
            _buildLabeledField("Golongan Darah", widget.golDarah),
            _buildLabeledField("Jumlah Kebutuhan Kantong", widget.jumlahKantong),
            _buildLabeledField("Deskripsi Kebutuhan", widget.deskripsi, maxLines: 3),
            _buildRow(
              _buildLabeledField("Lokasi Pendonoran", widget.lokasi),
              _buildLabeledField("Jadwal Berakhir Permintaan", widget.tanggal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
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
          color: AppTheme.brand_02.withOpacity(0.37), // Ganti dengan warna border yang kamu inginkan
          width: 1.0,          // Ganti dengan ketebalan border yang kamu inginkan
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
            style: const TextStyle(fontSize: 14, color: AppTheme.neutral_01),
          ),
        ],
      ),
    );
  }

  Widget _navigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: KembaliButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF476EB6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            onPressed: _validasiSebelumLanjut,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(">", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                Text("Kirim", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _validasiSebelumLanjut() {
    if (widget.nama.isEmpty ||
        widget.usia.isEmpty ||
        widget.nomorHP.isEmpty ||
        widget.golDarah.isEmpty ||
        widget.jumlahKantong.isEmpty ||
        widget.idLokasi.isEmpty ||
        widget.lokasi.isEmpty ||
        widget.tanggalDatabase.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Column(
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                const Text(
                  "Data Tidak Lengkap",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              "Harap lengkapi semua data sebelum melanjutkan!",
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  const Text("Menyimpan permintaan..."),
                ],
              ),
            ),
          );
        },
      );

      // DEPRECATED: Fitur membuat permintaan darah tidak ada di arsitektur baru
      // Dalam sistem notification-driven, hanya PMI yang membuat campaign
      // Flow baru: PMI creates campaign → Backend finds eligible donors → 
      //            Sends notifications → Donor confirms → Gets unique code
      
      Navigator.pop(context); // Close loading dialog
      showCustomDialog(context);
    }
  }

  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 10),
                const Text(
                  "Permintaan Anda Berhasil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                // const SizedBox(height: 10),
                // Text(
                //   "Kode Permintaan: ${permintaan.uniqueCode}",
                //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                //   textAlign: TextAlign.center,
                // ),
                const SizedBox(height: 10),
                const Text(
                  "Pengajuan Anda sedang diproses. Mohon TUNGGU KONFIRMASI dari pihak RS/PMI terkait sebelum mendatangi lokasi pendonoran.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('transaksiTab', "minta");
                      prefs.setInt('selectedIndex', 3);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                            (route) => false,
                      );
                    });
                  },
                  child: const Text("Lihat Daftar Permintaan", style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    MyApp.mainScreenKey.currentState?.changeTab(0);
                  },
                  child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}