import 'dart:convert';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:darahtanyoe_app/components/loadingIndicator.dart';
import 'package:darahtanyoe_app/pages/detail_donor_confirmation/donor_confirmation_detail.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:darahtanyoe_app/models/donor_confirmation_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:darahtanyoe_app/service/institution_service.dart';

class TransactionBlood extends StatefulWidget {
  final String? defaultTab;
  final String? uniqueCode;

  const TransactionBlood({super.key, this.uniqueCode, this.defaultTab});

  @override
  State<TransactionBlood> createState() => _TransactionBloodState();
}

class _TransactionBloodState extends State<TransactionBlood> {
  // Track which tab is selected
  // true = "Sedang Berlangsung" (active confirmations), false = "Selesai" (completed confirmations)
  bool isBerlangsungTab = true;
  bool isLoading = false;
  // Cache nama PMI berdasarkan pmiId untuk Donor Biasa
  final Map<String, String> _pmiNameCache = {};
  // Golongan darah pendonor (untuk Donor Biasa)
  String? _currentUserBloodType;

  // Lists for storing donor confirmation data
  List<DonorConfirmationModel> berlangsungList = [];
  List<DonorConfirmationModel> selesaiList = [];

  @override
  void initState() {
    super.initState();
    _ensureCurrentUserBloodType();
    _loadBerlangsung();
  }

  Future<void> _ensureCurrentUserBloodType() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUserBloodType = user?['blood_type']?.toString();
        });
      }
    } catch (_) {
      // ignore
    }
  }

  // ✅ Show error message via SnackBar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ✅ NEW: Load active confirmations (Sedang Berlangsung)
  Future<void> _loadBerlangsung() async {
    setState(() => isLoading = true);

    try {
      final user = await AuthService().getCurrentUser();
      if (user?['id'] == null) {
        _showError("Anda belum login atau pengguna tidak ditemukan.");
        setState(() => isLoading = false);
        return;
      }

      final donorId = user!['id'] as String;
      final String baseUrl = dotenv.env['BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl/fulfillment/donor/$donorId/confirmations?status=active');

      print('🔍 Fetching berlangsung from: $url');

      final response = await http.get(url);

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        
        print('✅ Loaded ${data.length} active confirmations');

        if (mounted) {
          setState(() {
            berlangsungList = data
                .map((item) => DonorConfirmationModel.fromJson(item))
                .toList();
            // Prefetch nama PMI untuk donor biasa
            final ids = berlangsungList
                .map((c) => c.pmiId)
                .where((id) => id != null && id!.isNotEmpty)
                .cast<String>()
                .toSet();
            for (final id in ids) {
              _ensurePmiName(id);
            }
            isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading berlangsung: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showError("Gagal memuat data pendonoran: $e");
      }
    }
  }

  // ✅ NEW: Load completed confirmations (Selesai)
  Future<void> _loadSelesai() async {
    setState(() => isLoading = true);

    try {
      final user = await AuthService().getCurrentUser();
      if (user?['id'] == null) {
        _showError("Anda belum login atau pengguna tidak ditemukan.");
        setState(() => isLoading = false);
        return;
      }

      final donorId = user!['id'] as String;
      final String baseUrl = dotenv.env['BASE_URL'] ?? '';
      final url = Uri.parse('$baseUrl/fulfillment/donor/$donorId/confirmations?status=completed');

      print('🔍 Fetching selesai from: $url');

      final response = await http.get(url);

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        
        print('✅ Loaded ${data.length} completed confirmations');

        if (mounted) {
          setState(() {
            selesaiList = data
                .map((item) => DonorConfirmationModel.fromJson(item))
                .toList();
            final ids = selesaiList
                .map((c) => c.pmiId)
                .where((id) => id != null && id!.isNotEmpty)
                .cast<String>()
                .toSet();
            for (final id in ids) {
              _ensurePmiName(id);
            }
            isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading selesai: $e');
      if (mounted) {
        setState(() => isLoading = false);
        _showError("Gagal memuat data pendonoran: $e");
      }
    }
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
                child: _buildTransactionBody(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionBody() {
    return Column(
      children: [
        // Header - Not scrollable
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaksi Anda',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral_01,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Divider(color: Colors.black26, thickness: 0.8),
              ),
            ],
          ),
        ),

        // Sticky Tab Buttons
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
          padding: const EdgeInsets.symmetric(horizontal: 2.6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: Colors.black87.withValues(alpha: 0.25),
                blurRadius: 3,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isBerlangsungTab = true;
                      _loadBerlangsung();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    backgroundColor: isBerlangsungTab
                        ? AppTheme.brand_01
                        : Colors.transparent,
                    foregroundColor: isBerlangsungTab
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(9),
                        right: Radius.circular(9),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Sedang Berlangsung',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isBerlangsungTab = false;
                      _loadSelesai();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    backgroundColor: !isBerlangsungTab
                        ? AppTheme.brand_01
                        : Colors.transparent,
                    foregroundColor: !isBerlangsungTab
                        ? Colors.white
                        : Colors.black.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(9),
                        right: Radius.circular(9),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isBerlangsungTab
                  ? _buildBerlangsungContent()
                  : _buildSelesaiContent(),
            ),
          ),
        ),
      ],
    );
  }

  // Build Sedang Berlangsung content
  Widget _buildBerlangsungContent() {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (berlangsungList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.neutral_01.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pendonoran sedang berlangsung',
              style: TextStyle(
                color: AppTheme.neutral_01.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: berlangsungList.length,
      itemBuilder: (context, index) {
        final confirmation = berlangsungList[index];
        return _buildDonationCard(confirmation);
      },
    );
  }

  // Build Selesai content
  Widget _buildSelesaiContent() {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (selesaiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppTheme.neutral_01.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada pendonoran yang selesai',
              style: TextStyle(
                color: AppTheme.neutral_01.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: selesaiList.length,
      itemBuilder: (context, index) {
        final confirmation = selesaiList[index];
        return _buildDonationCard(confirmation);
      },
    );
  }
  Widget _buildDonationCard(DonorConfirmationModel confirmation) {
    final bool isDonorBiasa = (confirmation.confirmationOrigin == 'donor_biasa');
    final String pmiName = isDonorBiasa ? (_pmiNameCache[confirmation.pmiId] ?? 'PMI Tujuan') : '';
    final String displayBloodType = isDonorBiasa
        ? (_currentUserBloodType ?? 'N/A')
        : (confirmation.patientBloodType ?? 'N/A');
    // Determine colors based on status
    Color titleColor;
    Color borderColor;
    Color backgroundColor;
    String statusText;

    if (confirmation.status == 'completed') {
      titleColor = const Color(0xFF359B5E); // Green
      borderColor = const Color(0xFF359B5E);
      backgroundColor = const Color(0xFFDBE6DF);
      statusText = 'Pendonoran Selesai';
    } else if (confirmation.status == 'rejected' || confirmation.status == 'expired' || confirmation.status == 'cancelled') {
      titleColor = const Color(0xFFAB4545); // Red
      borderColor = const Color(0xFFAB4545);
      backgroundColor = const Color(0xFFEAE2E2);
      if (confirmation.status == 'rejected') {
        statusText = 'Pendonoran Ditolak';
      } else if (confirmation.status == 'cancelled') {
        statusText = 'Pendonoran Dibatalkan';
      } else {
        statusText = 'Kadaluarsa';
      }
    } else {
      // Active/pending - Yellow
      titleColor = const Color(0xFFCB9B0A);
      borderColor = AppTheme.brand_02;
      backgroundColor = const Color(0xFFF1EEE5);
      statusText = 'Pendonoran Sedang Berlangsung';
    }

    return GestureDetector(
      onTap: () => _navigateToDonationDetail(confirmation),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 12, left: 14, right: 14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pendonoran Darah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDonorBiasa ? 'Donor Biasa' : (confirmation.patientName ?? 'Nama Pasien'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.neutral_01,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Golongan darah',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: titleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bloodtype_outlined,
                                size: 20,
                                color: titleColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                displayBloodType,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: titleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 0, top: 8),
                  child: Divider(
                    color: const Color(0xFFA3A3A3).withOpacity(0.4),
                    thickness: 1,
                    height: 16,
                  ),
                ),

                // Grid Content Row 1: Location + Progress
                Row(
                  children: [
                    // Location (left)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 24,
                              color: AppTheme.neutral_01),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isDonorBiasa
                                    ? pmiName
                                    : (confirmation.campaignLocation != null
                                      ? confirmation.campaignLocation!.split(',').first
                                      : 'Lokasi'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.neutral_01,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isDonorBiasa
                                    ? '${confirmation.distanceKm?.toStringAsFixed(1) ?? '?'} KM dari lokasi anda'
                                    : '${confirmation.distanceKm?.toStringAsFixed(1) ?? '?'} KM dari lokasi anda',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 11,
                                    color: AppTheme.neutral_01,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Progress (right)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 24,
                              color: titleColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.neutral_01,
                                  fontFamily: 'DM Sans',
                                ),
                                children: [
                                  const TextSpan(text: 'Telah terisi '),
                                  TextSpan(
                                    text: '${confirmation.fulfillmentRequest?.quantityCollected ?? 0}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: titleColor,
                                    ),
                                  ),
                                  const TextSpan(text: ' dari '),
                                  TextSpan(
                                    text: '${confirmation.fulfillmentRequest?.quantityNeeded ?? 0}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: titleColor,
                                    ),
                                  ),
                                  const TextSpan(text: '\nKantong'),
                                  TextSpan(
                                    text: ' yang dibutuhkan',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Grid Row 2: Description + Unique Code
                Row(
                  children: [
                    // Description (left)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.description_outlined,
                              size: 24,
                              color: AppTheme.neutral_01),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isDonorBiasa
                                  ? 'Donor terjadwal di PMI yang Anda pilih. Mohon hadir sesuai jadwal, membawa identitas, dan pastikan kondisi sehat sebelum donor.'
                                  : (confirmation.campaign?.description ?? 'Deskripsi tidak tersedia'),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.neutral_01,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Kode Unik (right)
                    if (confirmation.uniqueCode != null)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: titleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: titleColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kode Unik',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                confirmation.uniqueCode!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Status
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
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
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
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _ensurePmiName(String id) async {
    if (_pmiNameCache.containsKey(id)) return;
    try {
      final inst = await InstitutionService.getInstitutionById(id);
      final name = inst?['institution_name']?.toString();
      if (name != null && name.isNotEmpty && mounted) {
        setState(() {
          _pmiNameCache[id] = name;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  // ✅ NEW: Navigate to donation detail page
  void _navigateToDonationDetail(DonorConfirmationModel confirmation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DonorConfirmationDetail(confirmation: confirmation),
      ),
    );
  }
}
