import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';
import '../../service/auth_service.dart';

class BloodInfo extends StatefulWidget {
  const BloodInfo({Key? key}) : super(key: key);

  @override
  _BloodInfoState createState() => _BloodInfoState();
}

class _BloodInfoState extends State<BloodInfo> {
  final AuthService _authService = AuthService();

  String? _selectedBloodType;
  String? _selectedLastDonation;
  String? _selectedMedical;

  void _submitBloodInfo() async {
    if (_selectedBloodType == null || _selectedLastDonation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap lengkapi semua data")),
      );
      return;
    }

    bool success = await _authService.saveBloodInfo(
      _selectedBloodType!,
      _selectedLastDonation!,
      _selectedMedical!,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Informasi darah berhasil disimpan!")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan informasi darah")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
              Container(
                width: screenWidth,
                height: screenHeight * 0.6,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFCC5555),
                      Color(0xFFCC8888),
                      Color(0xFFF8F0F0),
                    ],
                    stops: [0.3, 0.7, 1.0],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
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
                      dropdownItems: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
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
                      text: "Lanjut",
                      onPressed: _submitBloodInfo,
                      color: const Color(0xFF476EB6),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    CopyrightWidget(),
                  ],
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
