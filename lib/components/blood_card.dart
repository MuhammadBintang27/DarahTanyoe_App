import 'package:darahtanyoe_app/helpers/get_selisih.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:darahtanyoe_app/components/all_svg.dart';

class BloodCard extends StatelessWidget {
  final String status;
  final String bloodType;
  final String date;
  final String hospital;
  final int bagCount;
  final int totalBags;
  final bool isRequest;
  final bool isNearest;
  final bool isHomeScreen;
  final double? distance;
  final String uniqueCode;
  final String createdAt;
  final String description;
  final bool isUrgent;
  final void Function()? onTap;

  const BloodCard({
    super.key,
    required this.status,
    required this.bloodType,
    required this.date,
    required this.hospital,
    required this.bagCount,
    required this.totalBags,
    required this.isRequest,
    this.isNearest = false,
    this.isHomeScreen = false,
    required this.uniqueCode,
    this.createdAt = "",
    required this.description,
    this.isUrgent = false,
    this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color titleColor;
    Color borderColor;
    Color backgroundColor;
    String statusText;

    if (status == "cancelled") {
      titleColor = AppTheme.brand_01;
      borderColor = AppTheme.brand_01;
      backgroundColor = const Color(0xFFEAE2E2);
      statusText = isRequest ? "Permintaan Darah Dibatalkan" : "Pendonoran Dibatalkan";
    } else if (status == "completed") {
      titleColor = const Color(0xFF359B5E);
      borderColor = const Color(0xFF359B5E);
      backgroundColor = const Color(0xFFDBE6DF);
      statusText = isRequest ? "Permintaan Darah Selesai" : "Pendonoran Selesai";
    } else {
      titleColor = isNearest ? AppTheme.brand_01 : const Color(0xFFCB9B0A);
      borderColor = AppTheme.brand_02;
      backgroundColor = const Color(0xFFF1EEE5);
      statusText = isRequest
          ? (status == "pending"
          ? "Menunggu Konfirmasi RS/PMI"
          : status == "confirmed"
          ? "Menunggu Kantong Darah Terpenuhi"
          : "Kantong Darah Terpenuhi")
          : "Menunggu Proses Donor";
    }

    double iconSize = isHomeScreen ? 22 : 24;
    double titleFontSize = isHomeScreen ? 16 : 18;
    double expiryDateFontSize = isHomeScreen ? 9.4 : 10;
    double sectionFontSize = isHomeScreen ? 11 : 13;
    double bloodTypeFontSize = isHomeScreen ? 20 : 22;
    double descriptionFontSize = isHomeScreen ? 10 : 11;
    double progressFontSize = isHomeScreen ? 10 : 11;
    double statusFontSize = 12;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 14, right: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRequest ? 'Permintaan Darah Anda' : isNearest ? 'Permintaan Darah Terdekat' : 'Pendonoran Darah Anda',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRequest ? 'Permintaan Berakhir' : 'Donor Sebelum',
                            style: TextStyle(
                              fontSize: expiryDateFontSize,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: expiryDateFontSize,
                              fontWeight: FontWeight.w500,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 0, top: 2),
                    child: Divider(
                      color: Color(0xFFA3A3A3).withValues(alpha: 0.4),
                      thickness: 1,
                      height: 24,
                    ),
                  ),

                  // Grid Content
                  LayoutGrid(
                    columnSizes: [1.fr, 1.fr],
                    rowSizes: [auto, auto],
                    rowGap: 8,
                    children: [
                      // Hospital
                      Row(
                        children: [
                          SvgPicture.string(
                            hospitalSvg,
                            width: iconSize,
                            height: iconSize,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  hospital,
                                  style: TextStyle(
                                    fontSize: sectionFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral_01,
                                  ),
                                ),
                                if (isNearest && distance != null)
                                  Text(
                                    '$distance km dari alamat anda',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: sectionFontSize - 2,
                                      color: AppTheme.neutral_01,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ).withGridPlacement(
                        columnStart: 0,
                        columnSpan: 1,
                        rowStart: 0,
                        rowSpan: 1,
                      ),


                      // Blood Type
                      Row(
                        children: [
                          SvgPicture.string(
                            bloodTypeSvg,
                            width: iconSize,
                            height: iconSize,
                          ),
                          SizedBox(width: 8),
                          Text(
                            bloodType,
                            style: TextStyle(
                              fontSize: bloodTypeFontSize,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ).withGridPlacement(columnStart: 1, columnSpan: 1, rowStart: 0, rowSpan: 1),

                      // Description
                      Row(
                        children: [
                          SvgPicture.string(
                            descriptionSvg,
                            width: iconSize,
                            height: iconSize,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: TextStyle(
                                fontSize: descriptionFontSize,
                                color: AppTheme.neutral_01,
                              ),
                            ),
                          ),
                        ],
                      ).withGridPlacement(columnStart: 0, columnSpan: 1, rowStart: 1, rowSpan: 1),

                      // Progress
                      Row(
                        children: [
                          SvgPicture.string(
                            bloodFilledDescSvg,
                            width: iconSize,
                            height: iconSize,
                          ),
                          SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: progressFontSize,
                                color: AppTheme.neutral_01,
                              ),
                              children: [
                                TextSpan(text: 'Telah terisi '),
                                TextSpan(
                                  text: '$bagCount',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                                TextSpan(text: ' dari '),
                                TextSpan(
                                  text: '$totalBags',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: titleColor,
                                  ),
                                ),
                                TextSpan(text: '\nKantong'),
                                TextSpan(
                                  text: ' yang dibutuhkan',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).withGridPlacement(columnStart: 1, columnSpan: 1, rowStart: 1, rowSpan: 1),
                    ],
                  ),

                  SizedBox(height: isHomeScreen ? 4 : 10),

                  // Status (hide if isHomeScreen)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isNearest)
                        Row(
                          children: [
                            Container(
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: titleColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: titleColor,
                                fontWeight: FontWeight.bold,
                                fontSize: statusFontSize,
                              ),
                            ),
                          ],
                        ),
                      Text(
                        getSelisih(createdAt),
                        style: TextStyle(
                          color: AppTheme.neutral_01.withValues(alpha: 0.5),
                          fontWeight: FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Arrow icon
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: isHomeScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
