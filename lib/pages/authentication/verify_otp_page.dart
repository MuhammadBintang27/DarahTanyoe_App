import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class VerifyOtpPage extends StatelessWidget {
  const VerifyOtpPage({Key? key}) : super(key: key);

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
                height: screenHeight * 0.4,
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
                        'KODE OTP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    const Text(
                      'Masukkan Kode yang dikirim via WhatsApp anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Pinput(
                        length: 6,
                        showCursor: true,
                        onCompleted: (pin) => print("Entered OTP: $pin"),
                      ),
                    ),
                    SizedBox(height: 25),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Tidak mendapatkan OTP? ",
                          style: TextStyle(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "Kirim Ulang",
                              style: TextStyle(
                                color: Color(0xFFAB4545),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print("Kirim Ulang ditekan");
                                },
                            ),
                          ],
                        ),
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
