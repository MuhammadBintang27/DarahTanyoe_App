import 'package:darahtanyoe_app/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:darahtanyoe_app/pages/notifikasi/Notifikasi.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:darahtanyoe_app/service/notification_service.dart' as NotifService;

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  int _unreadCount = 0;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null && mounted) {
        final notifications = await NotifService.NotificationService.getNotifications(
          user['id'] ?? '',
          includeRead: false,
        );
        
        // Filter hanya notifikasi yang belum dibaca (isRead == false)
        final unreadNotifications = notifications.where((n) => !n.isRead).toList();
        
        if (mounted) {
          setState(() {
            _unreadCount = unreadNotifications.length;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 40, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/darah_tanyoe_logo.png',
              width: 200,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationPage()),
              ).then((_) {
                // Reload unread count ketika kembali dari notification page
                _loadUnreadCount();
              });
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.brand_02,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brand_02.withOpacity(0.5),
                        spreadRadius: 6,
                        blurRadius: 15,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
                // Badge dengan jumlah notifikasi belum dibaca
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFA83838),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}