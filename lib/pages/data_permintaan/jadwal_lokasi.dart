import 'package:flutter/material.dart';
import 'validasi.dart';

class JadwalLokasi extends StatefulWidget {
  final String nama;
  final String usia;
  final String nomorHP;
  final String golDarah;
  final String rhesus;
  final String jumlahKantong;
  final String deskripsi;

  JadwalLokasi({
    required this.nama,
    required this.usia,
    required this.nomorHP,
    required this.golDarah,
    required this.rhesus,
    required this.jumlahKantong,
    required this.deskripsi,
  });

  @override
  _JadwalLokasiState createState() => _JadwalLokasiState();
}

class _JadwalLokasiState extends State<JadwalLokasi> {
  final TextEditingController lokasiController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  @override
  void dispose() {
    lokasiController.dispose();
    tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFAB4545),
        title: Text(
          "Data Permintaan Darah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
              'assets/images/alur_permintaan_3.png',
              width: double.infinity,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 16), // Tambahkan padding kiri 16px
                      child: Text(
                        'Lokasi Pendonoran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Input Lokasi dalam Box Hitam Transparan dengan Ikon Search
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2), // Warna hitam dengan opacity 0.2
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: lokasiController,
                            decoration: InputDecoration(
                              hintText: "Cari RS / PMI",
                              hintStyle: TextStyle(color: Colors.white), // Warna hint agar lebih terlihat
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.white), // Warna teks input putih agar kontras
                          ),
                        ),
                        SizedBox(width: 8), // Spasi antara input dan ikon
                        CircleAvatar(
                          backgroundColor: Colors.red, // Warna ikon search
                          radius: 18,
                          child: Icon(Icons.search, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _datePickerField(),
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

  Widget _inputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }

Widget _datePickerField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Jadwal Berakhir Permintaan",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
      SizedBox(height: 4),
      GestureDetector(
        onTap: () async {
          // Memilih tanggal
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );

          // Memilih jam dan menit jika tanggal dipilih
          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: pickedDate.hour, minute: pickedDate.minute),
            );

            // Jika jam dan menit dipilih
            if (pickedTime != null) {
              setState(() {
                // Menyusun tanggal, jam, dan menit dalam format yang diinginkan
                tanggalController.text =
                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year} ${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
              });
            }
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tanggalController.text.isEmpty
                    ? "Jadwal Berakhir Permintaan"
                    : tanggalController.text,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
            ],
          ),
        ),
      ),
    ],
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
                  builder: (context) => Validasi(
                  nama: widget.nama,
                  usia: widget.usia,
                  nomorHP: widget.nomorHP,
                  golDarah: widget.golDarah,
                  rhesus: widget.rhesus,
                  lokasi: lokasiController.text,
                  tanggal: tanggalController.text,
                  jumlahKantong: widget.jumlahKantong,
                  deskripsi: widget.deskripsi,
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
}