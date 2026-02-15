import 'dart:convert';
import 'dart:math';
import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/my_textfield.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:darahtanyoe_app/pages/donor_darah/donor_confirmation_success.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/service/toast_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataPendonoranDarah extends StatefulWidget {
  final String? confirmationId;    // From notification
  final String campaignId;         // Campaign ID
  final String golonganDarah;

  const DataPendonoranDarah({
    Key? key,
    this.confirmationId,
    required this.campaignId,
    required this.golonganDarah,
  }) : super(key: key);

  @override
  State<DataPendonoranDarah> createState() => _DataPendonoranDarahState();
}

class _DataPendonoranDarahState extends State<DataPendonoranDarah> {
  final _formKey = GlobalKey<FormState>();
  final _storage = FlutterSecureStorage();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+62');
  final TextEditingController _bloodTypeController = TextEditingController();

  String? _selectedRiwayatPenyakit;

  final List<String> _riwayatPenyakitOptions = [
    'Tidak ada',
    'Diabetes',
    'Hipertensi',
    'Penyakit Jantung',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _bloodTypeController.text = widget.golonganDarah;
    _autoFillUserData(); // ✅ Auto-fill data on page load
  }

  Future<void> _autoFillUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userDataString = await _storage.read(key: 'userData');
      
      if (userDataString == null) {
        ToastService.showError(context, message: 'Data pengguna tidak ditemukan. Silakan login kembali.');
        return;
      }

      final userData = jsonDecode(userDataString);
      
      setState(() {
        _nameController.text = userData['full_name'] ?? '';
        
        String phoneNumber = userData['phone_number'] ?? '';
        if (phoneNumber.startsWith('62')) {
          phoneNumber = phoneNumber.substring(2);
        } else if (phoneNumber.startsWith('+62')) {
          phoneNumber = phoneNumber.substring(3);
        }
        _phoneController.text = phoneNumber;
        
        String? healthNotes = userData['health_notes'];
        
        if (healthNotes != null && _riwayatPenyakitOptions.contains(healthNotes)) {
          _selectedRiwayatPenyakit = healthNotes;
        } else {
          _selectedRiwayatPenyakit = 'Lainnya'; // Fallback if health_notes doesn't match options
        }
      });
    } catch (e) {
      ToastService.showError(context, message: 'Gagal memuat data pengguna: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userDataString = await _storage.read(key: 'userData');
      
      if (userDataString == null) {
        setState(() {
          _isLoading = false;
        });
        ToastService.showError(context, message: 'User belum login');
        return;
      }

      final userData = jsonDecode(userDataString);
      final donorId = userData['id'];

      try {
        // ✅ Call correct endpoint: /fulfillment/donor/confirm
        final requestBody = {
          'donor_id': donorId,  // ✅ ALWAYS send donor_id
        };

        // Add confirmation_id jika ada (dari notification)
        if (widget.confirmationId != null) {
          requestBody['confirmation_id'] = widget.confirmationId;
        } else {
          // Jika tidak ada confirmation_id, kirim campaign_id
          // Backend akan create confirmation baru dari campaign_id
          requestBody['campaign_id'] = widget.campaignId;
        }

        final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}/fulfillment/donor/confirm'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final confirmationData = data['data'];

          // ✅ Navigate to success page with unique code
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DonorConfirmationSuccess(
                  uniqueCode: confirmationData['uniqueCode'] ?? 'N/A',
                  donorName: confirmationData['donorName'] ?? _nameController.text,
                  bloodType: widget.golonganDarah,
                  instructions: 'Harap datang ke PMI dengan membawa kode unik ini untuk verifikasi dan proses donor darah.',
                  codeExpiresAt: confirmationData['codeExpiresAt'] ?? DateTime.now().add(Duration(days: 7)).toString(),
                ),
              ),
            );
          }
        } else {
          final error = jsonDecode(response.body);
          final errorMsg = error['message'] ?? response.body;
          ToastService.showError(context, message: 'Error: $errorMsg');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ToastService.showError(context, message: 'Error: $e');
      }
    }
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            color: text == "Golongan Darah" ? AppTheme.neutral_01.withOpacity(0.6) : AppTheme.neutral_01,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Detail Pendonor Darah',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.brand_02,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            onTap: _isLoading ? null : _autoFillUserData, // Auto-fill on tap
                            borderRadius: BorderRadius.circular(18),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                                  : Text(
                                'Isi dengan data anda saat ini',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildLabel('Nama Lengkap Pendonor'),
                            MyTextField(
                              isAuth: false,
                              hintText: 'Nama Lengkap Pendonor',
                              keyboardType: TextInputType.text,
                              inputType: InputType.text,
                              controller: _nameController,
                              readOnly: true, // ✅ Read-only - auto-filled from profile
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Nomor WhatsApp'),
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white60,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 4,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                    border: Border.all(color: AppTheme.neutral_01.withOpacity(0.53), width: 0.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    controller: _countryCodeController,
                                    readOnly: true,
                                    style: TextStyle(color: AppTheme.neutral_01),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '+62',
                                      hintStyle: TextStyle(color: AppTheme.neutral_01),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: MyTextField(
                                    isAuth: false,
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
                            _buildLabel('Golongan Darah'),
                            TextFormField(
                              readOnly: true,
                              controller: _bloodTypeController,
                              style: TextStyle(
                                color: AppTheme.neutral_01.withOpacity(0.4),
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white38,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppTheme.neutral_01.withOpacity(0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: AppTheme.neutral_01.withOpacity(0.2)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildLabel('Riwayat Penyakit'),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonFormField<String>(
                                dropdownColor: Colors.white,
                                value: _selectedRiwayatPenyakit,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  filled: true,
                                  fillColor: Colors.white60,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: AppTheme.neutral_01.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: AppTheme.neutral_01.withOpacity(0.3)),
                                  ),
                                ),
                                style: TextStyle(
                                  color: AppTheme.neutral_01,
                                  fontSize: 16,
                                ),
                                hint: Text(
                                  'Pilih riwayat penyakit',
                                  style: TextStyle(
                                    color: AppTheme.neutral_01.withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                ),
                                items: _riwayatPenyakitOptions.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: AppTheme.neutral_01,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRiwayatPenyakit = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Pilih salah satu';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            // Extra bottom padding for spacing
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20), // Spacing before button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: _isLoading ? AppTheme.brand_04.withOpacity(0.6) : AppTheme.brand_04,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: _isLoading ? null : _submitForm,
                    borderRadius: BorderRadius.circular(20),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Text(
                        'Ajukan Pendonoran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '© 2025 Beyond. Hak Cipta Dilindungi.',
                  style: TextStyle(
                    color: AppTheme.neutral_01.withOpacity(0.4),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
