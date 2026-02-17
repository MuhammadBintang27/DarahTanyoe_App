import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:darahtanyoe_app/components/my_textfield.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/pages/authentication/verify_otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController(text: '');
  final TextEditingController _countryCodeController = TextEditingController(text: '+62');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _authService.loadingCallback = (isLoading) {
      setState(() {
        _isLoading = isLoading;
      });
    };

    _authService.errorCallback = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    };

    _authService.successCallback = () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerifyOtpPage()),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
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
            // Gunakan SingleChildScrollView untuk membuat seluruh layar scrollable
            SingleChildScrollView(
              // Tambahkan physics untuk kontrol scroll yang lebih baik
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Logo section
                      Expanded(
                        flex: 2,
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
                      // Form section
                      Container(
                        width: screenWidth,
                        // Jangan tetapkan height tetap
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.brand_01,
                              Color(0xFFCC8888),
                              Color(0xFFF8F0F0),
                            ],
                            stops: [0.3, 0.7, 1.0],
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
                        padding: EdgeInsets.fromLTRB(30, 40, 30, bottomInset > 0 ? bottomInset + 20 : 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'MASUK/DAFTAR',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 34),
                              Text(
                                'Nomor Handphone (WhatsApp)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.11),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white, width: 0.5),
                                    ),
                                    alignment: Alignment.center,
                                    child: TextFormField(
                                      controller: _countryCodeController,
                                      readOnly: true,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '+62',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.3),
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: MyTextField(
                                      hintText: '81237464785',
                                      keyboardType: TextInputType.phone,
                                      controller: _phoneController,
                                      inputType: InputType.text,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Nomor WhatsApp tidak boleh kosong';
                                        } else if (value.length < 10) {
                                          return 'Nomor WhatsApp tidak valid';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              MyButton(
                                text: _isLoading ? '' : 'Lanjut',
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // Sembunyikan keyboard sebelum menjalankan aksi
                                    FocusScope.of(context).unfocus();
                                    _authService.registrationData['phoneNumber'] =
                                    "+62${_phoneController.text}";
                                    _authService.sendOTP(
                                        _authService.registrationData['phoneNumber'],
                                        context);
                                  }
                                },
                                // onPressed: () {
                                //   // Default action jika tidak ada onPressed
                                //   Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(builder: (context) => VerifyOtpPage()),
                                //   );
                                // },
                              ),
                              const SizedBox(height: 20),
                              const CopyrightWidget(),
                              // Tambahkan padding tambahan saat keyboard muncul
                              SizedBox(height: bottomInset > 0 ? 20 : 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}