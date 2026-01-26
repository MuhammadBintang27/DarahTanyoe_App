import 'package:darahtanyoe_app/models/donor_confirmation_model.dart';
import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_border/dotted_border.dart';

class DonorConfirmationDetail extends StatefulWidget {
  final DonorConfirmationModel confirmation;

  const DonorConfirmationDetail({
    Key? key,
    required this.confirmation,
  }) : super(key: key);

  @override
  State<DonorConfirmationDetail> createState() =>
      _DonorConfirmationDetailState();
}

class _DonorConfirmationDetailState extends State<DonorConfirmationDetail> {
  late DonorConfirmationModel _confirmation;

  @override
  void initState() {
    super.initState();
    _confirmation = widget.confirmation;
    _logConfirmationData();
  }

  void _logConfirmationData() {
    // Debug logging for confirmation data
    print('🔍 DEBUG: Confirmation data received');
    print('🔍 Campaign ID: ${_confirmation.campaignId}');
    print('🔍 Campaign Object: ${_confirmation.campaign}');
    print('🔍 Campaign Location: ${_confirmation.campaignLocation}');
    print('🔍 Campaign Address: ${_confirmation.campaignAddress}');
    print('🔍 Campaign Latitude: ${_confirmation.campaignLatitude}');
    print('🔍 Campaign Longitude: ${_confirmation.campaignLongitude}');
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_confirmation.status);
    final statusText = _getStatusText(_confirmation.status);

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

                                // Nama Pasien
                                _buildField('Nama Pasien', _confirmation.patientName ?? 'N/A'),
                                const SizedBox(height: 12),

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

                                // Deskripsi Campaign
                                _buildField('Deskripsi', _confirmation.campaign?.description ?? 'Tidak ada deskripsi'),
                                const SizedBox(height: 12),

                                // Lokasi & Donor Sebelum (2 kolom)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildField(
                                        'Lokasi Pendonoran',
                                        '${_confirmation.campaign?.location?.split(',').first ?? 'RSUD Zainal Abidin'} (${_confirmation.distanceKm?.toStringAsFixed(1) ?? '2.0'} KM)',
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

                        // Warning Message
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECEC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            'Akan ada pemeriksaan kesehatan di lokasi pendonoran, pastikan diri anda dalam kondisi fit dan siap donor!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Status Section
                        _buildStatusSection(statusColor, statusText),
                        const SizedBox(height: 40),

                        // Copyright
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
              ),
    );
  }

  Widget _buildField(String label, String value) {
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
            maxLines: 1,
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
    final isActive =
        _confirmation.status == 'confirmed' || _confirmation.status == 'code_verified';

    return Container(
      width: 299,
      height: 54,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'STATUS PENDONORAN',
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Batalkan'),
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
      case 'expired':
        return 'Kadaluarsa';
      default:
        return 'Status Tidak Diketahui';
    }
  }

  void _openGoogleMaps() async {
    try {
      // Debug logging untuk melihat data yang tersedia
      debugPrint("📍 Campaign Data: ${_confirmation.campaign?.location}");
      debugPrint("📍 Campaign Address: ${_confirmation.campaign?.address}");
      debugPrint("📍 Parsed Latitude: ${_confirmation.campaignLatitude}");
      debugPrint("📍 Parsed Longitude: ${_confirmation.campaignLongitude}");
      
      double? latitude = _confirmation.campaignLatitude;
      double? longitude = _confirmation.campaignLongitude;
      
      if (latitude != null && longitude != null) {
        debugPrint("LATITUDE $latitude");
        debugPrint("LONGITUDE $longitude");
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
        
        debugPrint("📍 Fallback search with location name: $locationName");
        
        final Uri url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(locationName)}',
        );
        
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Koordinat lokasi tidak tersedia dan tidak dapat mencari berdasarkan nama')),
          );
        }
      }
    } catch (e) {
      print('Error opening Google Maps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka Google Maps')),
      );
    }
  }
}
