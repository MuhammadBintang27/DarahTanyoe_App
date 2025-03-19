import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Model untuk data notifikasi
class NotifikasiData {
  final String judul;
  final String deskripsi;
  final DateTime waktu;
  final bool dibaca;
  final String tipe; // 'permintaan_darah', 'konfirmasi', 'penolakan', dll.

  NotifikasiData({
    required this.judul,
    required this.deskripsi,
    required this.waktu,
    this.dibaca = false,
    required this.tipe,
  });

  // Factory method untuk data contoh
  factory NotifikasiData.sample() {
    return NotifikasiData(
      judul: 'Permintaan Donor Darah Baru',
      deskripsi: 'Ada permintaan donor darah mendesak untuk pasien Budi Santoso di RSUD Zainul Abidin',
      waktu: DateTime.now().subtract(const Duration(hours: 2)),
      tipe: 'permintaan_darah',
    );
  }
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  // Daftar notifikasi
  final List<NotifikasiData> _notifikasi = [
    NotifikasiData.sample(),
    NotifikasiData(
      judul: 'Konfirmasi Donor Darah',
      deskripsi: 'Permintaan donor Anda untuk pasien An. Siti telah dikonfirmasi',
      waktu: DateTime.now().subtract(const Duration(days: 1)),
      dibaca: true,
      tipe: 'konfirmasi',
    ),
    NotifikasiData(
      judul: 'Permintaan Ditolak',
      deskripsi: 'Maaf, permintaan donor Anda tidak dapat dilanjutkan',
      waktu: DateTime.now().subtract(const Duration(days: 3)),
      dibaca: true,
      tipe: 'penolakan',
    ),
  ];

  // Method untuk format waktu relatif
  String _formatWaktu(DateTime waktu) {
    final now = DateTime.now();
    final difference = now.difference(waktu);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${waktu.day}/${waktu.month}/${waktu.year}';
    }
  }

  // Method untuk mendapatkan warna berdasarkan tipe notifikasi
  Color _getWarnaTipe(String tipe) {
    switch (tipe) {
      case 'permintaan_darah':
        return const Color(0xFFAB4545); // Merah
      case 'konfirmasi':
        return const Color(0xFF2E7D32); // Hijau
      case 'penolakan':
        return const Color(0xFFB71C1C); // Merah gelap
      default:
        return const Color(0xFF333333); // Abu-abu
    }
  }

  // Method untuk mendapatkan ikon berdasarkan tipe notifikasi
  IconData _getIkonTipe(String tipe) {
    switch (tipe) {
      case 'permintaan_darah':
        return Icons.bloodtype;
      case 'konfirmasi':
        return Icons.check_circle;
      case 'penolakan':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Column(
        children: [
          // AppBar Custom
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Expanded(
                    child: Center(
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
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'Bersihkan Semua',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daftar Notifikasi
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.white.withOpacity(0.75),
                child: _notifikasi.isEmpty
                    ? _buildEmptyNotifikasi()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifikasi.length,
                        itemBuilder: (context, index) {
                          final notifikasi = _notifikasi[index];
                          return _buildItemNotifikasi(notifikasi);
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk item notifikasi
  Widget _buildItemNotifikasi(NotifikasiData notifikasi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: notifikasi.dibaca ? Colors.white : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notifikasi.dibaca ? Colors.grey.shade300 : const Color(0xFFAB4545),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getWarnaTipe(notifikasi.tipe).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              _getIkonTipe(notifikasi.tipe),
              color: _getWarnaTipe(notifikasi.tipe),
              size: 26,
            ),
          ),
        ),
        title: Text(
          notifikasi.judul,
          style: TextStyle(
            fontWeight: notifikasi.dibaca ? FontWeight.normal : FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notifikasi.deskripsi,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatWaktu(notifikasi.waktu),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tampilan saat tidak ada notifikasi
  Widget _buildEmptyNotifikasi() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty_notifications.png', // Asumsikan Anda memiliki gambar ini
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ada Notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan menerima notifikasi saat ada aktivitas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
