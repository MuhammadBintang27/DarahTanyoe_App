import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/service/toast_service.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../service/auth_service.dart';
import '../../service/animation_service.dart';
import '../../service/notification_service.dart' as notif_service;
import '../../service/campaign_service.dart';
import '../../models/notification_model.dart';
import '../detail_permintaan/detail_permintaan_darah.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class NotificationPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const NotificationPage({
    super.key,
    this.onBackPressed,
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _timedOut = false;
  Timer? _loadingTimer;
  bool _hasLoaded = false; // Flag untuk ensure load hanya sekali
  
  // Simpan future untuk mendapatkan user dalam state
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    // Inisialisasi future untuk mendapatkan user
    _userFuture = AuthService().getCurrentUser();
  }

  @override
  void dispose() {
    // Cancel any active timers
    _loadingTimer?.cancel();
    super.dispose();
  }

  // Helper to get icon based on notification type
  IconData _getIconForNotification(NotificationModel notification) {
    switch (notification.type) {
      case 'donation':
        return Icons.volunteer_activism_outlined;
      case 'pickup':
        return Icons.local_shipping_outlined;
      case 'stock':
        return Icons.inventory_2_outlined;
      case 'campaign':
        return Icons.campaign_outlined;
      case 'request':
        return Icons.water_drop_outlined;
      case 'system':
        return Icons.info_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  // Helper to format time ago
  String _getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'baru';
    }
  }

  // Get count of unread notifications
  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  // Load notifications from API
  Future<void> _loadNotifications(String userId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _timedOut = false;
    });

    try {
      final notifications = await notif_service.NotificationService.getNotifications(userId, includeRead: false);
      
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
          _timedOut = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat notifikasi. Silakan coba lagi.';
          _isLoading = false;
          _timedOut = false;
        });
      }
    }
  }

  // Mark notification as read
  Future<void> _markAsRead(String notificationId, String userId) async {
    // Call API to mark as read
    try {
      await notif_service.NotificationService.markAsRead(notificationId);
      
      // Update UI after successful API call
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((item) {
            if (item.id == notificationId) {
              // Create new notification with isRead = true
              return NotificationModel(
                id: item.id,
                userId: item.userId,
                institutionId: item.institutionId,
                title: item.title,
                message: item.message,
                type: item.type,
                priority: item.priority,
                relatedId: item.relatedId,
                relatedType: item.relatedType,
                isRead: true,
                readAt: item.readAt,
                actionUrl: item.actionUrl,
                actionLabel: item.actionLabel,
                imageUrl: item.imageUrl,
                pushSent: item.pushSent,
                emailSent: item.emailSent,
                smsSent: item.smsSent,
                expiresAt: item.expiresAt,
                metadata: item.metadata,
                createdAt: item.createdAt,
              );
            }
            return item;
          }).toList();
        });
      }
    } catch (e) {
      // Intentionally empty - notification action error is non-blocking
    }
  }

  // Handle notification tap - check campaign status
  Future<void> _handleNotificationTap(NotificationModel notification, String userId) async {
    // Mark as read
    _markAsRead(notification.id, userId);

    if (notification.relatedType == 'blood_campaign' && notification.relatedId != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAB4545)),
          ),
        ),
      );

      try {
        // Fetch campaign details using CampaignService
        final campaign = await CampaignService.getCampaignById(notification.relatedId!);

        // Dismiss loading dialog
        if (mounted) Navigator.of(context).pop();

        if (campaign != null) {
          if (!mounted) return;

          final status = campaign.status ?? 'unknown';

          if (status == 'completed' || status == 'cancelled') {
            // Campaign sudah tidak active
            AnimationService.showCampaignUnavailable(context, status: status);
          } else if (status == 'active' || status == 'draft') {
            // Campaign masih active, navigate to detail page
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailPermintaanDarah(permintaan: campaign),
              ),
            );
          }
        } else {
          // API error - campaign not found
          if (mounted) {
            ToastService.showError(context, message: 'Gagal memuat data permintaan darah');
          }
        }
      } catch (e) {
        // Dismiss loading dialog jika masih ada
        if (mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          ToastService.showError(context, message: 'Terjadi kesalahan saat memuat data');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar dengan warna putih dan ikon hitam
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light, // Untuk iOS
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            // Notification bell with badge
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF333333)),
                  onPressed: () {}, // Already on notification page
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFA83838),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (context, snapshot) {
              // Jika data sedang dimuat
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAB4545)),
                  ),
                );
              }
              
              // Jika data sudah selesai dimuat dan data tersedia
              if (snapshot.hasData && snapshot.data != null) {
                // Ambil userId dari data pengguna
                final String userId = snapshot.data!['id'] ?? '';
                
                // Load notifications hanya sekali untuk userId ini
                if (!_hasLoaded && userId.isNotEmpty) {
                  _hasLoaded = true;
                  Future.microtask(() => _loadNotifications(userId));
                }
                
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.4), // Lebih transparan agar motif batik lebih terlihat
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
                            // Unread count header
                            if (_notifications.isNotEmpty && !_isLoading)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      _unreadCount > 0
                                          ? 'Anda memiliki $_unreadCount notifikasi baru'
                                          : 'Semua notifikasi telah dibaca',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (_unreadCount > 0)
                                      const Spacer(),
                                    if (_unreadCount > 0)
                                      GestureDetector(
                                        onTap: () {
                                          // Mark all as read
                                          for (var notification in _notifications.where((n) => !n.isRead)) {
                                            _markAsRead(notification.id, userId);
                                          }
                                        },
                                        child: const Text(
                                          'Tandai semua dibaca',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFA83838),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                            // Notification list atau loading indicator
                            Expanded(
                              child: _buildNotificationList(userId),
                            ),

                            // Footer copyright
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              alignment: Alignment.center,
                              child: const Text(
                                '© 2025 Beyond. Hak Cipta Dilindungi.',
                                style: TextStyle(
                                  color: Color(0xFF8A8A8A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              
              // Jika terjadi error atau data tidak tersedia
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFAB4545),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Gagal memuat data pengguna. Silakan coba lagi.',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Reload user future
                          _userFuture = AuthService().getCurrentUser();
                          _hasLoaded = false; // Reset flag untuk reload
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFAB4545),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Build notification list with loading, error, and timeout states
  Widget _buildNotificationList(String userId) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAB4545)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Memuat notifikasi...',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Akan berhenti mencari setelah 5 detik',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _timedOut ? Icons.timer_off : Icons.error_outline,
              color: _timedOut ? Colors.orange : const Color(0xFFAB4545),
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                _hasLoaded = false; // Reset flag
                _loadNotifications(userId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAB4545),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off_outlined,
              color: Color(0xFF8A8A8A),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada notifikasi',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                _hasLoaded = false; // Reset flag
                _loadNotifications(userId);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFAB4545),
                side: const BorderSide(color: Color(0xFFAB4545)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification, userId);
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, String userId) {
    return Stack(
      children: [
        // Main notification card
        Container(
          margin: const EdgeInsets.only(bottom: 20), // Increased bottom margin
          decoration: BoxDecoration(
            color: const Color(0xFFF5F0DD), // Beige background color
            borderRadius:
                BorderRadius.circular(18), // Slightly larger border radius
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: 0.08), // Slightly stronger shadow
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE6DFC8), // Light border color
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Background image with low opacity
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1, // Very subtle background
                    child: Image.asset(
                      'assets/images/Hero.webp',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback if the image is not found
                        return Container(color: Colors.transparent);
                      },
                    ),
                  ),
                ),
                // Card content
                InkWell(
                  onTap: () {
                    _handleNotificationTap(notification, userId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center items vertically
                      children: [
                        // Icon container
                        Container(
                          margin: const EdgeInsets.only(
                              right: 14), // More space after icon
                          alignment: Alignment.center, // Center the icon
                          child: Icon(
                            _getIconForNotification(notification),
                            color: const Color(0xFF4D4D4D),
                            size: 30, // Larger icon
                          ),
                        ),

                        // Notification content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize
                                .min, // Only take necessary vertical space
                            children: [
                              Text(
                                notification.title,
                                style: const TextStyle(
                                  fontSize: 15, // Slightly larger font
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 5), // More space
                              Text(
                                notification.message,
                                style: const TextStyle(
                                  fontSize: 13, // Slightly larger font
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Time and more options
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize
                              .min, // Only take necessary vertical space
                          children: [
                            Text(
                              _getTimeAgo(notification.createdAt),
                              style: const TextStyle(
                                fontSize: 13, // Slightly larger font
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            const SizedBox(height: 5), // More space
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Color(0xFF9E9E9E),
                                size: 22, // Slightly larger icon
                              ),
                              onSelected: (value) {
                                if (value == 'mark_read') {
                                  _markAsRead(notification.id, userId);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'mark_read',
                                  child: Text(notification.isRead ? 'Tandai sebagai belum dibaca' : 'Tandai sebagai dibaca'),
                                ),
                                const PopupMenuItem(
                                  value: 'details',
                                  child: Text('Lihat detail'),
                                ),
                              ],
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

        // Red dot indicator in top-left corner (only if not read)
        if (!notification.isRead)
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 14, // Slightly larger dot
              height: 14,
              decoration: const BoxDecoration(
                color: Color(0xFFA83838),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

