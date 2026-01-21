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
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    _authService.loadingCallback = (isLoading) {
      if (mounted) {
        setState(() {
          _isLoading = isLoading;
        });
      }
    };

    _authService.errorCallback = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    };

    _authService.successCallback = () {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddressPage()),
        );
      }
    };
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    super.dispose();
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
                    child: SingleChildScrollView(
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
                      _buildLabel('Tanggal Lahir'),
                      GestureDetector(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(Duration(days: 365 * 18)), // Default 18 tahun lalu
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().subtract(Duration(days: 365 * 17)), // Minimal 17 tahun
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _selectedDate = pickedDate;
                              _dateOfBirthController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: MyTextField(
                            hintText: 'Pilih Tanggal Lahir',
                            keyboardType: TextInputType.datetime,
                            inputType: InputType.text,
                            controller: _dateOfBirthController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Tanggal lahir tidak boleh kosong';
                              }
                              if (_selectedDate == null) {
                                return 'Pilih tanggal lahir yang valid';
                              }
                              final age = DateTime.now().year - _selectedDate!.year;
                              final monthDiff = DateTime.now().month - _selectedDate!.month;
                              final actualAge = monthDiff < 0 || (monthDiff == 0 && DateTime.now().day < _selectedDate!.day) ? age - 1 : age;
                              if (actualAge < 17 || actualAge > 65) {
                                return 'Usia harus antara 17-65 tahun berdasarkan tanggal lahir';
                              }
                              return null;
                            },
                          ),
                        ),
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
                                  _selectedDate!,
                                  _emailController.text,
                                  context);
                            }
                          },
                          color: const Color(0xFF476EB6)),
                      const SizedBox(height: 20),
                      CopyrightWidget(),
                        ],
                      ),
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
}
