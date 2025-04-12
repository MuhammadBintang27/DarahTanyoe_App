import 'package:darahtanyoe_app/pages/authentication/address_page.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import '../../components/my_textfield.dart';
import '../../service/auth_service.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    };

    _authService.successCallback = () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddressPage()),
      );
    };
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
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
              Container(
                width: screenWidth,
                height: screenHeight * 0.6,
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
                      color: Colors.black26, // Warna shadow
                      blurRadius: 10, // Efek blur
                      spreadRadius: 3, // Seberapa jauh shadow menyebar
                      offset: Offset(0, -8), // Menggeser shadow ke atas
                    ),
                  ],
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Center(
                            child: Text(
                              'DATA DIRI',
                              style: GoogleFonts.dmSans(
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
                      _buildLabel('Nama Lengkap'),
                      MyTextField(
                        hintText: 'Nama Lengkap',
                        keyboardType: TextInputType.text,
                        inputType: InputType.text,
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Usia'),
                      MyTextField(
                        hintText: 'Usia',
                        keyboardType: TextInputType.number,
                        inputType: InputType.text,
                        controller: _ageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Usia tidak boleh kosong';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age < 17 || age > 120) {
                            return 'Usia harus antara 17-120 tahun';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildLabel('Email'),
                      MyTextField(
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        inputType: InputType.text,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 26),
                      MyButton(
                          text: _isLoading ? "Memproses..." : "Lanjut",
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              await _authService.savePersonalInfo(
                                  _nameController.text,
                                  int.parse(_ageController.text),
                                  _emailController.text,
                                  context);
                            }
                          },
                          color: const Color(0xFF476EB6)),
                      const SizedBox(height: 20),
                      const Spacer(),
                      CopyrightWidget(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
