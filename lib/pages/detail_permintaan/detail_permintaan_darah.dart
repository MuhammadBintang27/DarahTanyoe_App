import 'package:darahtanyoe_app/components/app_bar_with_logo.dart';
import 'package:darahtanyoe_app/components/all_svg.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/helpers/format_date_time.dart';
import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/pages/donor_darah/data_donor_darah.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/service/toast_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DetailPermintaanDarah extends StatefulWidget {
  final PermintaanDarahModel permintaan;
  final String? confirmationId;  // From notification

  const DetailPermintaanDarah({
    super.key,
    required this.permintaan,
    this.confirmationId,
  });

  @override
  State<DetailPermintaanDarah> createState() => _DetailPermintaanDarahState();
}

class _DetailPermintaanDarahState extends State<DetailPermintaanDarah> {
  double? _distance;
  String? _confirmationId;  // ✅ Store confirmation ID
  bool _preCheckLoading = false;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _calculateDistance();
    _preCheckConfirmation();  // ✅ Call pre-check on page load
  }

  // ✅ NEW: Pre-check confirmation for direct access flow
  Future<void> _preCheckConfirmation() async {
    // If coming from notification, already have confirmationId
    if (widget.confirmationId != null) {
      setState(() {
        _confirmationId = widget.confirmationId;
      });
      return;
    }

    // For "Permintaan Terdekat" flow, call pre-check endpoint
    setState(() {
      _preCheckLoading = true;
    });

    try {
      final userDataString = await _storage.read(key: 'userData');
      if (userDataString == null) {
        return;
      }

      final userData = jsonDecode(userDataString);
      final donorId = userData['id'];
      final campaignId = widget.permintaan.id;

      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/fulfillment/donor/pre-check')
            .replace(queryParameters: {
          'campaign_id': campaignId,
          'donor_id': donorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final confirmationId = data['data']['confirmationId'];
        
        setState(() {
          _confirmationId = confirmationId;
        });
      }
    } catch (e) {
      // Intentionally empty - blood availability check error is non-blocking
    } finally {
      setState(() {
        _preCheckLoading = false;
      });
    }
  }

  Future<void> _calculateDistance() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          return await Geolocator.getLastKnownPosition() ?? 
            Position(
              latitude: 0,
              longitude: 0,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            );
        },
      );

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.permintaan.latitude,
        widget.permintaan.longitude,
      ) / 1000; // Convert meters to km

      if (mounted) {
        setState(() {
          _distance = double.parse(distance.toStringAsFixed(1));
        });
      }
    } catch (e) {
      // Intentionally empty - donor confirmation failure is non-blocking
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Detail Permintaan Darah',
        onBackPressed: () {
          Navigator.pop(context);
        },
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
                      _buildInfoCard(
                        leadingIcon: SvgPicture.string(
                          userRequest,
                          colorFilter: ColorFilter.mode(AppTheme.neutral_01, BlendMode.srcIn),
                          width: 30,
                          height: 30,
                        ),
                        title: 'Peminta Darah',
                        subtitle: widget.permintaan.patientName ?? '-',
                        isProfile: true,
                      ),
                      const SizedBox(height: 6),
                      Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 73,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.brand_01,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.string(
                            bloodTypeSvg,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.permintaan.bloodType ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 73,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.brand_01,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.string(
                            bloodTube,
                            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            width: 36,
                            height: 36,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Jumlah Darah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${widget.permintaan.relatedBloodRequest?.quantity ?? 0} Kantong',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLocationCard(
                title: 'Lokasi Permintaan Darah',
                location: widget.permintaan.organiser?.institutionName ?? 'N/A',
                distance: _distance,
                latitude: widget.permintaan.latitude,
                longitude: widget.permintaan.longitude,
              ),
              _buildInfoCard(
                leadingIcon: SvgPicture.string(
                  timeSand,
                  colorFilter: ColorFilter.mode(AppTheme.neutral_01, BlendMode.srcIn),
                  width: 30,
                  height: 30,
                ),
                title: 'Jadwal Berakhir Permintaan',
                subtitle: formatDateTime(widget.permintaan.endDate.toIso8601String()),
              ),
              _buildInfoCard(
                leadingIcon: SvgPicture.string(
                  descriptionSvg,
                  colorFilter: ColorFilter.mode(AppTheme.neutral_01, BlendMode.srcIn),
                  width: 30,
                  height: 30,
                ),
                title: 'Deskripsi Kebutuhan',
                subtitle: (widget.permintaan.description ?? '').trim().isNotEmpty
                    ? widget.permintaan.description ?? '-'
                    : '-',
                hasMoreButton: true,
              ),
                      _buildInfoCard(
                        leadingIcon: SvgPicture.string(
                          info,
                          colorFilter: ColorFilter.mode(AppTheme.neutral_01, BlendMode.srcIn),
                          width: 30,
                          height: 30,
                        ),
                        title: 'Progress Permintaan',
                        subtitle: 'Telah terisi ${widget.permintaan.currentQuantity} dari ${widget.permintaan.relatedBloodRequest?.quantity ?? 0} Kantong',
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
                  color: AppTheme.brand_03,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      // ✅ Use pre-checked confirmation ID if available
                      final confirmId = _confirmationId ?? widget.confirmationId;
                      
                      if (confirmId == null && !_preCheckLoading) {
                        ToastService.showError(context, message: 'Gagal mempersiapkan konfirmasi. Silakan refresh halaman.');
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataPendonoranDarah(
                            confirmationId: confirmId,  // ✅ Use pre-checked ID
                            campaignId: widget.permintaan.id,
                            golonganDarah: widget.permintaan.bloodType ?? '-',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Center(
                      child: _preCheckLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'Donor Sekarang',
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
                    color: AppTheme.neutral_01.withValues(alpha: 0.4),
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


  Widget _buildInfoCard({
    required Widget leadingIcon,
    required String title,
    required String subtitle,
    bool isProfile = false,
    bool hasMoreButton = false,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          border: Border.all(color: AppTheme.brand_02.withValues(alpha: 0.37)),
          color: const Color(0xFFEEE8D7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral_01,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.neutral_01,
                  ),
                  maxLines: hasMoreButton ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String location,
    required double? distance,
    required double latitude,
    required double longitude,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: AppTheme.brand_02.withValues(alpha: 0.37)),
          color: const Color(0xFFEEE8D7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Row(
        children: [
          SvgPicture.string(
            hospitalSvg,
            colorFilter: ColorFilter.mode(AppTheme.neutral_01, BlendMode.srcIn),
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neutral_01,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.neutral_01,
                  ),
                ),
                if (distance != null)
                  Text(
                    '$distance KM dari alamat anda',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              final Uri url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            },
            borderRadius: BorderRadius.circular(20), // agar efek ripple sesuai
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.brand_04,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.brand_02.withValues(alpha: 0.37)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.location_on,
                    color: AppTheme.brand_02,
                    size: 20,
                  ),
                  SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: 'Lihat pada\n',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'Google Maps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
