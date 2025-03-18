import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:flutter/material.dart';

import '../../components/my_textfield.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
                height: screenHeight * 0.55,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFCC5555), // Darker red at top
                      Color(0xFFCC8888), // Mid transition
                      Color(0xFFF8F0F0), // Light color at bottom
                    ],
                    stops: [
                      0.3,
                      0.7,
                      1.0
                    ], // Adjust these values to move the red lower
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
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'MASUK/DAFTAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),

                    const Text(
                      'Nomor Handphone (WhatsApp)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone Input Field
                    MyTextField(
                      hintText: 'Nomor Handphone (WhatsApp)',
                      initialValue: '+62 ',
                      keyboardType: TextInputType.phone,
                      inputType: InputType.text,
                    ),

                    const SizedBox(height: 20),

                    // Continue Button
                    MyButton(
                      text: "Lanjut",
                      onPressed: () {
                        // Aksi tombol
                      },
                      color: Color(
                          0xFF476EB6), // Warna bisa diubah, misalnya merah
                    ),

                    const SizedBox(height: 20),

                    // Divider with text
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.white38)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Masuk/Daftar lebih cepat dengan',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.white38)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Google sign in button
                    Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(0xFFD6E4FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Google_logo.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Google',
                            style: TextStyle(
                              color: Color(0xFF476EB6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
}
