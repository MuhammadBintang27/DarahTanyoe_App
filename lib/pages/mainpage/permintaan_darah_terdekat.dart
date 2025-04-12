import 'dart:convert';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/bloodCard.dart';
import 'package:darahtanyoe_app/components/loadingIndicator.dart';
import 'package:darahtanyoe_app/helpers/formatDateTime.dart';
import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/pages/detail_permintaan/detail_permintaan_darah.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:intl/intl.dart';
import '../../service/permintaan_terdekat.dart';

class NearestBloodDonation extends StatefulWidget {
  final String? uniqueCode;

  const NearestBloodDonation({super.key, this.uniqueCode});

  @override
  State<NearestBloodDonation> createState() => _NearestBloodDonationState();
}

class _NearestBloodDonationState extends State<NearestBloodDonation> {
  bool isLoading = true;
  List<PermintaanDarahModel> permintaanList = [];

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BackgroundWidget(
          child: Column(
            children: [
              HeaderWidget(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Permintaan Darah Terdekat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral_01,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
              child: Divider(color: Colors.black26, thickness: 0.8),
            ),
            _buildRequestContent(),
            const SizedBox(height: 64)
          ],
        ),
      ),
    );
  }

  Widget _buildRequestContent() {
    return FutureBuilder<List<PermintaanDarahModel>>(
      future: _getNearbyBloodRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        } else if (snapshot.hasError) {
          // Tampilkan SnackBar untuk error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${snapshot.error.toString()}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
                action: SnackBarAction(
                  label: 'Tutup',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          });

          // Tampilkan UI untuk data kosong
          return _buildEmptyRequestUI();
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyRequestUI();
        }

        // Data berhasil dimuat
        List<PermintaanDarahModel> permintaanList = snapshot.data!;

        return Column(
          children: permintaanList.map((permintaan) {
            String formattedDate = formatDateTime(permintaan.expiry_date);
            int bagCount = permintaan.bloodBagsFulfilled;
            int totalBags = permintaan.bloodBagsNeeded;

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: BloodCard(
                status: permintaan.status,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => DetailPermintaanDarah(
                        permintaan: permintaan,
                      ),
                    ),
                  );
                },
                createdAt: permintaan.createdAt!,
                bloodType: permintaan.bloodType,
                date: formattedDate,
                hospital: permintaan.partner_name,
                bagCount: bagCount,
                totalBags: totalBags,
                isNearest: true,
                isRequest: true,
                distance: permintaan.distance,
                uniqueCode: permintaan.uniqueCode,
                description: (permintaan.description.isNotEmpty) ? permintaan.description : '-',
              ),
            );
          }).toList(),
        );
      },
    );
  }

// Helper function untuk mendapatkan data
  Future<List<PermintaanDarahModel>> _getNearbyBloodRequests() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user == null || user['id'] == null) {
        throw Exception('User tidak ditemukan atau belum login');
      }

      final String userId = user['id'];
      return await PermintaanTerdekat().fetchBloodRequests(userId);
    } catch (e) {
      throw Exception('Gagal mengambil data permintaan darah: $e');
    }
  }

// Extract widget untuk tampilan kosong menjadi function terpisah
  Widget _buildEmptyRequestUI() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype_outlined, size: 80, color: Colors.grey[400]),
            SizedBox(height: 24),
            Text(
              "Belum ada permintaan darah terdekat",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                "Permintaan darah di sekitar Anda akan muncul di sini",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
