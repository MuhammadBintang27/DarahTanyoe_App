String getSelisih(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) return 'Tidak diketahui';

  DateTime waktuBuat;
  try {
    waktuBuat = DateTime.parse(createdAt);
  } catch (e) {
    return 'Format tanggal tidak valid';
  }

  final now = DateTime.now();
  final difference = now.difference(waktuBuat);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} detik yang lalu';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit yang lalu';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} jam yang lalu';
  } else if (difference.inDays < 30) {
    return '${difference.inDays} hari yang lalu';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months bulan yang lalu';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years tahun yang lalu';
  }
}
