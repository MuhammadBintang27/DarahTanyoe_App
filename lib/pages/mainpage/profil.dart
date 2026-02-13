import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import '../../components/background_widget.dart';
import '../../service/auth_service.dart';
import '../../service/toast_service.dart';
import '../../widget/header_widget.dart';
import 'edit_profil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ============================================================================
// MODELS & DATA CLASSES
// ============================================================================

class UserProfile {
  final String? id;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? bloodType;
  final String? address;
  final String? healthNotes;
  final DateTime? dateOfBirth;
  final DateTime? lastDonationDate;
  final bool notificationsEnabled;

  UserProfile({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.bloodType,
    this.address,
    this.healthNotes,
    this.dateOfBirth,
    this.lastDonationDate,
    this.notificationsEnabled = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString(),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      bloodType: json['blood_type']?.toString(),
      address: json['address']?.toString(),
      healthNotes: json['health_notes']?.toString(),
      dateOfBirth: _parseDate(json['date_of_birth']),
      lastDonationDate: _extractLastDonationDate(
        json['last_donation_date'] ??
            json['lastDonationDate'] ??
            json['last_donation_at'] ??
            json['lastDonationAt'],
      ),
      notificationsEnabled: _parseBool(json['notifications_enabled']) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'blood_type': bloodType,
      'address': address,
      'health_notes': healthNotes,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'last_donation_date': lastDonationDate?.toIso8601String(),
      'notifications_enabled': notificationsEnabled,
    };
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int calculatedAge = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  DonorStatus get donorStatus {
    if (lastDonationDate == null) {
      return DonorStatus(isEligible: true, daysUntilEligible: 0);
    }

    final nextEligibleDate = lastDonationDate!.add(const Duration(days: 90));
    final today = DateTime.now();

    if (nextEligibleDate.isAfter(today)) {
      final daysLeft = nextEligibleDate.difference(today).inDays;
      return DonorStatus(
        isEligible: false,
        daysUntilEligible: daysLeft,
        nextEligibleDate: nextEligibleDate,
      );
    }

    return DonorStatus(isEligible: true, daysUntilEligible: 0);
  }

  String get formattedLastDonation {
    if (lastDonationDate == null) return 'Tidak tersedia';
    return DateFormat('dd MMM yyyy', 'id').format(lastDonationDate!);
  }

  // Helper methods
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

  static DateTime? _extractLastDonationDate(dynamic raw) {
    try {
      if (raw == null) return null;

      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw)?.toLocal();
      }

      if (raw is int) {
        final isMillis = raw > 100000000000;
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

      if (raw is Map) {
        final candidate =
            raw['date'] ?? raw['last_donation_date'] ?? raw['value'];
        return _extractLastDonationDate(candidate);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final s = value.trim().toLowerCase();
      if (s == 'true') return true;
      if (s == 'false') return false;
    }
    if (value is num) return value != 0;
    return null;
  }
}

class DonorStatus {
  final bool isEligible;
  final int daysUntilEligible;
  final DateTime? nextEligibleDate;

  DonorStatus({
    required this.isEligible,
    required this.daysUntilEligible,
    this.nextEligibleDate,
  });
}

// ============================================================================
// MAIN PROFILE SCREEN
// ============================================================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final current = await _authService.getCurrentUser();
      final userId = current?['id'] as String?;

      if (userId == null || userId.isEmpty) {
        setState(() {
          _errorMessage = 'ID pengguna tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      final profile = await _fetchUserProfile(userId);

      if (!mounted) return;

      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal memuat profil: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<UserProfile> _fetchUserProfile(String userId) async {
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

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final userData = _extractUserData(decoded);
      return UserProfile.fromJson(userData);
    } else {
      // Fallback to local storage
      final current = await _authService.getCurrentUser();
      if (current != null) {
        return UserProfile.fromJson(current);
      }
      throw Exception('Gagal memuat data pengguna');
    }
  }

  Map<String, dynamic> _extractUserData(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      // Try 'user' key first
      if (decoded['user'] is Map) {
        return Map<String, dynamic>.from(decoded['user']);
      }
      if (decoded['user'] is List &&
          (decoded['user'] as List).isNotEmpty &&
          (decoded['user'] as List).first is Map) {
        return Map<String, dynamic>.from((decoded['user'] as List).first);
      }
      // Try 'data' key
      if (decoded['data'] is Map) {
        return Map<String, dynamic>.from(decoded['data']);
      }
      if (decoded['data'] is List &&
          (decoded['data'] as List).isNotEmpty &&
          (decoded['data'] as List).first is Map) {
        return Map<String, dynamic>.from((decoded['data'] as List).first);
      }
      // Use decoded directly
      return decoded;
    }
    if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
      return Map<String, dynamic>.from(decoded.first);
    }
    return {};
  }

  Future<void> _updateNotificationPreference(bool enabled) async {
    if (_userProfile?.id == null) {
      ToastService.showError(
        context,
        message: 'ID pengguna tidak tersedia',
      );
      return;
    }

    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl/users/update/${_userProfile!.id}');
      final token = await _authService.getAccessToken();

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'notifications_enabled': enabled}),
      );

      if (response.statusCode == 200) {
        // Update local state
        final body = jsonDecode(response.body);
        final serverUser = (body is Map && body['user'] is Map)
            ? Map<String, dynamic>.from(body['user'])
            : null;

        if (serverUser != null) {
          await _authService.updateUserData(serverUser);
          setState(() {
            _userProfile = UserProfile.fromJson(serverUser);
          });
        } else {
          await _authService.updateUserData({'notifications_enabled': enabled});
          setState(() {
            _userProfile = UserProfile.fromJson({
              ..._userProfile!.toJson(),
              'notifications_enabled': enabled,
            });
          });
        }

        ToastService.showSuccess(
          context,
          message: enabled ? 'Notifikasi diaktifkan ✓' : 'Notifikasi dimatikan ✓',
        );
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      ToastService.showError(
        context,
        message: 'Gagal memperbarui pengaturan: $e',
      );
      // Revert UI
      await _loadUserProfile();
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontFamily: 'DM Sans', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(fontFamily: 'DM Sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brand_01,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final bottomNavHeight = MediaQuery.of(context).padding.bottom + 56;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            children: [
              const HeaderWidget(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: _buildContent(bottomNavHeight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(double bottomPadding) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUserProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brand_02,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(
        child: Text(
          'Data pengguna tidak tersedia',
          style: TextStyle(fontFamily: 'DM Sans', color: Colors.white),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding + 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _ProfileHeader(profile: _userProfile!),
            const SizedBox(height: 24),
            _PersonalInfoSection(profile: _userProfile!),
            const SizedBox(height: 16),
            _DonorInfoSection(profile: _userProfile!),
            const SizedBox(height: 16),
            _NotificationSettings(
              profile: _userProfile!,
              onToggle: (enabled) async {
                // Optimistic update
                final oldProfile = _userProfile;
                setState(() {
                  _userProfile = UserProfile.fromJson({
                    ..._userProfile!.toJson(),
                    'notifications_enabled': enabled,
                  });
                });

                try {
                  await _updateNotificationPreference(enabled);
                } catch (e) {
                  // Revert on error
                  setState(() {
                    _userProfile = oldProfile;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            _ActionButtons(
              onEditProfile: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilPage(
                      userData: _userProfile!.toJson(),
                    ),
                  ),
                );
                if (result == true) {
                  _loadUserProfile();
                }
              },
              onLogout: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// UI COMPONENTS
// ============================================================================

class _ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Avatar
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            size: 70,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 16),

        // Name
        Text(
          profile.fullName ?? 'Pengguna',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'DM Sans',
            color: Colors.black,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Badges
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _Badge(
              icon: Icons.bloodtype,
              label: profile.bloodType ?? 'N/A',
              color: AppTheme.brand_01,
            ),
            _Badge(
              icon: profile.donorStatus.isEligible
                  ? Icons.check_circle_outline
                  : Icons.pause_circle_outline,
              label:
                  profile.donorStatus.isEligible ? 'Donor Aktif' : 'Istirahat',
              color:
                  profile.donorStatus.isEligible ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'DM Sans',
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  final UserProfile profile;

  const _PersonalInfoSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral_01.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pribadi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Sans',
              color: AppTheme.neutral_02,
            ),
          ),
          const SizedBox(height: 20),
          // Grid 2x2
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: profile.email ?? 'Tidak tersedia',
                  color: AppTheme.brand_02,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: profile.phoneNumber ?? 'Tidak tersedia',
                  color: AppTheme.brand_02,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.cake_outlined,
                  label: 'Usia',
                  value: profile.age != null
                      ? '${profile.age} tahun'
                      : 'Tidak tersedia',
                  color: AppTheme.brand_02,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: profile.address ?? 'Tidak tersedia',
                  color: AppTheme.brand_02,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Info card for grid layout
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.neutral_01,
              fontSize: 12,
              fontFamily: 'DM Sans',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              fontFamily: 'DM Sans',
              color: AppTheme.neutral_02,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DonorInfoSection extends StatelessWidget {
  final UserProfile profile;

  const _DonorInfoSection({required this.profile});

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength).trim()}...';
  }

  @override
  Widget build(BuildContext context) {
    final donorStatus = profile.donorStatus;
    final isWithin3Months = !donorStatus.isEligible;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral_01.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Donor',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Sans',
              color: AppTheme.neutral_02,
            ),
          ),
          const SizedBox(height: 20),
          // Two Panel Layout
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.neutral_01.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.neutral_03.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Panel Kiri - Countdown
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isWithin3Months
                            ? AppTheme.brand_02.withOpacity(0.08)
                            : AppTheme.brand_03.withOpacity(0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isWithin3Months) ...[
                            Text(
                              'Bisa donor lagi dalam',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'DM Sans',
                                color: AppTheme.neutral_01,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${donorStatus.daysUntilEligible}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'DM Sans',
                                    color: AppTheme.brand_02,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'hari',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'DM Sans',
                                      color: AppTheme.neutral_01,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.brand_03,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Siap donor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'DM Sans',
                                color: AppTheme.brand_03,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Divider vertikal
                  Container(
                    width: 1,
                    color: AppTheme.neutral_03.withOpacity(0.3),
                  ),
                  // Panel Kanan - Info Detail
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Donor Terakhir
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Donor Terakhir',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                  color: AppTheme.neutral_01,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _truncateText(profile.formattedLastDonation, 18),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'DM Sans',
                                  color: AppTheme.neutral_02,
                                ),
                              ),
                            ],
                          ),
                          // Divider horizontal
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            height: 1,
                            color: AppTheme.neutral_03.withOpacity(0.3),
                          ),
                          // Catatan Kesehatan
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Catatan Kesehatan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'DM Sans',
                                  color: AppTheme.neutral_01,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _truncateText(profile.healthNotes ?? 'Tidak ada catatan', 35),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'DM Sans',
                                  color: AppTheme.neutral_02,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSettings extends StatelessWidget {
  final UserProfile profile;
  final Function(bool) onToggle;

  const _NotificationSettings({
    required this.profile,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final donorStatus = profile.donorStatus;
    final isWithin3Months = !donorStatus.isEligible;
    final canToggle = !isWithin3Months;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neutral_01.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'DM Sans',
              color: AppTheme.neutral_02,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifikasi Permintaan Darah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'DM Sans',
                        color: AppTheme.neutral_02,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canToggle 
                          ? 'Terima notifikasi untuk permintaan donor darah'
                          : 'Nonaktif karena dalam periode donor (${donorStatus.daysUntilEligible} hari lagi)',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'DM Sans',
                        color: AppTheme.neutral_01,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: profile.notificationsEnabled && canToggle,
                  onChanged: canToggle ? onToggle : null,
                  activeColor: AppTheme.brand_01,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
         
          _NotificationStatusCard(
            profile: profile,
            isWithin3Months: isWithin3Months,
            daysUntilEligible: donorStatus.daysUntilEligible,
            nextEligibleDate: donorStatus.nextEligibleDate,
          ),
        ],
      ),
    );
  }
}

class _NotificationStatusCard extends StatelessWidget {
  final UserProfile profile;
  final bool isWithin3Months;
  final int daysUntilEligible;
  final DateTime? nextEligibleDate;

  const _NotificationStatusCard({
    required this.profile,
    required this.isWithin3Months,
    required this.daysUntilEligible,
    this.nextEligibleDate,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWithin3Months
        ? Colors.orange
        : (profile.notificationsEnabled ? Colors.green : Colors.grey);

    final icon = isWithin3Months
        ? Icons.info_outline
        : (profile.notificationsEnabled
            ? Icons.notifications_active_outlined
            : Icons.notifications_off_outlined);

    final title = isWithin3Months
        ? 'Istirahat Donor'
        : (profile.notificationsEnabled
            ? 'Notifikasi Aktif'
            : 'Notifikasi Dimatikan');

    final description = isWithin3Months
        ? 'Notifikasi dimatikan otomatis selama masa istirahat donor.'
        : (profile.notificationsEnabled
            ? 'Anda akan menerima permintaan darah di sekitar Anda.'
            : 'Anda tidak akan menerima permintaan darah saat ini.');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'DM Sans',
                    color: color[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isWithin3Months && nextEligibleDate != null) ...[
            const SizedBox(height: 6),
            Text(
              'Hingga ${DateFormat('dd MMM yyyy', 'id').format(nextEligibleDate!)}',
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'DM Sans',
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const _ActionButtons({
    required this.onEditProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onEditProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.brand_02,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.brand_01,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.brand_01, width: 2),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: AppTheme.brand_01, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      color: AppTheme.brand_01,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}