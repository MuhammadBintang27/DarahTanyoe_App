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
                            'No user data available',
                            style: TextStyle(fontFamily: 'DM Sans'),
                          ),
                        );
                      }

                      final userData = snapshot.data!;
                      String formattedDate = 'Not available';
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
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage('assets/images/profil.png'),
                                backgroundColor: Colors.grey[200],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userData['full_name'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'DM Sans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatUserType(userData['user_type'] ?? ''),
                                style: TextStyle(
                                  color: Colors.red[800],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'DM Sans',
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoSection(context, 'Personal Information', [
                              _buildInfoItem(context, 'Email', userData['email'] ?? 'Not available'),
                              _buildInfoItem(context, 'Phone', userData['phone_number'] ?? 'Not available'),
                              _buildInfoItem(context, 'Age', userData['age']?.toString() ?? 'Not available'),
                              _buildInfoItem(context, 'Address', userData['address'] ?? 'Not available'),
                            ]),
                            const SizedBox(height: 16),
                            _buildInfoSection(context, 'Donation Information', [
                              _buildInfoItem(context, 'Blood Type', userData['blood_type'] ?? 'Not available'),
                              _buildInfoItem(context, 'Last Donation', formattedDate),
                              _buildInfoItem(context, 'Total Points', userData['total_points']?.toString() ?? '0'),
                              _buildInfoItem(context, 'Health Notes', userData['health_notes'] ?? 'None'),
                            ]),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.brand_01,
                                  side: BorderSide(color: AppTheme.brand_01),
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  _showLogoutConfirmation(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.brand_01,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontFamily: 'DM Sans',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
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
            width: 100,
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
    if (userType.isEmpty) return 'User';

    final words = userType.split('_');
    final capitalizedWords = words.map(
      (word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
    );
    return capitalizedWords.join(' ');
  }

  void _showLogoutConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        content: const Text(
          'Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: 'DM Sans'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: TextStyle(color: AppTheme.brand_01, fontFamily: 'DM Sans'),
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
