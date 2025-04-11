import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/kembali_button.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

import '../../models/permintaan_darah_model.dart';
import '../../service/permintaan_darah_service.dart';
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart';

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
  });

  @override
  _ValidasiState createState() => _ValidasiState();
}

class _ValidasiState extends State<Validasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarWithLogo(
          title: 'Data Permintaan Darah',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: BackgroundWidget(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      top: 20), // Sesuaikan nilai sesuai kebutuhan
                  child: Image.asset(
                    'assets/images/alur_permintaan_4.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInfoCard(),
                const SizedBox(height: 20),
                _navigationButtons(context),
                SizedBox(height: 20),
                Text(
                  '© 2025 Beyond. Hak Cipta Dilindungi.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2), // Warna abu-abu
          width: 2, // Ketebalan border
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
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
          _buildLabeledField("Deskripsi Kebutuhan", widget.deskripsi,
              maxLines: 3),
          _buildRow(
            _buildLabeledField("Lokasi Pendonoran", widget.lokasi),
            _buildLabeledField("Jadwal Berakhir Permintaan", widget.tanggal),
          ),
        ],
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
      width: double.infinity, // Memastikan container memenuhi lebar parent
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE9B824).withOpacity(0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
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
          width: MediaQuery.of(context).size.width / 2.5, // Samakan ukuran
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
                  child: Text(">",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                Text("Kirim",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
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
        widget.deskripsi.isEmpty ||
        widget.idLokasi.isEmpty ||
        widget.lokasi.isEmpty ||
        widget.tanggal.isEmpty) {
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
      // Menampilkan dialog loading
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

      // Membuat model permintaan darah
      final String uniqueCode = PermintaanDarahService.generateUniqueCode();
      final DateTime now = DateTime.now();

      final permintaan = PermintaanDarahModel(
        patientName: widget.nama,
        patientAge: widget.usia,
        phoneNumber: widget.nomorHP,
        bloodType: widget.golDarah,
        bloodBagsNeeded: int.tryParse(widget.jumlahKantong) ?? 0,
        description: widget.deskripsi,
        partner_id: widget.idLokasi,
        expiry_date: widget.tanggal,
        uniqueCode: uniqueCode,
        bloodBagsFulfilled: 0,
        status: PermintaanDarahModel.STATUS_PENDING,
      );

      // Menyimpan permintaan
      PermintaanDarahService.simpanPermintaan(permintaan).then((success) {
        Navigator.pop(context); // Tutup dialog loading

        if (success) {
          // Tampilkan dialog sukses
          showCustomDialog(context, permintaan);
        } else {
          // Tampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Gagal menyimpan permintaan. Silakan coba lagi."),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  void showCustomDialog(BuildContext context, PermintaanDarahModel permintaan) {
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
                const SizedBox(height: 10),
                Text(
                  "Kode Permintaan: ${permintaan.uniqueCode}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pengajuan Anda sedang diproses. Mohon TUNGGU KONFIRMASI dari pihak RS/PMI terkait sebelum mendatangi idLokasi pendonoran.",
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
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
                  child: const Text("Lihat Daftar Permintaan",
                      style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    MyApp.mainScreenKey.currentState?.changeTab(0);
                  },
                  child: const Text("Kembali ke Beranda",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
