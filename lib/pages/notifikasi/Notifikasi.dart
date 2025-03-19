import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationModel {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String subtitle;
  final String timeAgo;
  final bool isRead;

  NotificationModel({
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    this.isRead = false,
  });
}

class NotificationPage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const NotificationPage({
    Key? key,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationModel> _notifications = [
    NotificationModel(
      icon: Icons.water_drop_outlined,
      iconBackgroundColor: const Color(0xFF5A7D7C),
      title: 'Ada permintaan darah di sekitar Anda.',
      subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
      timeAgo: '2j',
    ),
    NotificationModel(
      icon: Icons.volunteer_activism_outlined,
      iconBackgroundColor: const Color(0xFF41628A),
      title: 'Seseorang telah mendonorkan darah untuk Anda.',
      subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
      timeAgo: '2j',
    ),
    NotificationModel(
      icon: Icons.handshake_outlined,
      iconBackgroundColor: const Color(0xFF6D7958),
      title: 'Permintaan darah Anda telah terpenuhi.',
      subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
      timeAgo: '2j',
    ),
    NotificationModel(
      icon: Icons.card_giftcard_outlined,
      iconBackgroundColor: const Color(0xFF8A4250),
      title: 'Donor, dapatkan poin, dan tukar dengan voucher sembako.',
      subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
      timeAgo: '2j',
    ),
    NotificationModel(
      icon: Icons.hourglass_empty_outlined,
      iconBackgroundColor: const Color(0xFF8C7D64),
      title: 'Permintaan darah Anda telah mencapai batas waktu',
      subtitle: 'Ketuk untuk melihat informasi lebih lanjut',
      timeAgo: '2j',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Set status bar dengan warna putih dan ikon hitam
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light, // For iOS
    ));

    return Scaffold(
      body: Stack(
        children: [
          // Main Content Area
          Column(
            children: [
              // Custom AppBar with absolute position
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFAB4545),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: widget.onBackPressed ?? () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Text(
                              'Notifikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Space for symmetry
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              // Body content below the app bar
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/background.png'),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    ),
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    
                    padding: const EdgeInsets.only(top: 30),
                    child: Column(
                      children: [
                        // User pill container
                        Container(

                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          
                        ),
                        
                        // Notification list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _buildNotificationItem(notification);
                            },
                          ),
                        ),
                        
                        // Footer copyright
                       // Footer copyright styled like the image
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
              ),
            ],
          ),

          // Logo positioned between appBar and content
          Positioned(
            top: 80.0 - 15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/darah_tanyoe_logo.png',
                  height: 25,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
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
            borderRadius: BorderRadius.circular(18), // Slightly larger border radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), // Slightly stronger shadow
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
                    ),
                  ),
                ),
                // Card content
                InkWell(
                  onTap: () {
                    // Handle notification tap
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center, // Center items vertically
                      children: [
                        // Icon container
                        Container(
                          margin: const EdgeInsets.only(right: 14), // More space after icon
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
                            mainAxisSize: MainAxisSize.min, // Only take necessary vertical space
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
                          mainAxisSize: MainAxisSize.min, // Only take necessary vertical space
                          children: [
                            Text(
                              notification.timeAgo,
                              style: const TextStyle(
                                fontSize: 13, // Slightly larger font
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            const SizedBox(height: 5), // More space
                            const Icon(
                              Icons.more_horiz,
                              color: Color(0xFF9E9E9E),
                              size: 22, // Slightly larger icon
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
        
        // Red dot indicator in top-left corner
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
class NotificationExample extends StatelessWidget {
  const NotificationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const NotificationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const NotificationExample());
}