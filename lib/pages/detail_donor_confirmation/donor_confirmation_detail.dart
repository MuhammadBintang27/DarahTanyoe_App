import 'package:darahtanyoe_app/models/donor_confirmation_model.dart';
import 'package:darahtanyoe_app/components/app_bar_with_logo.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/service/toast_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:darahtanyoe_app/service/institution_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class DonorConfirmationDetail extends StatefulWidget {
  final DonorConfirmationModel confirmation;

  const DonorConfirmationDetail({
    super.key,
    required this.confirmation,
  });

  @override
  State<DonorConfirmationDetail> createState() =>
      _DonorConfirmationDetailState();
}

class _DonorConfirmationDetailState extends State<DonorConfirmationDetail> {
  late DonorConfirmationModel _confirmation;
  late Timer _timerUpdate;
  late ValueNotifier<String> _timeRemaining;
  Map<String, dynamic>? _pmi;
  double? _pmiLat;
  double? _pmiLng;

  @override
  void initState() {
    super.initState();
    _confirmation = widget.confirmation;
    _timeRemaining = ValueNotifier<String>(_confirmation.formattedTimeRemaining);
    _startTimer();
    _logConfirmationData();
    _maybeFetchPmi();
  }

  void _startTimer() {
    _timerUpdate = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _timeRemaining.value = _confirmation.formattedTimeRemaining;
      }
    });
  }

  @override
  void dispose() {
    _timerUpdate.cancel();
    _timeRemaining.dispose();
    super.dispose();
  }

  void _logConfirmationData() {
    // Debug logging for confirmation data
  }

  Future<void> _maybeFetchPmi() async {
    if ((_confirmation.confirmationOrigin == 'donor_biasa') && (_confirmation.pmiId != null && _confirmation.pmiId!.isNotEmpty)) {
      try {
        final inst = await InstitutionService.getInstitutionById(_confirmation.pmiId!);
        if (mounted) {
          setState(() {
            _pmi = inst;
            final loc = inst?['location'];
            if (loc is String) {
              _pmiLat = _parseEWKBLatitude(loc);
              _pmiLng = _parseEWKBLongitude(loc);
            }
          });
        }
      } catch (e) {
        // Intentionally empty - PMI institution fetch error is non-blocking
      }
    }
  }

  // Minimal EWKB parsers for POINT with SRID
  double? _parseEWKBLatitude(String ewkbHex) {
    try {
      if (ewkbHex.length < 50) return null;
      final latHex = ewkbHex.substring(34, 50);
      return _bytesToDouble(_hexToBytes(latHex));
    } catch (_) {
      return null;
    }
  }

  double? _parseEWKBLongitude(String ewkbHex) {
    try {
      if (ewkbHex.length < 50) return null;
      final lngHex = ewkbHex.substring(18, 34);
      return _bytesToDouble(_hexToBytes(lngHex));
    } catch (_) {
      return null;
    }
  }

  List<int> _hexToBytes(String hex) {
    final List<int> bytes = [];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  double _bytesToDouble(List<int> bytes) {
    final bd = ByteData.view(Uint8List.fromList(bytes).buffer);
    return bd.getFloat64(0, Endian.little);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_confirmation.status);
    final statusText = _getStatusText(_confirmation.status);
    final bool isDonorBiasa = (_confirmation.confirmationOrigin == 'donor_biasa');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarWithLogo(
        title: 'Detail Konfirmasi Donor',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Container with dashed border for all fields
                        DottedBorder(
                          borderType: BorderType.RRect,
                          radius: const Radius.circular(20),
                          padding: const EdgeInsets.all(0),
                          dashPattern: const [8, 4],
                          color: const Color.fromRGBO(86, 86, 86, 0.26),
                          strokeWidth: 2,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.3707, 0.8107],
                                colors: [
                                  Color.fromRGBO(171, 69, 69, 0.2), // rgba(171, 69, 69, 0.2)
                                  Color.fromRGBO(255, 255, 255, 0.01), // rgba(255, 255, 255, 0.01)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                // Nama Pendonor
                                FutureBuilder<Map<String, dynamic>?>(
                                  future: AuthService().getCurrentUser(),
                                  builder: (context, snapshot) {
                                    String userName = 'Memuat...';
                                    if (snapshot.connectionState == ConnectionState.done &&
                                        snapshot.hasData &&
                                        snapshot.data != null) {
                                      userName = snapshot.data!['full_name'] ?? 'Pengguna';
                                    }
                                    return _buildField('Nama Pendonor', userName);
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Nama Pasien (sembunyikan jika Donor Biasa)
                                if (!isDonorBiasa) ...[
                                  _buildField('Nama Pasien', _confirmation.patientName ?? 'N/A'),
                                  const SizedBox(height: 12),
                                ],

                                // Golongan Darah & Telah Terisi (2 kolom)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildField('Golongan Darah', _confirmation.patientBloodType ?? 'A'),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildField(
                                        'Telah terisi',
                                        '${_confirmation.fulfillmentRequest?.quantityCollected ?? 0} dari ${_confirmation.fulfillmentRequest?.quantityNeeded ?? 0 } kantong',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Deskripsi (Donor Biasa pakai hardcode)
                                _buildField(
                                  'Deskripsi',
                                  isDonorBiasa
                                      ? 'Donor terjadwal di PMI yang Anda pilih. Mohon hadir sesuai jadwal, membawa identitas, dan pastikan kondisi sehat sebelum donor.'
                                      : (_confirmation.campaign?.description ?? 'Tidak ada deskripsi'),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 12),

                                // Lokasi & Donor Sebelum (2 kolom)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        'Lokasi Pendonoran',
                                        isDonorBiasa
                                            ? '${_pmi?['institution_name'] ?? 'PMI Tujuan'}\n${_pmi?['address'] ?? ''}'.trim()
                                            : '${_confirmation.campaign?.location?.split(',').first ?? 'RSUD Zainal Abidin'} (${_confirmation.distanceKm?.toStringAsFixed(1) ?? '2.0'} KM)',
                                        maxLines: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildField('Pendonoran Sebelum', '26 Juli 2024, 16:00 WIB'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Kode Unik & Maps (2 kolom dengan styling khusus)
                        Row(
                          children: [
                            Expanded(
                              child: _buildSpecialField('Kode Unik', _confirmation.uniqueCode ?? 'AC6B34'),
                            ),
                            const SizedBox(width: 12),
                            if (isDonorBiasa)
                              Expanded(
                                child: DottedBorder(
                                  borderType: BorderType.RRect,
                                  radius: const Radius.circular(12),
                                  padding: const EdgeInsets.all(0),
                                  dashPattern: const [6, 3],
                                  color: const Color.fromRGBO(35, 58, 131, 0.4),
                                  strokeWidth: 1.2,
                                  child: InkWell(
                                    onTap: _openGoogleMaps,
                                    child: Container(
                                      height: 75,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(35, 58, 131, 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on, color: Colors.blue[400], size: 27),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _pmi != null ? 'Lihat lokasi PMI pada Google Maps' : 'Cari PMI terdekat di Google Maps',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                                height: 1.33,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (!isDonorBiasa)
                              Expanded(
                                child: GestureDetector(
                                  onTap: _openGoogleMaps,
                                  child: DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: const Radius.circular(12),
                                    padding: const EdgeInsets.all(0),
                                    dashPattern: const [6, 3],
                                    color: const Color.fromRGBO(35, 58, 131, 0.4),
                                    strokeWidth: 1.2,
                                    child: Container(
                                      height: 75,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(35, 58, 131, 0.16),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color.fromRGBO(0, 0, 0, 0.1),
                                            offset: Offset(0, 4),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Google Maps Icon placeholder
                                          Container(
                                            width: 27,
                                            height: 38,
                                            decoration: const BoxDecoration(
                                              color: Colors.transparent,
                                            ),
                                            child: Image.asset(
                                              'assets/images/google_maps_icon.png',
                                              width: 27,
                                              height: 38,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.location_on,
                                                  color: Colors.blue[400],
                                                  size: 27,
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Lihat lokasi pendonoran pada Google Maps',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                                height: 1.33,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        

                        // Status Section
                        _buildStatusSection(statusColor, statusText),
                        
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '© 2025 Beyond. Hak Cipta Dilindungi.',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

  }

  Widget _buildField(String label, String value, {int maxLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(171, 69, 69, 0.18),
        border: Border.all(
          color: const Color.fromRGBO(171, 69, 69, 0.37),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color.fromRGBO(0, 0, 0, 0.7),
              height: 1.29, // 18px / 14px
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF565656),
              height: 1.33, // 16px / 12px
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialField(String label, String value) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      padding: const EdgeInsets.all(0),
      dashPattern: const [6, 3],
      color: const Color.fromRGBO(35, 58, 131, 0.4),
      strokeWidth: 1.2,
      child: Container(
        height: 75,
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 58, 131, 0.16),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.1),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(0, 0, 0, 0.7),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF565656),
                height: 1.2,
                letterSpacing: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(Color statusColor, String statusText) {
    // Status Sedang Berjalan (confirmed/code_verified) - dengan timer countdown
    if (_confirmation.status == 'confirmed' || _confirmation.status == 'code_verified') {
      return Column(
        children: [
          // Warning text dengan divider
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8B4545),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    children: const [
                      TextSpan(text: 'Akan ada '),
                      TextSpan(
                        text: 'pemeriksaan kesehatan',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(text: ' di lokasi pendonoran, pastikan diri anda dalam '),
                      TextSpan(
                        text: 'kondisi fit dan siap donor!',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Color.fromRGBO(171, 69, 69, 0.2),
                  thickness: 1,
                  height: 1,
                ),
              ],
            ),
          ),
          // Timer Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color.fromRGBO(171, 69, 69, 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SISA WAKTU SEBELUM PENDONORAN BERAKHIR',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B4545),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ValueListenableBuilder<String>(
                    valueListenable: _timeRemaining,
                    builder: (context, timeValue, child) {
                      return Text(
                        timeValue,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B4545),
                          letterSpacing: 1,
                          height: 1.2,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Tombol Batalkan
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _cancelJanjiDonor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4545),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Batalkan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Status Dibatalkan/Ditolak - dengan container border sama
    if (_confirmation.status == 'rejected' || _confirmation.status == 'expired' || _confirmation.status == 'failed' || _confirmation.status == 'cancelled') {
      return Column(
        children: [
          // Warning text dengan divider (spacing kosong)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                SizedBox(height: 24),
              ],
            ),
          ),
          // Status content container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color.fromRGBO(171, 69, 69, 0.2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon X
                    Image.asset(
                      'assets/images/icon_error_x.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    // Title text
                    const Expanded(
                      child: Text(
                        'PENDONORAN DARAH DIBATALKAN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8B4545),
                        ),
                      ),
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ],
      );
    }

    // Status Selesai - dengan container border sama
    if (_confirmation.status == 'completed') {
      return Column(
        children: [
          // Warning text dengan divider (spacing kosong)
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                SizedBox(height: 24),
                
              ],
            ),
          ),
          // Status content container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color.fromRGBO(53, 155, 94, 0.2),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Checkmark
                Image.asset(
                  'assets/images/icon_success_checkmark.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                // Text
                const Expanded(
                  child: Text(
                    'PENDONORAN DARAH SELESAI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF359B5E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Status Default/Pending
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromRGBO(171, 69, 69, 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATUS PENDONORAN',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF565656),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statusText,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF565656),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }



  Color _getStatusColor(String? status) {
    switch (status) {
      case 'confirmed':
      case 'code_verified':
        return const Color(0xFFCB9B0A); // Yellow
      case 'completed':
        return const Color(0xFF359B5E); // Green
      case 'rejected':
      case 'expired':
        return const Color(0xFFAB4545); // Red
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'confirmed':
      case 'code_verified':
        return 'Pendonoran Sedang Berlangsung';
      case 'completed':
        return 'Pendonoran Selesai';
      case 'rejected':
        return 'Pendonoran Dibatalkan';
      case 'cancelled':
        return 'Pendonoran Dibatalkan';
      case 'expired':
        return 'Kadaluarsa';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  void _openGoogleMaps() async {
    try {
      final bool isDonorBiasa = (_confirmation.confirmationOrigin == 'donor_biasa');
      if (isDonorBiasa) {
        // Donor Biasa: gunakan koordinat PMI jika tersedia, jika tidak cari berdasarkan nama/alamat
        if (_pmiLat != null && _pmiLng != null) {
          final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${_pmiLat},${_pmiLng}');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            if (mounted) {
              ToastService.showError(context, message: 'Tidak dapat membuka lokasi PMI di Google Maps');
            }
          }
          return;
        }
        final String searchQuery = (_pmi?['institution_name'] ?? _pmi?['address'] ?? 'PMI (Palang Merah Indonesia)').toString();
        final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ToastService.showError(context, message: 'Tidak dapat membuka pencarian PMI di Google Maps');
          }
        }
        return;
      }
      // Debug logging untuk melihat data yang tersedia
      
      double? latitude = _confirmation.campaignLatitude;
      double? longitude = _confirmation.campaignLongitude;
      
      if (latitude != null && longitude != null) {
        final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      } else {
        // Fallback: coba buka dengan nama lokasi
        final locationName = _confirmation.campaign?.location ?? 
                           _confirmation.campaign?.address ?? 
                           'RSUD Zainal Abidin';
        
        final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationName)}',
        );
        
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ToastService.showError(context, message: 'Koordinat lokasi tidak tersedia dan tidak dapat mencari berdasarkan nama');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, message: 'Gagal membuka. Pastikan Google Maps terinstal');
      }
    }
  }

  Future<void> _cancelJanjiDonor() async {
    try {
      final user = await AuthService().getCurrentUser();
      final donorId = user?['id'];
      if (donorId == null) {
        ToastService.showError(context, message: 'User tidak ditemukan');
        return;
      }
      final baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
      // Pilih endpoint berdasarkan origin
      final bool isDonorBiasa = (_confirmation.confirmationOrigin == 'donor_biasa');
      final Uri url = isDonorBiasa
          ? Uri.parse('$baseUrl/janji-donor/cancel')
          : Uri.parse('$baseUrl/fulfillment/donor/cancel');
      final Map<String, dynamic> payload = {
        'confirmation_id': _confirmation.id,
        'donor_id': donorId,
      };
      // untuk fulfillment, kita dukung optional reason
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;
      if (resp.statusCode == 200) {
        ToastService.showSuccess(context, message: isDonorBiasa ? 'Janji Donor berhasil dibatalkan' : 'Konfirmasi donor berhasil dibatalkan');
        Navigator.pop(context);
      } else {
        final msg = (() {
          try {
            final j = jsonDecode(resp.body);
            return j['message']?.toString() ?? 'Gagal membatalkan Janji Donor';
          } catch (_) {
            return 'Gagal membatalkan Janji Donor';
          }
        })();
        ToastService.showError(context, message: msg);
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showError(context, message: 'Error: $e');
    }
  }
}
