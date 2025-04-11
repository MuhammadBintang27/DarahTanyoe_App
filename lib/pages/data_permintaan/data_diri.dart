import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/LanjutButton.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'jadwal_lokasi.dart';

class DataPemintaanDarah extends StatefulWidget {
  const DataPemintaanDarah({super.key});

  @override
  _DataPemintaanDarahState createState() => _DataPemintaanDarahState();
}

class _DataPemintaanDarahState extends State<DataPemintaanDarah> {
  // Controllers untuk semua input field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController jumlahKantongController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  // State untuk dropdown
  String? selectedTipeDarah;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    usiaController.dispose();
    phoneController.dispose();
    jumlahKantongController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  // Auto fill function from secure storage
  Future<void> _autoFillUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await AuthService().getCurrentUser();

      setState(() {
        // Fill data from user info
        nameController.text = user?['full_name'] ?? '';
        usiaController.text = user?['age']?.toString() ?? '';

        // Format phone number to remove +62 prefix if present
        String phoneNumber = user?['phone_number'] ?? '';
        if (phoneNumber.startsWith('62')) {
          phoneNumber = phoneNumber.substring(2); // Remove '62' prefix
        } else if (phoneNumber.startsWith('+62')) {
          phoneNumber = phoneNumber.substring(3); // Remove '+62' prefix
        }
        phoneController.text = phoneNumber;

        // Set blood type if available
        if (user?['blood_type'] != null) {
          selectedTipeDarah = user?['blood_type'];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pengguna: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _inputField(
      String label, String hint, TextEditingController controller,
      {String? suffixInside,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral_01),
          ),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white60,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutral_01.withOpacity(0.53), width: 0.5),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines,
              style: TextStyle(color: AppTheme.neutral_01),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppTheme.neutral_01.withOpacity(0.4)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                suffixIcon: suffixInside != null
                    ? Container(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    suffixInside,
                    style: TextStyle(color: AppTheme.neutral_02),
                  ),
                )
                    : null,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _phoneField() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nomor Handphone (WhatsApp)',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral_01),
          ),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white60,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutral_01.withOpacity(0.53), width: 0.5),
            ),
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: AppTheme.neutral_01),
              decoration: InputDecoration(
                hintText: 'Nomor Handphone (WhatsApp)',
                hintStyle: TextStyle(color: AppTheme.neutral_01.withOpacity(0.4)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                prefixIcon: Container(
                  alignment: Alignment.center,
                  width: 40,
                  child: Text('+62', style: TextStyle(color: AppTheme.neutral_02)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _dropdownField(String label, String? selectedValue,
      List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral_01),
          ),
          SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white60,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.neutral_01.withOpacity(0.53), width: 0.5),
            ),
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              hint: Text(
                "Pilih $label",
                style: TextStyle(
                  color: AppTheme.neutral_01.withOpacity(0.4),
                ),
              ),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: EdgeInsets.all(12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF2CC59),
          border: Border.all(color: Color(0xFF565656)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

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
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Semua form dalam ScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian Data Diri
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Image.asset(
                          'assets/images/alur_permintaan_1.png',
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Auto-fill button
                      Container(
                        width: double.infinity,
                        height: 48,
                        margin: EdgeInsets.only(top: 10, bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.brand_02,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: isLoading ? null : _autoFillUserData,
                            borderRadius: BorderRadius.circular(20),
                            child: Center(
                              child: isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'Isi dengan data anda saat ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      _inputField("Nama Lengkap Pasien", "Nama Lengkap Pasien", nameController),
                      _inputField(
                          "Usia Pasien",
                          "Usia Pasien",
                          usiaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          suffixInside: "Tahun"),
                      _phoneField(),

                      // Bagian Data Darah
                      _dropdownField("Golongan Darah", selectedTipeDarah,
                          ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"], (value) {
                            setState(() {
                              selectedTipeDarah = value;
                            });
                          }),
                      _inputField(
                        "Jumlah Kebutuhan Kantong",
                        "Masukkan jumlah kantong",
                        jumlahKantongController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        suffixInside: "Kantong",
                      ),
                      _inputField("Deskripsi Kebutuhan", "Masukkan deskripsi kebutuhan",
                          deskripsiController,
                          maxLines: 5, keyboardType: TextInputType.text),
                    ],
                  ),
                ),
              ),

              // Button navigation section & footer
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: LanjutButton(
                  onPressed: () {
                    // Validasi semua data sebelum lanjut
                    if (nameController.text.isEmpty ||
                        usiaController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        selectedTipeDarah == null ||
                        jumlahKantongController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mohon lengkapi semua data yang diperlukan')),
                      );
                      return;
                    }
                    print('Nama: ${nameController.text}, Usia: ${usiaController.text}, No HP: 62${phoneController.text}, '
                        'Tipe Darah: $selectedTipeDarah, Jumlah Kantong: ${jumlahKantongController.text}, '
                        'Deskripsi: ${deskripsiController.text}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JadwalLokasi(
                          nama: nameController.text,
                          usia: usiaController.text,
                          nomorHP: "62${phoneController.text}",
                          golDarah: selectedTipeDarah ?? "",
                          jumlahKantong: jumlahKantongController.text,
                          deskripsi: deskripsiController.text,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                '© 2025 Beyond. Hak Cipta Dilindungi.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}