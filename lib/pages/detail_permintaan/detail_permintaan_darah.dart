import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// Enum untuk status donasi
enum DonationStatusType {
  pending,      // Menunggu konfirmasi
  confirmed,    // Dikonfirmasi, silahkan datang ke lokasi
  countdown,    // Menampilkan sisa waktu permintaan
  rejected,     // Permintaan ditolak
  completed,    // Permintaan selesai
}

// Model untuk data pasien
class PatientDonationData {
  final String patientName;
  final int patientAge;
  final String phoneNumber;
  final String bloodType;
  final int bloodBagsNeeded;
  final String description;
  final String donationLocation;
  final DateTime deadline;
  
  PatientDonationData({
    required this.patientName,
    required this.patientAge,
    required this.phoneNumber,
    required this.bloodType,
    required this.bloodBagsNeeded,
    required this.description,
    required this.donationLocation,
    required this.deadline,
  });
  
  // Format tanggal dengan format Indonesia
  String get deadlineFormatted {
    List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    String day = deadline.day.toString();
    String month = months[deadline.month - 1];
    String year = deadline.year.toString();
    String hour = deadline.hour.toString().padLeft(2, '0');
    String minute = deadline.minute.toString().padLeft(2, '0');
    
    return '$day $month $year, $hour:$minute WIB';
  }
  
  // Factory method untuk membuat contoh data (untuk pengujian)
  factory PatientDonationData.sample() {
    return PatientDonationData(
      patientName: 'Budi Santoso',
      patientAge: 20,
      phoneNumber: '+628131231445',
      bloodType: 'O',
      bloodBagsNeeded: 5,
      description: 'Butuh darah cepat setelah cuci darah',
      donationLocation: 'RSUD Zainul Abidin',
      deadline: DateTime.now().add(const Duration(days: 1, hours: 12, minutes: 32, seconds: 6)),
    );
  }
}

// Model untuk status donasi
class DonationStatus {
  final String uniqueCode;
  final int filledBags;
  final DonationStatusType status;
  final VoidCallback? onCancelRequest;
  final DateTime? remainingTime;
  
  DonationStatus({
    this.uniqueCode = '',
    required this.filledBags,
    required this.status,
    this.onCancelRequest,
    this.remainingTime,
  });
  
  // Factory method untuk membuat contoh data (untuk pengujian)
  factory DonationStatus.sample() {
    return DonationStatus(
      uniqueCode: '',
      filledBags: 2,
      status: DonationStatusType.pending,
      remainingTime: DateTime.now().add(const Duration(days: 1, hours: 12, minutes: 32, seconds: 6)),
    );
  }
  
  // Sample untuk status countdown
  factory DonationStatus.countdown() {
    return DonationStatus(
      uniqueCode: 'DON123456',
      filledBags: 2,
      status: DonationStatusType.countdown,
      remainingTime: DateTime.now().add(const Duration(days: 1, hours: 12, minutes: 32, seconds: 6)),
    );
  }
  
  // Sample untuk status confirmed
  factory DonationStatus.confirmed() {
    return DonationStatus(
      uniqueCode: 'ACG834',
      filledBags: 2,
      status: DonationStatusType.confirmed,
    );
  }
  
  // Sample untuk status rejected
  factory DonationStatus.rejected() {
    return DonationStatus(
      uniqueCode: 'ACG834',
      filledBags: 5,
      status: DonationStatusType.rejected,
    );
  }
  
  // Sample untuk status completed
  factory DonationStatus.completed() {
    return DonationStatus(
      uniqueCode: 'ACG834',
      filledBags: 5,
      status: DonationStatusType.completed,
    );
  }
}

class BloodDonationDetailScreen extends StatefulWidget {
  
  BloodDonationDetailScreen({
    super.key,
    this.onBackPressed,
    this.onNotificationPressed,
    PatientDonationData? patientData,
    DonationStatus? donationStatus,
  }) : 
    patientData = patientData ?? PatientDonationData.sample(),
    donationStatus = donationStatus ?? DonationStatus.sample();

  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;
  
  // Model untuk data pasien
  final PatientDonationData patientData;
  
  // Model untuk status donasi
  final DonationStatus donationStatus;

  @override
  State<BloodDonationDetailScreen> createState() => _BloodDonationDetailScreenState();
}

class _BloodDonationDetailScreenState extends State<BloodDonationDetailScreen> {
  String remainingTimeText = "00:00:00"; // Default value
  Timer? _timer;
  
 @override
  void initState() {
    super.initState();
    
    // Tambahkan logging
    print('Current status: ${widget.donationStatus.status}');
    print('Remaining time: ${widget.donationStatus.remainingTime}');
    
    // Pastikan kondisi ini terpenuhi
    if (widget.donationStatus.status == DonationStatusType.countdown && 
        widget.donationStatus.remainingTime != null) {
      print('Starting countdown timer');
      _startCountdownTimer();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startCountdownTimer() {
    print('Countdown timer started');
    _updateRemainingTime(); // Panggil segera
    
    // Timer yang update setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('Updating timer'); // Debug log
      _updateRemainingTime();
    });
  }
  
  void _updateRemainingTime() {
    // Pastikan remainingTime tidak null
    if (widget.donationStatus.remainingTime == null) {
      print('Remaining time is null');
      return;
    }
    
    final now = DateTime.now();
    final remaining = widget.donationStatus.remainingTime!.difference(now);
    
    // Debug informasi
    print('Now: $now');
    print('Remaining time: ${widget.donationStatus.remainingTime}');
    print('Difference: $remaining');
    
    if (remaining.isNegative) {
      setState(() {
        remainingTimeText = "Waktu habis";
      });
      _timer?.cancel();
      print('Timer cancelled - time expired');
    } else {
      // Ubah ke format jam
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      final seconds = remaining.inSeconds.remainder(60);
      
      setState(() {
        remainingTimeText = "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      });
      
      print('Remaining time text: $remainingTimeText');
    }
  }

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
          // Area konten utama
          Column(
            children: [
              // AppBar custom dengan posisi absolute
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
                        onPressed: widget.onBackPressed ??
                            () {
                              Navigator.of(context).pop();
                            },
                      ),
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Text(
                              'Detail Permintaan Darah Anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: widget.onNotificationPressed,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFCC33),
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bagian body di bawah app bar
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
                    padding: const EdgeInsets.only(top: 30),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // Kartu Informasi Pasien
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F0DD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Baris 1: Nama dan Usia
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        title: 'Nama Pasien',
                                        value: widget.patientData.patientName,
                                        icon: Icons.person,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInfoCard(
                                        title: 'Usia Pasien',
                                        value: '${widget.patientData.patientAge} tahun',
                                        icon: Icons.calendar_today,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Baris 2: Nomor Telepon
                                _buildInfoCard(
                                  title: 'Nomor Handphone (WhatsApp)',
                                  value: widget.patientData.phoneNumber,
                                  icon: Icons.phone_android,
                                ),
                                const SizedBox(height: 20),

                                // Baris 3: Golongan Darah dan Rhesus
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        title: 'Golongan Darah',
                                        value: widget.patientData.bloodType,
                                        icon: Icons.bloodtype,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Baris 4: Kantong Darah Dibutuhkan
                                _buildInfoCard(
                                  title: 'Jumlah Kebutuhan Kantong',
                                  value: '${widget.patientData.bloodBagsNeeded} Kantong',
                                  icon: Icons.shopping_bag,
                                ),
                                const SizedBox(height: 20),

                                // Baris 5: Deskripsi
                                _buildInfoCard(
                                  title: 'Deskripsi Kebutuhan',
                                  value: widget.patientData.description,
                                  icon: Icons.description,
                                ),
                                const SizedBox(height: 20),

                                // Baris 6: Lokasi dan Tenggat Waktu
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        title: 'Lokasi Pendonoran',
                                        value: widget.patientData.donationLocation,
                                        icon: Icons.location_on,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInfoCard(
                                        title: 'Jadwal Berakhir',
                                        value: widget.patientData.deadlineFormatted,
                                        icon: Icons.access_time,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Kartu Kode Unik dan Status Kantong
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7F9),
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.qr_code,
                                            size: 16,
                                            color: Color(0xFF555555),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Kode Unik',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.donationStatus.uniqueCode.isEmpty
                                            ? 'Belum Ada'
                                            : widget.donationStatus.uniqueCode,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: widget.donationStatus.uniqueCode.isEmpty
                                              ? Colors.grey
                                              : const Color(0xFF333333),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF0F0),
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFA83838),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Telah terisi ${widget.donationStatus.filledBags} dari ${widget.patientData.bloodBagsNeeded} Kantong yang Dibutuhkan',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Tampilan status berdasarkan jenis status
                          _buildStatusSection(),

                          const SizedBox(height: 16),

                          // Tombol Batalkan (hanya jika status belum selesai/ditolak)
                          if (widget.donationStatus.status != DonationStatusType.completed && 
                              widget.donationStatus.status != DonationStatusType.rejected)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Tampilkan dialog konfirmasi pembatalan
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Konfirmasi Pembatalan'),
                                        content: const Text(
                                            'Apakah Anda yakin ingin membatalkan permintaan donor darah ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Tidak'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              // Tambahkan logika pembatalan di sini
                                              widget.donationStatus.onCancelRequest?.call();
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Ya, Batalkan'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA83838),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Batalkan Permintaan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Teks Hak Cipta
                          const Text(
                            '© 2025 Beyond. Hak Cipta Dilindungi.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Logo yang diposisikan di atas, berada di antara appBar dan konten
          Positioned(
            top: 80.0 - 15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
                  'assets/images/logo.png',
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

  // Widget untuk menampilkan status yang berbeda sesuai dengan status saat ini
  Widget _buildStatusSection() {
    switch (widget.donationStatus.status) {
      case DonationStatusType.pending:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFCC33), width: 1),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.access_time_filled,
                size: 16,
                color: Color(0xFFD4A017),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'MENUNGGU KONFIRMASI RS/PMI TERKAIT',
                  style: TextStyle(
                    color: Color(0xFFD4A017),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DonationStatusType.countdown:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 219, 216, 216),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SISA WAKTU PERMINTAAN',
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                remainingTimeText,
                style: const TextStyle(
                  color: Color(0xFF424242),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      
      case DonationStatusType.confirmed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4CAF50), width: 1),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Color(0xFF2E7D32),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SILAHKAN DATANG KE LOKASI PENDONORAN',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DonationStatusType.rejected:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE53935), width: 1),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.cancel,
                size: 16,
                color: Color(0xFFB71C1C),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PERMINTAAN DARAH DIBATALKAN. Jika Diperlukan, Lakukan Permintaan Ulang',
                  style: TextStyle(
                    color: Color(0xFFB71C1C),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      
      case DonationStatusType.completed:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2196F3), width: 1),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.verified,
                size: 16,
                color: Color(0xFF1565C0),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'PERMINTAAN DARAH SELESAI',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5E8C5),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: const Color(0xFF666666),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

// Contoh kode untuk menggunakan Firebase dengan DetailPermintaanDarah.dart

class FirebaseService {
  // Mendapatkan data pasien dari Firestore
  Future<PatientDonationData> getPatientData(String donationId) async {
  // Di sini implementasikan kode untuk mengambil data dari Firebase
    // Contoh:
    // final docSnapshot = await FirebaseFirestore.instance.collection('donations').doc(donationId).get();
    // if (docSnapshot.exists) {
    //   final data = docSnapshot.data()!;
    //   return PatientDonationData(
    //     patientName: data['patientName'] ?? '',
    //     patientAge: data['patientAge'] ?? 0,
    //     phoneNumber: data['phoneNumber'] ?? '',
    //     bloodType: data['bloodType'] ?? '',
    //     rhesus: data['rhesus'] ?? '',
    //     bloodBagsNeeded: data['bloodBagsNeeded'] ?? 0,
    //     description: data['description'] ?? '',
    //     donationLocation: data['donationLocation'] ?? '',
    //     deadline: data['deadline']?.toDate() ?? DateTime.now().add(const Duration(days: 1)),
    //   );
    // }
    
    // Contoh data sementara (untuk pengujian)
    return PatientDonationData.sample();
  }
  
  // Mendapatkan status donasi dari Firestore
  Future<DonationStatus> getDonationStatus(String donationId) async {
    // Di sini implementasikan kode untuk mengambil status dari Firebase
    // Contoh:
    // final docSnapshot = await FirebaseFirestore.instance.collection('donation_status').doc(donationId).get();
    // if (docSnapshot.exists) {
    //   final data = docSnapshot.data()!;
    //   final statusString = data['status'] ?? 'pending';
    //   final status = _convertStatusFromString(statusString);
      
    //   return DonationStatus(
    //     uniqueCode: data['uniqueCode'] ?? '',
    //     filledBags: data['filledBags'] ?? 0,
    //     status: status,
    //     remainingTime: data['deadline']?.toDate(),
    //     onCancelRequest: () {
    //       // Implementasi pembatalan di sini
    //       FirebaseFirestore.instance.collection('donations').doc(donationId).update({
    //         'status': 'cancelled',
    //         'cancelledAt': FieldValue.serverTimestamp(),
    //       });
    //     },
    //   );
    // }
    
    // Contoh data sementara (untuk pengujian)
    return DonationStatus.sample();
  }
  
  // Konversi string status menjadi enum
  DonationStatusType _convertStatusFromString(String status) {
    switch (status) {
      case 'confirmed':
        return DonationStatusType.confirmed;
      case 'countdown':
        return DonationStatusType.countdown;
      case 'rejected':
        return DonationStatusType.rejected;
      case 'completed':
        return DonationStatusType.completed;
      default:
        return DonationStatusType.pending;
    }
  }
  
  // Metode untuk membatalkan permintaan darah
  Future<void> cancelDonationRequest(String donationId) async {
    // Di sini implementasikan kode untuk membatalkan permintaan
    // Contoh:
    // await FirebaseFirestore.instance.collection('donations').doc(donationId).update({
    //   'status': 'cancelled',
    //   'cancelledAt': FieldValue.serverTimestamp(),
    // });
    
    print('Donation request $donationId cancelled');
  }
  
  // Metode untuk streaming perubahan status
  // Stream<DonationStatus> streamDonationStatus(String donationId) {
  //   return FirebaseFirestore.instance
  //     .collection('donation_status')
  //     .doc(donationId)
  //     .snapshots()
  //     .map((snapshot) {
  //       if (!snapshot.exists) {
  //         return DonationStatus.sample();
  //       }
  //       
  //       final data = snapshot.data()!;
  //       final statusString = data['status'] ?? 'pending';
  //       final status = _convertStatusFromString(statusString);
  //       
  //       return DonationStatus(
  //         uniqueCode: data['uniqueCode'] ?? '',
  //         filledBags: data['filledBags'] ?? 0,
  //         status: status,
  //         remainingTime: data['deadline']?.toDate(),
  //         onCancelRequest: () {
  //           cancelDonationRequest(donationId);
  //         },
  //       );
  //     });
  // }
}

// Contoh penggunaan dalam screen lain untuk memanggil detail screen
class UsageExample extends StatelessWidget {
  const UsageExample({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contoh Navigasi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Contoh beberapa tombol untuk menampilkan berbagai status
            ElevatedButton(
              onPressed: () => _showDonationDetail(context, DonationStatusType.pending),
              child: const Text('Tampilkan Status Menunggu Konfirmasi'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showDonationDetail(context, DonationStatusType.countdown),
              child: const Text('Tampilkan Status Countdown'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showDonationDetail(context, DonationStatusType.confirmed),
              child: const Text('Tampilkan Status Dikonfirmasi'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showDonationDetail(context, DonationStatusType.rejected),
              child: const Text('Tampilkan Status Ditolak'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showDonationDetail(context, DonationStatusType.completed),
              child: const Text('Tampilkan Status Selesai'),
            ),
            const SizedBox(height: 20),
            // Contoh memuat data dari Firebase (uncomment jika sudah menggunakan Firebase)
            // ElevatedButton(
            //   onPressed: () => _loadFromFirebase(context, 'donation123'),
            //   child: const Text('Muat Data dari Firebase'),
            //   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            // ),
          ],
        ),
      ),
    );
  }
  
  // Menampilkan detail dengan status tertentu (untuk contoh/pengujian)
  void _showDonationDetail(BuildContext context, DonationStatusType statusType) {
    // Data pasien
    final patientData = PatientDonationData(
      patientName: 'Budi Santoso',
      patientAge: 20,
      phoneNumber: '+628131231445',
      bloodType: 'O',
      bloodBagsNeeded: 5,
      description: 'Butuh darah cepat setelah cuci darah',
      donationLocation: 'RSUD Zainul Abidin',
      deadline: DateTime.now().add(const Duration(days: 2)),
    );
    
    // Status donasi yang berbeda berdasarkan parameter
    late DonationStatus donationStatus;
    
    switch (statusType) {
      case DonationStatusType.pending:
        donationStatus = DonationStatus(
          uniqueCode: '', // Kode unik kosong saat masih pending
          filledBags: 0, 
          status: DonationStatusType.pending,
          onCancelRequest: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permintaan berhasil dibatalkan')),
            );
          },
        );
        break;
        
      case DonationStatusType.countdown:
        donationStatus = DonationStatus(
          uniqueCode: '',
          filledBags: 2,
          status: DonationStatusType.countdown,
          remainingTime: DateTime.now().add(const Duration(days: 1, hours: 12, minutes: 32)),
          onCancelRequest: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permintaan berhasil dibatalkan')),
            );
          },
        );
        break;
        
      case DonationStatusType.confirmed:
        donationStatus = DonationStatus(
          uniqueCode: 'ACG834',
          filledBags: 2,
          status: DonationStatusType.confirmed,
          onCancelRequest: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permintaan berhasil dibatalkan')),
            );
          },
        );
        break;
        
      case DonationStatusType.rejected:
        donationStatus = DonationStatus(
          uniqueCode: 'ACG834',
          filledBags: 5,
          status: DonationStatusType.rejected,
        );
        break;
        
      case DonationStatusType.completed:
        donationStatus = DonationStatus(
          uniqueCode: 'ACG834',
          filledBags: 5,
          status: DonationStatusType.completed,
        );
        break;
    }
    
    // Navigasi ke halaman detail
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BloodDonationDetailScreen(
          patientData: patientData,
          donationStatus: donationStatus,
        ),
      ),
    );
  }
  
  // Memuat data dari Firebase (uncomment jika sudah menggunakan Firebase)
  // void _loadFromFirebase(BuildContext context, String donationId) async {
  //   final firebaseService = FirebaseService();
  //   
  //   try {
  //     final patientData = await firebaseService.getPatientData(donationId);
  //     final donationStatus = await firebaseService.getDonationStatus(donationId);
  //     
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BloodDonationDetailScreen(
  //           patientData: patientData,
  //           donationStatus: donationStatus,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }
}