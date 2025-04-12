import 'dart:convert';
import 'dart:math';
import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/my_textfield.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'package:darahtanyoe_app/pages/mainpage/transaksi.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataPendonoranDarah extends StatefulWidget {
  final String? requestId;
  final String golonganDarah;

  const DataPendonoranDarah({
    Key? key,
    required this.requestId,
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
  }

  String generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _autoFillUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userDataString = await _storage.read(key: 'userData');
      if (userDataString == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data pengguna tidak ditemukan. Silakan login kembali.')),
        );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pengguna: ${e.toString()}')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User belum login')),
        );
        return;
      }

      final userData = jsonDecode(userDataString);
      final userId = userData['id'];

      final body = {
        "user_id": userId,
        "request_id": widget.requestId,
        "full_name": _nameController.text,
        "phone_number": '62${_phoneController.text}',
        "health_notes": _selectedRiwayatPenyakit ?? '',
        "status": "on_progress",
        "unique_code": generateUniqueCode(),
      };

      final response = await http.post(
        Uri.parse('${dotenv.env['BASE_URL']}/donor/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDonorSuccessDialog(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim data: ${response.body}')),
        );
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
          style: GoogleFonts.dmSans(
            color: text == "Golongan Darah" ? AppTheme.neutral_01.withOpacity(0.6) : AppTheme.neutral_01,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void showDonorSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: Colors.green),
                const SizedBox(height: 10),
                const Text(
                  "Pendaftaran Donor Berhasil",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Pengajuan Anda diproses. Silakan datang ke RS/PMI tujuan untuk pengecekan dan donor darah.",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.setString('transaksiTab', "donor");
                      prefs.setInt('selectedIndex', 3);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()),
                            (route) => false,
                      );
                    });
                  },
                  child: const Text("Lihat Daftar Pendonoran", style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
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
                                style: GoogleFonts.dmSans(
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
                                    style: GoogleFonts.dmSans(color: AppTheme.neutral_01),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '+62',
                                      hintStyle: GoogleFonts.dmSans(color: AppTheme.neutral_01),
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
                              style: GoogleFonts.dmSans(
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
                                style: GoogleFonts.dmSans(
                                  color: AppTheme.neutral_01,
                                  fontSize: 16,
                                ),
                                hint: Text(
                                  'Pilih riwayat penyakit',
                                  style: GoogleFonts.dmSans(
                                    color: AppTheme.neutral_01.withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                ),
                                items: _riwayatPenyakitOptions.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: GoogleFonts.dmSans(
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
                        style: GoogleFonts.dmSans(
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
