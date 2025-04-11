import 'package:darahtanyoe_app/components/AppBarWithLogo.dart';
import 'package:darahtanyoe_app/components/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

// Model class for notifications with fromJson constructor
class NotificationModel {
  final String id;
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isRead = false,
  });

  // Factory constructor to create a NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Map string icon names to IconData
    IconData getIconFromString(String iconName) {
      switch (iconName) {
        case 'water_drop':
          return Icons.water_drop_outlined;
        case 'volunteer_activism':
          return Icons.volunteer_activism_outlined;
        case 'handshake':
          return Icons.handshake_outlined;
        case 'gift':
          return Icons.card_giftcard_outlined;
        case 'hourglass':
          return Icons.hourglass_empty_outlined;
        default:
          return Icons.notifications_outlined;
      }
    }

    // Map string color codes to actual Color objects
    Color getColorFromString(String colorCode) {
      try {
        // If color is in hex format like #RRGGBB or 0xFFRRGGBB
        if (colorCode.startsWith('#')) {
          return Color(int.parse('0xFF${colorCode.substring(1)}'));
        } else if (colorCode.startsWith('0x')) {
          return Color(int.parse(colorCode));
        } else {
          // Handle named colors or fallback
          switch (colorCode) {
            case 'red':
              return const Color(0xFF8A4250);
            case 'green':
              return const Color(0xFF6D7958);
            case 'blue':
              return const Color(0xFF41628A);
            case 'teal':
              return const Color(0xFF5A7D7C);
            case 'brown':
              return const Color(0xFF8C7D64);
            default:
              return const Color(0xFF8A4250); // Default color
          }
        }
      } catch (e) {
        return const Color(0xFF8A4250); // Default color on error
      }
    }

    return NotificationModel(
      id: json['id'] ?? '0',
      icon: getIconFromString(json['icon'] ?? 'notifications'),
      iconBackgroundColor: getColorFromString(json['iconColor'] ?? 'red'),
      title: json['title'] ?? 'Notifikasi',
      subtitle:
      json['subtitle'] ?? 'Ketuk untuk melihat informasi lebih lanjut',
      timeAgo: json['timeAgo'] ?? 'baru',
      isRead: json['isRead'] ?? false,
    );
  }
}

// API service class to handle API requests
class NotificationService {
  // Base URL of your API
  final String baseUrl;

  NotificationService({required this.baseUrl});

  // Method to fetch notifications from API with timeout
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      // Create a completer to handle the timeout
      final completer = Completer<http.Response>();

      // Start the HTTP request
      final request = http.get(Uri.parse('$baseUrl/notifications'));

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
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => NotificationModel.fromJson(json)).toList();
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

  // Method to provide mock notifications when API is unavailable
  List<NotificationModel> getMockNotifications() {
    return [
      NotificationModel(
        id: '1',
        icon: Icons.water_drop_outlined,
        iconBackgroundColor: const Color(0xFF5A7D7C),
        title: 'Ada permintaan darah di sekitar Anda.',
        subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
        timeAgo: '2j',
      ),
      NotificationModel(
        id: '2',
        icon: Icons.volunteer_activism_outlined,
        iconBackgroundColor: const Color(0xFF41628A),
        title: 'Seseorang telah mendonorkan darah untuk Anda.',
        subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
        timeAgo: '2j',
      ),
      NotificationModel(
        id: '3',
        icon: Icons.handshake_outlined,
        iconBackgroundColor: const Color(0xFF6D7958),
        title: 'Permintaan darah Anda telah terpenuhi.',
        subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
        timeAgo: '5j',
      ),
      // Add more mock notifications as needed
    ];
  }

  // Method to mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
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
  final String apiBaseUrl;
  final bool useMockData;

  const NotificationPage({
    super.key,
    this.onBackPressed,
    this.apiBaseUrl = 'https://api.yourdomain.com/v1', // Default API URL
    this.useMockData = false, // Set to true to use mock data directly
  });

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationService _notificationService;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _timedOut = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(baseUrl: widget.apiBaseUrl);

    if (widget.useMockData) {
      // If mock data is requested, load it directly
      _loadMockData();
    } else {
      // Otherwise, try to fetch from API
      _loadNotifications();
    }
  }

  @override
  void dispose() {
    // Cancel any active timers
    _loadingTimer?.cancel();
    super.dispose();
  }

  // Load mock data directly
  void _loadMockData() {
    setState(() {
      _notifications = _notificationService.getMockNotifications();
      _isLoading = false;
      _errorMessage = null;
      _timedOut = false;
    });
  }

  // Load notifications from API with timeout
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _timedOut = false;
    });

    // Cancel any existing loading timer
    _loadingTimer?.cancel();

    // Set a timer for 5 seconds
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
          _timedOut = true;
          _errorMessage =
          'Permintaan melebihi batas waktu 5 detik. Ketuk tombol di bawah untuk mencoba lagi.';
        });
      }
    });

    try {
      final notifications = await _notificationService.fetchNotifications();

      // Only update state if the loading timer hasn't fired yet
      if (_loadingTimer != null && _loadingTimer!.isActive) {
        _loadingTimer!.cancel();
        setState(() {
          _notifications = notifications;
          _isLoading = false;
          _timedOut = false;
        });
      }
    } on TimeoutException {
      // Handle timeout exception
      if (_loadingTimer != null && _loadingTimer!.isActive) {
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
      if (_loadingTimer != null && _loadingTimer!.isActive) {
        _loadingTimer!.cancel();
        setState(() {
          _errorMessage = 'Gagal memuat notifikasi. Silakan coba lagi.';
          _isLoading = false;
          _timedOut = false;

          // Use mock data in case of error during development
          if (widget.useMockData) {
            _notifications = _notificationService.getMockNotifications();
          }
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
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.white.withOpacity(0.4), // Lebih transparan agar motif batik lebih terlihat
                  padding: const EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      // User pill container
                      // Container(
                      //   padding: const EdgeInsets.symmetric(vertical: 8),
                      //   alignment: Alignment.center,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(20),
                      //       border: Border.all(color: Colors.grey.shade300),
                      //     ),
                      //   ),
                      // ),

                      // Notification list atau loading indicator
                      Expanded(
                        child: _buildNotificationList(),
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
          ),
        ),
      ),
    );
  }

  // Build notification list with loading, error, and timeout states
  Widget _buildNotificationList() {
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
              onPressed: _isLoading ? null : _loadNotifications,
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
              onPressed: _loadNotifications,
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
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
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
                    opacity: 0.2, // Very subtle background
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
                            icon: item.icon,
                            iconBackgroundColor: item.iconBackgroundColor,
                            title: item.title,
                            subtitle: item.subtitle,
                            timeAgo: item.timeAgo,
                            isRead: true,
                          );
                        }
                        return item;
                      }).toList();
                    });

                    // In a real app, you would also call the API
                    // _notificationService.markAsRead(notification.id);

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
                                notification.subtitle,
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
                                          icon: item.icon,
                                          iconBackgroundColor:
                                          item.iconBackgroundColor,
                                          title: item.title,
                                          subtitle: item.subtitle,
                                          timeAgo: item.timeAgo,
                                          isRead: true,
                                        );
                                      }
                                      return item;
                                    }).toList();
                                  });
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

// Example usage
