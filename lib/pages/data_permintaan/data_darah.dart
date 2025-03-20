import 'package:flutter/material.dart';
import 'jadwal_lokasi.dart';

class DataDarah extends StatefulWidget {
  final String nama;
  final String usia;
  final String nomorHP;

  DataDarah({required this.nama, required this.usia, required this.nomorHP});

  @override
  _DataDarahState createState() => _DataDarahState();
}

class _DataDarahState extends State<DataDarah> {
  String? selectedGolonganDarah;
  String? selectedRhesus;
  final TextEditingController jumlahKantongController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  @override
  void dispose() {
    jumlahKantongController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  Widget _dropdownField(String label, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              hint: Text("Pilih $label"),
              underline: SizedBox(),
              onChanged: onChanged,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
            ),
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
              backgroundColor: Color(0xFFE9B824),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
        SizedBox(width: 16),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF476EB6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JadwalLokasi(
                    nama: widget.nama,
                    usia: widget.usia,
                    nomorHP: widget.nomorHP,
                    golDarah: selectedGolonganDarah ?? "",
                    rhesus: selectedRhesus ?? "",
                    jumlahKantong: jumlahKantongController.text,
                    deskripsi: deskripsiController.text,
                  ),
                ),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(">", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                Text("Lanjut", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFAB4545),
        title: Text("Data Permintaan Darah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/alur_permintaan_2.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF2CC59),
                border: Border.all(color: Color(0xFF565656)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Isi dengan data diri anda saat ini",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            _dropdownField("Golongan Darah", selectedGolonganDarah, ["A", "B", "AB", "O"], (value) {
              setState(() {
                selectedGolonganDarah = value;
              });
            }),
            _dropdownField("Rhesus", selectedRhesus, ["Positif (+)", "Negatif (-)"], (value) {
              setState(() {
                selectedRhesus = value;
              });
            }),
            _inputField("Jumlah Kebutuhan Kantong", "Masukkan jumlah kantong", jumlahKantongController, suffixInside: "Kantong"),
            _inputField("Deskripsi Kebutuhan", "Masukkan deskripsi kebutuhan", deskripsiController, maxLines: 5),
            Spacer(),
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

Widget _inputField(String label, String hint, TextEditingController controller, {String? suffixInside, int maxLines = 1}) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            suffixIcon: suffixInside != null
                ? Padding(
                    padding: EdgeInsets.only(right: 15), // Padding tambahan ke kanan
                    child: Container(
                      alignment: Alignment.centerRight,
                      width: 65, // Lebar yang cukup untuk teks
                      child: Text(
                        suffixInside,
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}


}
