import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import '../../components/background_widget.dart';
import '../../service/auth_service.dart';
import '../../widget/header_widget.dart';
import 'edit_profil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

                      // Hitung usia dari date_of_birth
                      int? age;
                      if (userData['date_of_birth'] != null) {
                        try {
                          final dateOfBirth = DateTime.parse(userData['date_of_birth']);
                          final today = DateTime.now();
                          age = today.year - dateOfBirth.year;
                          if (today.month < dateOfBirth.month ||
                              (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
                            age--;
                          }
                        } catch (e) {
                          age = null;
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
                                      color: Colors.grey.withValues(alpha: 0.3),
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
                              _buildInfoItem(context, 'Usia', age != null ? '$age tahun' : 'Tidak tersedia'),
                              _buildInfoItem(context, 'Alamat', userData['address'] ?? 'Tidak tersedia'),
                            ]),
                            const SizedBox(height: 16),
                            _buildInfoSection(context, 'Informasi Donor', [
                              _buildInfoItem(context, 'Golongan Darah', userData['blood_type'] ?? 'Tidak tersedia'),
                              _buildInfoItem(context, 'Donor Terakhir', formattedDate),
                              _buildInfoItem(context, 'Catatan Kesehatan', userData['health_notes'] ?? 'Tidak ada'),
                            ]),
                            const SizedBox(height: 16),
                            _buildNotificationSettings(context, userData),
                            
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfilPage(userData: userData),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.brand_02,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Edit Profil',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showLogoutConfirmation(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.brand_01,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'Keluar',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
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

  Widget _buildNotificationSettings(BuildContext context, Map<String, dynamic> userData) {
    // Hitung apakah user dalam periode 3 bulan setelah donor
    bool isWithin3Months = false;
    int daysLeft = 0;
    
    if (userData['last_donation_date'] != null) {
      try {
        final lastDonation = DateTime.parse(userData['last_donation_date']);
        final nextEligible = lastDonation.add(const Duration(days: 90));
        final today = DateTime.now();
        
        if (nextEligible.isAfter(today)) {
          isWithin3Months = true;
          daysLeft = nextEligible.difference(today).inDays;
        }
      } catch (e) {
        print('Error calculating donation period: $e');
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        // Get notifications_enabled from userData, default true
        bool notificationsEnabled = userData['notifications_enabled'] ?? true;
        
        // Jika dalam periode 3 bulan, force notifikasi menjadi false
        if (isWithin3Months) {
          notificationsEnabled = false;
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(228, 255, 255, 255),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.25),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pengaturan Notifikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'DM Sans',
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: notificationsEnabled,
                      onChanged: isWithin3Months
                          ? null // Disable toggle jika dalam 3 bulan
                          : (value) {
                              // Update local state immediately
                              setState(() {
                                notificationsEnabled = value;
                              });
                              // Update API + localStorage
                              _updateNotificationPreference(
                                context,
                                value,
                                userData['id'],
                                userData,
                              );
                            },
                      activeColor: AppTheme.brand_01,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isWithin3Months
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isWithin3Months
                        ? Colors.orange.withValues(alpha: 0.3)
                        : Colors.blue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isWithin3Months ? Icons.info_outline : Icons.check_circle_outline,
                          size: 20,
                          color: isWithin3Months ? Colors.orange[700] : Colors.blue[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isWithin3Months
                                ? 'Periode Istirahat Donor'
                                : 'Status Notifikasi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'DM Sans',
                              color: isWithin3Months ? Colors.orange[700] : Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isWithin3Months) ...[
                      Text(
                        '⏸️ Notifikasi sedang dimatikan otomatis',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'DM Sans',
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Anda dapat menerima notifikasi dalam $daysLeft hari lagi (${DateTime.parse(userData['last_donation_date']!).add(const Duration(days: 90)).toString().split(' ')[0]})',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'DM Sans',
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Terima kasih telah mendonor! Anda perlu istirahat 3 bulan sebelum dapat mendonor lagi.',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'DM Sans',
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      Text(
                        notificationsEnabled ? '✅ Notifikasi aktif' : '❌ Notifikasi dimatikan',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'DM Sans',
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Anda siap menerima notifikasi permintaan darah',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'DM Sans',
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
            color: Colors.grey.withValues(alpha: 0.25),
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
            shadowColor: Colors.grey.withValues(alpha: 0.3),
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
            shadowColor: AppTheme.brand_01.withValues(alpha: 0.3),
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

  Future<void> _updateNotificationPreference(
    BuildContext context,
    bool enabled,
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl/users/update/$userId');

      print('🔄 Sending notification update: enabled=$enabled');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'notifications_enabled': enabled,
        }),
      );

      print('🔍 DEBUG: Notification update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Notification update successful');
        
        // Update userData map untuk reflect changes immediately
        userData['notifications_enabled'] = enabled;
        
        // Update localStorage
        await AuthService().updateUserData({
          'notifications_enabled': enabled,
        });

        // Handle FCM subscription based on enabled status
        if (!enabled) {
          print('✅ User unsubscribed from notification topics');
        } else {
          print('✅ User subscribed to notification topics');
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(enabled 
                  ? 'Notifikasi diaktifkan ✓' 
                  : 'Notifikasi dimatikan ✓'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to update notification settings: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR updating notifications: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}