import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../service/auth_service.dart'; // Import AuthService

// Model class for notifications with fromJson constructor
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String relatedTo;
  final String? referenceId;
  final bool isRead;
  final String createdAt;
  
  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedTo,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  // Factory constructor to create a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? 'Notifikasi',
      message: json['message'] ?? 'Ketuk untuk melihat informasi lebih lanjut',
      type: json['type'] ?? 'app',
      relatedTo: json['related_to'] ?? '',
      referenceId: json['reference_id'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
  
  // Helper method to get appropriate icon based on notification type/relatedTo
  IconData get icon {
    switch (relatedTo) {
      case 'request':
        return Icons.water_drop_outlined;
      case 'offer':
        return Icons.volunteer_activism_outlined;
      case 'donation':
        return Icons.handshake_outlined;
      case 'reminder':
        return Icons.hourglass_empty_outlined;
      case 'reward':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
  
  // Get background color for icon based on related_to value
  Color get iconBackgroundColor {
    switch (relatedTo) {
      case 'request':
        return const Color(0xFF5A7D7C);
      case 'offer':
        return const Color(0xFF41628A);
      case 'donation':
        return const Color(0xFF6D7958);
      case 'reminder':
        return const Color(0xFF8C7D64);
      case 'reward':
        return const Color(0xFF8A4250);
      default:
        return const Color(0xFF8A4250);
    }
  }
  
  // Calculate time ago from created_at timestamp
  String get timeAgo {
    final now = DateTime.now();
    final createdDateTime = DateTime.parse(createdAt);
    final difference = now.difference(createdDateTime);
    
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
}

// API service class to handle API requests
class NotificationService {
  // Base URL of your API
  final String baseUrl;
  final String userId;

  NotificationService({required this.baseUrl, required this.userId});

  // Method to fetch notifications from API with timeout
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      // Create a completer to handle the timeout
      final completer = Completer<http.Response>();

      // Start the HTTP request
      final request = http.get(Uri.parse('$baseUrl/notification/$userId'));


      // Set up a 5-second timeout
      final timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (!completer.isCompleted) {
          completer.completeError(
              TimeoutException('Request timed out after 5 seconds'));
        }
      });

      // Complete the completer with the response when it comes
      request.then((response) {
        if (!completer.isCompleted) {
          completer.complete(response);
        }
      }).catchError((error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      });

      // Wait for either the response or the timeout
      final response = await completer.future;

      // Cancel the timer to avoid memory leaks
      timeoutTimer.cancel();

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = json.decode(response.body);
        
        // Check if the API response is successful
        if (jsonResponse['status'] == 'SUCCESS' && jsonResponse['data'] != null) {
          List<dynamic> data = jsonResponse['data'];
          return data.map((item) => NotificationModel.fromJson(item)).toList();
        } else {
          // Handle API error response
          throw Exception('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        // Handle API errors
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } on TimeoutException {
      // Handle timeout specifically
      throw TimeoutException('Permintaan melebihi batas waktu 5 detik');
    } catch (e) {
      // Handle other network errors
      throw Exception('Network error: $e');
    }
  }

  // Method to mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId/read/$notificationId'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

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

  // Load notifications from API with timeout
  Future<void> _loadNotifications(String userId) async {
    // Buat NotificationService untuk userId
    final notificationService = NotificationService(
      baseUrl: 'https://gtf-api.vercel.app',
      userId: userId,
    );
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _timedOut = false;
    });

    // Cancel any existing loading timer
    _loadingTimer?.cancel();

    // Set a timer for 5 seconds
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (_isLoading && mounted) {
        setState(() {
          _isLoading = false;
          _timedOut = true;
          _errorMessage =
              'Permintaan melebihi batas waktu 5 detik. Ketuk tombol di bawah untuk mencoba lagi.';
        });
      }
    });

    try {
      final notifications = await notificationService.fetchNotifications();

      // Only update state if the loading timer hasn't fired yet and widget still mounted
      if (_loadingTimer != null && _loadingTimer!.isActive && mounted) {
        _loadingTimer!.cancel();
        setState(() {
          _notifications = notifications;
          _isLoading = false;
          _timedOut = false;
        });
      }
    } on TimeoutException {
      // Handle timeout exception
      if (_loadingTimer != null && _loadingTimer!.isActive && mounted) {
        _loadingTimer!.cancel();
        setState(() {
          _isLoading = false;
          _timedOut = true;
          _errorMessage =
              'Permintaan melebihi batas waktu 5 detik. Ketuk tombol di bawah untuk mencoba lagi.';
        });
      }
    } catch (e) {
      // Handle other errors
      if (_loadingTimer != null && _loadingTimer!.isActive && mounted) {
        _loadingTimer!.cancel();
        setState(() {
          _errorMessage = 'Gagal memuat notifikasi. Silakan coba lagi.';
          _isLoading = false;
          _timedOut = false;
        });
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
      appBar: AppBarWithLogo(
        title: 'Notifikasi',
        onBackPressed: () {
          Navigator.pop(context);
        },
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
                
                // Jika ini adalah pertama kalinya userId tersedia, muat notifikasi
                if (_isLoading && _notifications.isEmpty && userId.isNotEmpty) {
                  // Gunakan Future.microtask untuk menghindari setState selama build
                  Future.microtask(() => _loadNotifications(userId));
                }
                
                return Column(
                  children: [
                    Expanded(
                      child: Container(
                        color: Colors.white.withOpacity(0.4), // Lebih transparan agar motif batik lebih terlihat
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(
                          children: [
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
              onPressed: _isLoading ? null : () => _loadNotifications(userId),
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
              onPressed: () => _loadNotifications(userId),
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
                    Colors.black.withOpacity(0.08), // Slightly stronger shadow
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
                      'assets/images/Hero.png',
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
                    // Mark notification as read when tapped
                    setState(() {
                      _notifications = _notifications.map((item) {
                        if (item.id == notification.id) {
                          return NotificationModel(
                            id: item.id,
                            userId: item.userId,
                            title: item.title,
                            message: item.message,
                            type: item.type,
                            relatedTo: item.relatedTo,
                            referenceId: item.referenceId,
                            isRead: true,
                            createdAt: item.createdAt,
                          );
                        }
                        return item;
                      }).toList();
                    });

                    // Create a new service instance to mark as read
                    final notificationService = NotificationService(
                      baseUrl: 'https://gtf-api.vercel.app/notification',
                      userId: userId,
                    );
                    
                    // Call the API to mark as read
                    notificationService.markAsRead(notification.id);

                    // Handle notification tap - navigate to detail page etc.
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
                            notification.icon,
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
                              notification.timeAgo,
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
                                  setState(() {
                                    _notifications = _notifications.map((item) {
                                      if (item.id == notification.id) {
                                        return NotificationModel(
                                          id: item.id,
                                          userId: item.userId,
                                          title: item.title,
                                          message: item.message,
                                          type: item.type,
                                          relatedTo: item.relatedTo,
                                          referenceId: item.referenceId,
                                          isRead: true,
                                          createdAt: item.createdAt,
                                        );
                                      }
                                      return item;
                                    }).toList();
                                  });
                                  
                                  // Create a new service instance for marking read
                                  final notificationService = NotificationService(
                                    baseUrl: 'https://gtf-api.vercel.app/notification',
                                    userId: userId,
                                  );
                                  
                                  // Call API to mark as read
                                  notificationService.markAsRead(notification.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'mark_read',
                                  child: Text('Tandai sebagai dibaca'),
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

