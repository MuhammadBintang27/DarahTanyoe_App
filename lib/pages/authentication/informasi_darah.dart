import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';

class InformasiDarah extends StatelessWidget {
  const InformasiDarah({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background pattern
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/batik_pattern.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content
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

              // Form Section
              Container(
                width: screenWidth,
                height: screenHeight * 0.7,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFCC5555), // Darker red at top
                      Color(0xFFCC8888), // Mid transition
                      Color(0xFFF8F0F0), // Light color at bottom
                    ],
                    stops: [0.3, 0.7, 1.0],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Center(
                          child: Text(
                            'DATA DIRI',
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
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 34),

                    _buildLabel('Golongan Darah'),
                    MyTextField(
                      hintText: 'Pilih golongan darah',
                      inputType: InputType.dropdown,
                      dropdownItems: ['A', 'B', 'AB', 'O'],
                    ),
                    
                    const SizedBox(height: 20),

                    _buildLabel('Rhesus'),
                    MyTextField(
                      hintText: 'Pilih Rhesus',
                      inputType: InputType.dropdown,
                      dropdownItems: ['+', '-'],
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Riwayat Donor Terakhir'),
                    MyTextField(
                      hintText: 'Pilih tanggal',
                      inputType: InputType.date,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Riwayat Penyakit'),
                    MyTextField(
                      hintText: 'Pilih Riwayat Penyakit',
                      inputType: InputType.dropdown,
                      dropdownItems: ['Tidak Ada', 'Diabetes', 'Hipertensi', 'Jantung', 'Hepatitis', 'Lainnya'],
                    ),

                    const SizedBox(height: 26),

                    MyButton(
                      text: "Lanjut",
                      onPressed: () {},
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
