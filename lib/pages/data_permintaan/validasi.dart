import 'package:flutter/material.dart';

class Validasi extends StatefulWidget {
  final String nama;
  final String usia;
  final String nomorHP;
  final String golDarah;
  final String rhesus;
  final String jumlahKantong;
  final String deskripsi;
  final String lokasi;
  final String tanggal;

  const Validasi({
    Key? key,
    required this.nama,
    required this.usia,
    required this.nomorHP,
    required this.golDarah,
    required this.rhesus,
    required this.jumlahKantong,
    required this.deskripsi,
    required this.lokasi,
    required this.tanggal,
  }) : super(key: key);

  @override
  _ValidasiState createState() => _ValidasiState();
}

class _ValidasiState extends State<Validasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFAB4545),
        title: const Text(
          "Data Permintaan Darah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/images/icon_notif.png',
              width: 60,  
              height: 60, 
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Image.asset(
              'assets/images/alur_permintaan_4.png',
              width: double.infinity,
              fit: BoxFit.contain,
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
    );
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
          _buildRow(
            _buildLabeledField("Golongan Darah", widget.golDarah),
            _buildLabeledField("Rhesus", widget.rhesus),
          ),
          _buildLabeledField("Jumlah Kebutuhan Kantong", widget.jumlahKantong),
          _buildLabeledField("Deskripsi Kebutuhan", widget.deskripsi, maxLines: 3),
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
        width: MediaQuery.of(context).size.width / 2.5,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE9B824),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          onPressed: () => Navigator.pop(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("<", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              Text("Kembali", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
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
        widget.rhesus.isEmpty ||
        widget.jumlahKantong.isEmpty ||
        widget.deskripsi.isEmpty ||
        widget.lokasi.isEmpty ||
        widget.tanggal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap lengkapi semua data!"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Menampilkan pop-up gambar
      _showPopup();
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // Menutup popup
              Navigator.pop(context); // Menutup dialog
            },
            child: Image.asset(
              'assets/images/popup_permintaan.png',
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}