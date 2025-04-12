String getTimeRemainingText(String expiryDate) {
  final now = DateTime.now();
  final expired = DateTime.parse(expiryDate);
  final difference = expired.difference(now);

  if (difference.isNegative) return "Kadaluarsa";

  if (difference.inDays > 0) {
    return '${difference.inDays} HARI LAGI';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} JAM LAGI';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} MENIT LAGI';
  } else {
    return '${difference.inSeconds} DETIK LAGI';
  }
}
