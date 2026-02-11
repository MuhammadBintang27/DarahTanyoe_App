import 'dart:convert';
import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/my_textfield.dart';
import 'package:darahtanyoe_app/pages/donor_darah/donor_confirmation_success.dart';
import 'package:darahtanyoe_app/pages/detail_donor_confirmation/donor_confirmation_detail.dart';
import 'package:darahtanyoe_app/models/donor_confirmation_model.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class DataPendonoranBiasa extends StatefulWidget {
  const DataPendonoranBiasa({Key? key}) : super(key: key);

  @override
  State<DataPendonoranBiasa> createState() => _DataPendonoranBiasaState();
}

class _DataPendonoranBiasaState extends State<DataPendonoranBiasa> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryCodeController = TextEditingController(text: '+62');
  final TextEditingController _bloodTypeController = TextEditingController(text: 'A+');

  String? _selectedRiwayatPenyakit;
  List<Map<String, dynamic>> _pmiList = [];
  String? _selectedPMIId;
  bool _isLoadingPMI = false;

  final List<String> _riwayatPenyakitOptions = const [
    'Tidak ada',
    'Diabetes',
    'Hipertensi',
    'Penyakit Jantung',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _autoFillUserData();
    _fetchPMIList();
  }

  Future<void> _autoFillUserData() async {
    setState(() => _isLoading = true);
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
        _bloodTypeController.text = userData['blood_type'] ?? _bloodTypeController.text;
        final healthNotes = userData['health_notes'];
        _selectedRiwayatPenyakit = _riwayatPenyakitOptions.contains(healthNotes)
            ? healthNotes
            : 'Lainnya';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data pengguna: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPMIList() async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) return;
    final url = Uri.parse("$baseUrl/partners");
    try {
      setState(() => _isLoadingPMI = true);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> allInstitutions = data["data"] ?? [];
        final pmiInstitutions = allInstitutions
            .where((inst) => inst["institution_type"] == "pmi")
            .toList();
        setState(() {
          _pmiList = List<Map<String, dynamic>>.from(pmiInstitutions.map((pmi) => {
                "id": pmi["id"]?.toString() ?? "",
                "name": pmi["institution_name"]?.toString() ?? (pmi["name"]?.toString() ?? "PMI"),
              }));
          if (_pmiList.isNotEmpty && (_selectedPMIId == null || _selectedPMIId!.isEmpty)) {
            _selectedPMIId = _pmiList.first["id"];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar PMI: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingPMI = false);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userDataString = await _storage.read(key: 'userData');
        if (userDataString == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User belum login')),
          );
          return;
        }
        final userData = jsonDecode(userDataString);
        final donorId = userData['id'];
        if (_selectedPMIId == null || _selectedPMIId!.isEmpty) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Silakan pilih PMI tujuan terlebih dahulu.')),
          );
          return;
        }
        final requestBody = {
          'donor_id': donorId,
          'blood_type': _bloodTypeController.text,
          'pmi_id': _selectedPMIId,
        };
        final response = await http.post(
          Uri.parse('${dotenv.env['BASE_URL']}/janji-donor/create'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        setState(() => _isLoading = false);
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final confirmationData = data['data'];
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DonorConfirmationSuccess(
                  uniqueCode: confirmationData['uniqueCode'] ?? confirmationData['unique_code'] ?? 'N/A',
                  donorName: confirmationData['donorName'] ?? _nameController.text,
                  bloodType: _bloodTypeController.text,
                  instructions: 'Harap datang ke PMI dengan membawa kode unik ini untuk verifikasi dan proses donor darah.',
                  codeExpiresAt: confirmationData['codeExpiresAt'] ?? confirmationData['code_expires_at'] ?? DateTime.now().add(const Duration(days: 7)).toString(),
                ),
              ),
            );
          }
        } else if (response.statusCode == 409) {
          final data = jsonDecode(response.body);
          final existing = data['existing'];
          if (existing != null && mounted) {
            final model = DonorConfirmationModel.fromJson(existing as Map<String, dynamic>);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DonorConfirmationDetail(confirmation: model)),
            );
          } else {
            final errorMsg = data['message'] ?? 'Janji Donor aktif sudah ada';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg)),
            );
          }
        } else {
          final error = jsonDecode(response.body);
          final errorMsg = error['message'] ?? response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMsg')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Detail Pendonor Darah',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
          child: Column(
            children: [
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
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            onTap: _isLoading ? null : _autoFillUserData,
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
                              readOnly: true,
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
                            _buildLabel('Pilih PMI Tujuan'),
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
                                value: _selectedPMIId,
                                isExpanded: true,
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
                                  _isLoadingPMI ? 'Memuat daftar PMI...' : 'Pilih PMI tujuan',
                                  style: GoogleFonts.dmSans(
                                    color: AppTheme.neutral_01.withOpacity(0.4),
                                    fontSize: 16,
                                  ),
                                ),
                                items: _pmiList.map<DropdownMenuItem<String>>((pmi) {
                                  final String id = (pmi['id'] ?? '').toString();
                                  final String name = (pmi['name'] ?? 'PMI').toString();
                                  return DropdownMenuItem<String>(
                                    value: id,
                                    child: Text(
                                      name,
                                      style: GoogleFonts.dmSans(
                                        color: AppTheme.neutral_01,
                                        fontSize: 16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPMIId = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Pilih PMI tujuan';
                                  }
                                  return null;
                                },
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
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      offset: const Offset(0, 4),
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
