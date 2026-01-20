import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';
import '../../service/auth_service.dart';

class BloodInfo extends StatefulWidget {
  const BloodInfo({super.key});

  @override
  _BloodInfoState createState() => _BloodInfoState();
}

class _BloodInfoState extends State<BloodInfo> {
  final AuthService _authService = AuthService();

  String? _selectedBloodType;
  String? _selectedLastDonation;
  String? _selectedMedical;

  void _submitBloodInfo() async {
    if (_selectedBloodType == null || _selectedLastDonation == null || _selectedMedical == null) {
      if (!mounted) return; // Cegah akses ke context jika sudah tidak valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
      return;
    }

    try {
      bool success = await _authService.saveBloodInfo(
          _selectedBloodType!,
          _selectedLastDonation!,
          _selectedMedical!,
          context
      );

      if (success) {
        // Navigasi sudah ditangani di auth_service.dart
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menyimpan informasi darah")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: ${e.toString()}")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/batik_pattern.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assets/images/darah_tanyoe_logo.png',
                        width: 300,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.brand_01,
                        Color(0xFFCC8888),
                        Color(0xFFF8F0F0),
                      ],
                      stops: [0.2, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: Offset(0, -8),
                      ),
                    ],
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: Text(
                                'Informasi Darah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 34),
                        _buildLabel('Golongan Darah'),
                        MyTextField(
                          hintText: 'Pilih golongan darah',
                          inputType: InputType.dropdown,
                          dropdownItems: [
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'AB+',
                            'AB-',
                            'O+',
                            'O-'
                          ],
                          onChanged: (value) => _selectedBloodType = value,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Riwayat Donor Terakhir'),
                        MyTextField(
                          hintText: 'Pilih tanggal',
                          inputType: InputType.date,
                          onChanged: (value) => _selectedLastDonation = value,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel('Riwayat Penyakit'),
                        MyTextField(
                          hintText: 'Pilih Riwayat Penyakit',
                          inputType: InputType.dropdown,
                          dropdownItems: [
                            'Tidak Ada',
                            'Diabetes',
                            'Hipertensi',
                            'Jantung',
                            'Hepatitis',
                            'HIV'
                          ],
                          onChanged: (value) => _selectedMedical = value,
                        ),
                        const SizedBox(height: 26),
                        MyButton(
                          text: "Daftar",
                          onPressed: () {
                            if (_selectedBloodType == null ||
                                _selectedBloodType!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text("Golongan darah tidak boleh kosong")),
                              );
                              return;
                            }
                            if (_selectedLastDonation == null ||
                                _selectedLastDonation!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                    Text("Riwayat donor tidak boleh kosong")),
                              );
                              return;
                            }
                            if (_selectedMedical == null ||
                                _selectedMedical!.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Riwayat penyakit tidak boleh kosong")),
                              );
                              return;
                            }

                            _submitBloodInfo();
                          },
                          color: const Color(0xFF476EB6),
                        ),
                        const SizedBox(height: 20),
                        CopyrightWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}