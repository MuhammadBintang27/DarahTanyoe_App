import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import '../../components/background_widget.dart';
import '../../service/auth_service.dart';
import '../../widget/header_widget.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + 56;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              HeaderWidget(),
              Expanded(
                child: SingleChildScrollView(
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _authService.getCurrentUser(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(fontFamily: 'DM Sans'),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                          child: Text(
                            'Data pengguna tidak tersedia',
                            style: TextStyle(fontFamily: 'DM Sans'),
                          ),
                        );
                      }

                      final userData = snapshot.data!;
                      String formattedDate = 'Tidak tersedia';
                      if (userData['last_donation_date'] != null) {
                        try {
                          final date = DateTime.parse(userData['last_donation_date']);
                          formattedDate = DateFormat('dd MMM yyyy').format(date);
                        } catch (e) {
                          formattedDate = userData['last_donation_date'];
                        }
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: bottomNavHeight + 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userData['full_name'] ?? 'Pengguna',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                            const SizedBox(height: 8),
                          
                            const SizedBox(height: 24),
                            _buildInfoSection(context, 'Informasi Pribadi', [
                              _buildInfoItem(context, 'Email', userData['email'] ?? 'Tidak tersedia'),
                              _buildInfoItem(context, 'Telepon', userData['phone_number'] ?? 'Tidak tersedia'),
                              _buildInfoItem(context, 'Usia', userData['age']?.toString() ?? 'Tidak tersedia'),
                              _buildInfoItem(context, 'Alamat', userData['address'] ?? 'Tidak tersedia'),
                            ]),
                            const SizedBox(height: 16),
                            _buildInfoSection(context, 'Informasi Donor', [
                              _buildInfoItem(context, 'Golongan Darah', userData['blood_type'] ?? 'Tidak tersedia'),
                              _buildInfoItem(context, 'Donor Terakhir', formattedDate),
                              _buildInfoItem(context, 'Catatan Kesehatan', userData['health_notes'] ?? 'Tidak ada'),
                            ]),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 4,
                                  shadowColor: Colors.grey.withOpacity(0.4),
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppTheme.brand_01),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Edit Profil',
                                          style: TextStyle(
                                            fontFamily: 'DM Sans',
                                            color: AppTheme.brand_01,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.brand_01.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: AppTheme.brand_01,
                                  borderRadius: BorderRadius.circular(20),
                                  elevation: 4,
                                  shadowColor: AppTheme.brand_01.withOpacity(0.5),
                                  child: InkWell(
                                    onTap: () {
                                      _showLogoutConfirmation(context);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      height: 50,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'Keluar',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(228, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Sans',
            ),
          ),
          const Divider(height: 24),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                fontFamily: 'DM Sans',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUserType(String userType) {
    if (userType.isEmpty) return 'Pengguna';

    // Pemetaan tipe pengguna dari bahasa Inggris ke Indonesia
    final Map<String, String> userTypeMapping = {
      'donor': 'Pendonor',
      'recipient': 'Penerima',
      'admin': 'Admin',
      'blood_bank': 'Bank Darah',
      'hospital': 'Rumah Sakit',
      'user': 'Pengguna',
    };

    final words = userType.split('_');
    if (userTypeMapping.containsKey(userType)) {
      return userTypeMapping[userType]!;
    } else {
      final capitalizedWords = words.map(
        (word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
      );
      return capitalizedWords.join(' ');
    }
  }

  void _showLogoutConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        content: const Text(
          'Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          Material(
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            shadowColor: Colors.grey.withOpacity(0.3),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(fontFamily: 'DM Sans'),
              ),
            ),
          ),
          Material(
            borderRadius: BorderRadius.circular(20),
            elevation: 2,
            shadowColor: AppTheme.brand_01.withOpacity(0.3),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Keluar',
                style: TextStyle(color: AppTheme.brand_01, fontFamily: 'DM Sans'),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout(context);
    }
  }
}