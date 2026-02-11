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

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _loadingUser = true;
  bool _notificationsEnabled = true;
  bool _isWithin3Months = false;
  int _daysLeft = 0;
  
  bool? _boolFrom(dynamic v) {
    try {
      if (v == null) return null;
      if (v is bool) return v;
      if (v is String) {
        final s = v.trim().toLowerCase();
        if (s == 'true') return true;
        if (s == 'false') return false;
      }
      if (v is num) return v != 0;
      return null;
    } catch (_) {
      return null;
    }
  }
  
  DateTime? _extractLastDonationDate(dynamic raw) {
    try {
      if (raw == null) return null;
      // String ISO date
      if (raw is String && raw.isNotEmpty) {
        final dt = DateTime.tryParse(raw);
        if (dt != null) return dt.toLocal();
      }
      // Numeric timestamp (seconds or milliseconds)
      if (raw is int) {
        final isMillis = raw > 100000000000; // > 10^11 indicates ms
        return isMillis
            ? DateTime.fromMillisecondsSinceEpoch(raw).toLocal()
            : DateTime.fromMillisecondsSinceEpoch(raw * 1000).toLocal();
      }
      if (raw is double) {
        final v = raw.toInt();
        final isMillis = v > 100000000000;
        return isMillis
            ? DateTime.fromMillisecondsSinceEpoch(v).toLocal()
            : DateTime.fromMillisecondsSinceEpoch(v * 1000).toLocal();
      }
      // Nested map patterns
      if (raw is Map) {
        final candidate = raw['date'] ?? raw['last_donation_date'] ?? raw['value'];
        return _extractLastDonationDate(candidate);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      // Get user id from secure storage (identity only)
      final current = await _authService.getCurrentUser();
      final userId = current?['id'] as String?;

      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _userData = null;
          _loadingUser = false;
        });
        return;
      }

      // Fetch realtime user profile from API (include token if available)
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final cacheBust = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse('$baseUrl/users/$userId?_=$cacheBust');
      final token = await _authService.getAccessToken();
      final headers = {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final resp = await http.get(url, headers: headers);

      Map<String, dynamic>? fetched;
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) {
          // Prefer 'user' key if present
          final userField = decoded['user'];
          if (userField is Map) {
            fetched = Map<String, dynamic>.from(userField);
          } else if (userField is List && userField.isNotEmpty && userField.first is Map) {
            fetched = Map<String, dynamic>.from(userField.first as Map);
          } else {
            // Also support 'data' wrapper or plain object
            final dataField = decoded['data'];
            if (dataField is Map) {
              fetched = Map<String, dynamic>.from(dataField);
            } else if (dataField is List && dataField.isNotEmpty && dataField.first is Map) {
              fetched = Map<String, dynamic>.from(dataField.first as Map);
            } else {
              fetched = Map<String, dynamic>.from(decoded);
            }
          }
        } else if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
          fetched = Map<String, dynamic>.from(decoded.first as Map);
        }
      } else {
        // fallback: use local storage data if API fails
        fetched = current;
      }

      if (!mounted) return;
      setState(() {
        _userData = fetched ?? {};
        _loadingUser = false;
        _notificationsEnabled = _boolFrom(_userData?['notifications_enabled']) ?? true;
        _isWithin3Months = false;
        _daysLeft = 0;
        final rawLast = _userData?['last_donation_date'] ??
            _userData?['lastDonationDate'] ??
            _userData?['last_donation_at'] ??
            _userData?['lastDonationAt'];
        final lastDonation = _extractLastDonationDate(rawLast);
        if (lastDonation != null) {
          final nextEligible = lastDonation.add(const Duration(days: 90));
          final today = DateTime.now();
          if (nextEligible.isAfter(today)) {
            _isWithin3Months = true;
            _daysLeft = nextEligible.difference(today).inDays;
            _notificationsEnabled = false;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userData = null;
        _loadingUser = false;
      });
    }
  }

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
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadUser();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: _loadingUser
                      ? const Center(child: CircularProgressIndicator())
                      : (_userData == null
                          ? const Center(
                              child: Text(
                                'Data pengguna tidak tersedia',
                                style: TextStyle(fontFamily: 'DM Sans'),
                              ),
                            )
                          : Builder(builder: (context) {
                              final userData = _userData!;
                      final rawLast = userData['last_donation_date'] ??
                          userData['lastDonationDate'] ??
                          userData['last_donation_at'] ??
                          userData['lastDonationAt'];
                      final dtLast = _extractLastDonationDate(rawLast);
                        final String formattedDate = dtLast != null
                          ? DateFormat('dd MMM yyyy', 'id').format(dtLast)
                          : 'Tidak tersedia';

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
                            _buildNotificationSettings(context),
                            // Debug panel removed in production
                            
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
                            }))
                  )
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildNotificationSettings(BuildContext context) {
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
                scale: 0.9,
                child: Switch(
                  value: _notificationsEnabled,
                  onChanged: _isWithin3Months
                      ? null
                      : (value) async {
                          // Optimistic UI
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          final ok = await _updateNotificationPreference(
                            context,
                            value,
                            _userData?['id'],
                          );
                          if (!ok && mounted) {
                            // Revert on failure
                            setState(() {
                              _notificationsEnabled = !value;
                            });
                          }
                          // Refresh from API to keep in sync
                          if (ok) {
                            await _loadUser();
                          }
                        },
                  activeColor: AppTheme.brand_01,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Permintaan darah dari PMI akan dikirim sesuai preferensi Anda.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'DM Sans',
            ),
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isWithin3Months
                  ? Colors.orange.withValues(alpha: 0.08)
                  : (_notificationsEnabled
                      ? Colors.green.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.08)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isWithin3Months
                    ? Colors.orange.withValues(alpha: 0.3)
                    : (_notificationsEnabled
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isWithin3Months
                          ? Icons.info_outline
                          : (_notificationsEnabled
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined),
                      size: 20,
                      color: _isWithin3Months
                          ? Colors.orange[700]
                          : (_notificationsEnabled
                              ? Colors.green[700]
                              : Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isWithin3Months
                            ? 'Istirahat Donor'
                            : (_notificationsEnabled
                                ? 'Notifikasi Aktif'
                                : 'Notifikasi Dimatikan'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'DM Sans',
                          color: _isWithin3Months
                              ? Colors.orange[700]
                              : (_notificationsEnabled
                                  ? Colors.green[700]
                                  : Colors.grey[700]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_isWithin3Months) ...[
                  Text(
                    'Notifikasi dimatikan otomatis selama masa istirahat donor.',
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Hingga ${DateFormat('dd MMM yyyy', 'id').format(DateTime.now().add(Duration(days: _daysLeft)))}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                      color: Colors.grey,
                    ),
                  ),
                ] else ...[
                  Text(
                    _notificationsEnabled
                        ? 'Anda akan menerima permintaan darah di sekitar Anda.'
                        : 'Anda tidak akan menerima permintaan darah saat ini.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'DM Sans',
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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

  Future<bool> _updateNotificationPreference(
    BuildContext context,
    bool enabled,
    String? userId,
  ) async {
    if (userId == null || userId.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID pengguna tidak tersedia'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl/users/update/$userId');
      final token = await _authService.getAccessToken();

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notifications_enabled': enabled}),
      );

      if (response.statusCode == 200) {
        // Update local state and storage
        // Try to use server response to avoid stale local data
        try {
          final body = jsonDecode(response.body);
          final serverUser = (body is Map && body['user'] is Map)
              ? Map<String, dynamic>.from(body['user'])
              : null;
          if (serverUser != null) {
            setState(() {
              _userData = serverUser;
              _notificationsEnabled = _boolFrom(serverUser['notifications_enabled']) ?? enabled;
            });
            await AuthService().updateUserData(serverUser);
          } else {
            setState(() {
              _userData?['notifications_enabled'] = enabled;
              _notificationsEnabled = enabled;
            });
            await AuthService().updateUserData({'notifications_enabled': enabled});
          }
        } catch (_) {
          setState(() {
            _userData?['notifications_enabled'] = enabled;
            _notificationsEnabled = enabled;
          });
          await AuthService().updateUserData({'notifications_enabled': enabled});
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
        return true;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Gagal memperbarui pengaturan: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}