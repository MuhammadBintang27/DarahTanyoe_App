import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/allSvg.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/helpers/formatDateTime.dart';
import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/pages/donor_darah/data_donor_darah.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPermintaanDarah extends StatefulWidget {
  final PermintaanDarahModel permintaan;

  const DetailPermintaanDarah({
    Key? key,
    required this.permintaan,
  }) : super(key: key);

  @override
  State<DetailPermintaanDarah> createState() => _DetailPermintaanDarahState();
}

class _DetailPermintaanDarahState extends State<DetailPermintaanDarah> {
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
              _buildInfoCard(
                leadingIcon: SvgPicture.string(
                  userRequest,
                  color: AppTheme.neutral_01,
                  width: 30,
                  height: 30,
                ),
                title: 'Peminta Darah',
                subtitle: widget.permintaan.patientName,
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
                            color: Colors.black.withOpacity(0.25),
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
                            color: Colors.white,
                            width: 30,
                            height: 30,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.permintaan.bloodType,
                            style: TextStyle(
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
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          SvgPicture.string(
                            bloodTube,
                            color: Colors.white,
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
                                '${widget.permintaan.bloodBagsNeeded} Kantong',
                                style: TextStyle(
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
                location: widget.permintaan.partner_name,
                distance: widget.permintaan.distance,
                latitude: widget.permintaan.partner_latitude,
                longitude: widget.permintaan.partner_longitude,
              ),
              _buildInfoCard(
                leadingIcon: SvgPicture.string(
                  timeSand,
                  color: AppTheme.neutral_01,
                  width: 30,
                  height: 30,
                ),
                title: 'Jadwal Berakhir Permintaan',
                subtitle: formatDateTime(widget.permintaan.expiry_date),
              ),
              _buildInfoCard(
                leadingIcon: SvgPicture.string(
                  descriptionSvg,
                  color: AppTheme.neutral_01,
                  width: 30,
                  height: 30,
                ),
                title: 'Deskripsi Kebutuhan',
                subtitle: (widget.permintaan.description ?? '').trim().isNotEmpty
                    ? widget.permintaan.description
                    : '-',
                hasMoreButton: true,
              ),
              _buildInfoCard(
                leadingIcon: SvgPicture.string(
                  info,
                  color: AppTheme.neutral_01,
                  width: 30,
                  height: 30,
                ),
                title: 'Progress Permintaan',
                subtitle: 'Telah terisi ${widget.permintaan.bloodBagsFulfilled} dari ${widget.permintaan.bloodBagsNeeded} Kantong',
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.brand_03,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DataPendonoranDarah(
                            requestId: widget.permintaan.id,
                            golonganDarah: widget.permintaan.bloodType,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Center(
                      child: Text(
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
          border: Border.all(color: AppTheme.brand_02.withOpacity(0.37)),
          color: const Color(0xFFEEE8D7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
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
                  maxLines: 1,
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
          border: Border.all(color: AppTheme.brand_02.withOpacity(0.37)),
          color: const Color(0xFFEEE8D7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: Row(
        children: [
          SvgPicture.string(
            hospitalSvg,
            color: AppTheme.neutral_01,
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
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.neutral_01,
                  ),
                ),
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
            },
            borderRadius: BorderRadius.circular(20), // agar efek ripple sesuai
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.brand_04,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.brand_02.withOpacity(0.37)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
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
