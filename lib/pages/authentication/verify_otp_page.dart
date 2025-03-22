import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/pages/authentication/personal_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../service/auth_service.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({Key? key}) : super(key: key);

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  int _countdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    _authService.loadingCallback = (isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    };

    _authService.errorCallback = (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, style: GoogleFonts.dmSans())),
      );
    };

    _authService.successCallback = () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PersonalInfo()),
      );
    };
  }

  void _startCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
            _startCountdown();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  void _resendOtp() {
    setState(() {
      _canResend = false;
      _countdown = 60;
    });
    _startCountdown();
    final phoneNumber = _authService.registrationData['phoneNumber'];
    _authService.sendOTP(phoneNumber);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Kode OTP telah dikirim ulang', style: GoogleFonts.dmSans())),
    );
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
                height: screenHeight * 0.4,
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
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'KODE OTP',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 34),
                    Text(
                      'Masukkan Kode yang dikirim via WhatsApp Anda',
                      style: GoogleFonts.dmSans(
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
                        controller: _otpController,
                        showCursor: true,
                        onCompleted: (pin) {
                          if (!_isLoading) {
                            _authService.verifyOTP(pin, _authService.registrationData['phoneNumber'], context);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 25),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Tidak mendapatkan OTP? ",
                          style: GoogleFonts.dmSans(color: Colors.white),
                          children: [
                            TextSpan(
                              text: _canResend
                                  ? "Kirim Ulang"
                                  : "Kirim ulang dalam $_countdown detik",
                              style: GoogleFonts.dmSans(
                                color: Color(0xFFAB4545),
                                fontWeight: FontWeight.bold,
                                decoration: _canResend
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                              recognizer: _canResend
                                  ? (TapGestureRecognizer()
                                    ..onTap = _resendOtp)
                                  : null,
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