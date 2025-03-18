import 'package:darahtanyoe_app/components/copyright.dart';
import 'package:darahtanyoe_app/components/my_button.dart';
import 'package:flutter/material.dart';
import '../../components/my_textfield.dart';

class DataDiri extends StatelessWidget {
  const DataDiri({Key? key}) : super(key: key);

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
                height: screenHeight * 0.6,
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

                    _buildLabel('Nama Lengkap'),
                    MyTextField(
                      hintText: 'Nama lengkap',
                      keyboardType: TextInputType.text,
                      inputType: InputType.text,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Usia'),
                    MyTextField(
                      hintText: 'Usia',
                      keyboardType: TextInputType.number,
                      inputType: InputType.text,
                    ),

                    const SizedBox(height: 20),

                    _buildLabel('Email'),
                    MyTextField(
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      inputType: InputType.text,
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
