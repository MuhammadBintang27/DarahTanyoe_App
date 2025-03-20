import 'package:darahtanyoe_app/components/my_navbar.dart';
import 'package:darahtanyoe_app/widget/header_widget.dart';
import 'package:flutter/material.dart';

// Define the BloodRequest class
class BloodRequest {
  final String status;
  final String bloodType;
  final String date;
  final String hospital;
  final String distance;
  final int bagCount;
  final bool isCompleted;
  final bool isCancelled;
  final bool isUrgent;

  BloodRequest({
    required this.status,
    required this.bloodType,
    required this.date,
    required this.hospital,
    required this.distance,
    required this.bagCount,
    required this.isCompleted,
    required this.isCancelled,
    required this.isUrgent,
  });
}

// Define the BloodDonation class
class BloodDonation {
  final String status;
  final String bloodType;
  final String date;
  final String hospital;
  final String distance;
  final int bagCount;
  final bool isCompleted;
  final bool isCancelled;

  BloodDonation({
    required this.status,
    required this.bloodType,
    required this.date,
    required this.hospital,
    required this.distance,
    required this.bagCount,
    required this.isCompleted,
    required this.isCancelled,
  });
}

class TransactionBlood extends StatefulWidget {
  const TransactionBlood({Key? key}) : super(key: key);

  @override
  State<TransactionBlood> createState() => _TransactionBloodState();
}

class _TransactionBloodState extends State<TransactionBlood> {
  // Track which tab is selected
  bool isRequestTab = true;

  // Dummy data for blood requests
  List<BloodRequest> requestList = [
    BloodRequest(
      status: 'Menunggu Donor',
      bloodType: 'A+',
      date: '20 Mar 2025',
      hospital: 'RS Medika Jakarta',
      distance: '2.5 km dari lokasi Anda',
      bagCount: 2,
      isCompleted: false,
      isCancelled: false,
      isUrgent: true,
    ),
    BloodRequest(
      status: 'Dalam Proses',
      bloodType: 'O-',
      date: '18 Mar 2025',
      hospital: 'RSUD Tangerang',
      distance: '5.8 km dari lokasi Anda',
      bagCount: 3,
      isCompleted: false,
      isCancelled: false,
      isUrgent: false,
    ),
    BloodRequest(
      status: 'Telah Selesai',
      bloodType: 'B+',
      date: '15 Mar 2025',
      hospital: 'RS Hermina Bekasi',
      distance: '7.2 km dari lokasi Anda',
      bagCount: 5,
      isCompleted: true,
      isCancelled: false,
      isUrgent: true,
    ),
    BloodRequest(
      status: 'Dibatalkan',
      bloodType: 'AB-',
      date: '10 Mar 2025',
      hospital: 'RS Siloam Surabaya',
      distance: '3.1 km dari lokasi Anda',
      bagCount: 0,
      isCompleted: false,
      isCancelled: true,
      isUrgent: false,
    ),
  ];

  // Dummy data for blood donations
  List<BloodDonation> donationList = [
    BloodDonation(
      status: 'Menunggu Konfirmasi',
      bloodType: 'O+',
      date: '19 Mar 2025',
      hospital: 'PMI Jakarta Pusat',
      distance: '1.8 km dari lokasi Anda',
      bagCount: 1,
      isCompleted: false,
      isCancelled: false,
    ),
    BloodDonation(
      status: 'Dalam Proses',
      bloodType: 'A-',
      date: '16 Mar 2025',
      hospital: 'RS Fatmawati',
      distance: '4.3 km dari lokasi Anda',
      bagCount: 2,
      isCompleted: false,
      isCancelled: false,
    ),
    BloodDonation(
      status: 'Telah Selesai',
      bloodType: 'B-',
      date: '12 Mar 2025',
      hospital: 'RS Harapan Kita',
      distance: '6.7 km dari lokasi Anda',
      bagCount: 5,
      isCompleted: true,
      isCancelled: false,
    ),
    BloodDonation(
      status: 'Dibatalkan',
      bloodType: 'AB+',
      date: '08 Mar 2025',
      hospital: 'RS Cipto Mangunkusumo',
      distance: '3.5 km dari lokasi Anda',
      bagCount: 0,
      isCompleted: false,
      isCancelled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: HeaderWidget(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaksi Anda',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              
              // Toggle buttons for switching between request and donation
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRequestTab = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRequestTab ? Colors.red.shade700 : Colors.transparent,
                          foregroundColor: isRequestTab ? Colors.white : Colors.black,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                        ),
                        child: const Text('Permintaan Darah'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRequestTab = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !isRequestTab ? Colors.red.shade700 : Colors.transparent,
                          foregroundColor: !isRequestTab ? Colors.white : Colors.black,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                        ),
                        child: const Text('Pendonoran Darah'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Display different content based on selected tab
              isRequestTab ? _buildRequestContent() : _buildDonationContent(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: 0),
    );
  }

  Widget _buildRequestContent() {
    // Fix: Use Column with shrinkWrap instead of ListView.builder directly
    return Column(
      children: requestList.map((request) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBloodCard(
            status: request.status,
            bloodType: request.bloodType,
            date: request.date,
            hospital: request.hospital,
            distance: request.distance,
            bagCount: request.bagCount,
            isCompleted: request.isCompleted,
            isCancelled: request.isCancelled,
            
            isRequest: true, // Ini adalah card permintaan darah
            isUrgent: request.isUrgent,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDonationContent() {
    // Fix: Use Column with shrinkWrap instead of ListView.builder directly
    return Column(
      children: donationList.map((donation) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBloodCard(
            status: donation.status,
            bloodType: donation.bloodType,
            date: donation.date,
            hospital: donation.hospital,
            distance: donation.distance,
            bagCount: donation.bagCount,
            isCompleted: donation.isCompleted,
            isCancelled: donation.isCancelled,
            isRequest: false, // Ini adalah card donasi darah
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBloodCard({
  required String status,
  required String bloodType,
  required String date,
  required String hospital,
  required String distance,
  required int bagCount,
  required bool isCompleted,
  required bool isCancelled,
  required bool isRequest,
  bool isUrgent = false,
}) {
  // Warna berdasarkan status
  Color statusColor;
  Color titleColor;
  Color borderColor;
  Color backgroundColor;

  if (isCancelled) {
    statusColor = Color(0xFFAB4545);
    titleColor = Color(0xFFAB4545);
    borderColor = Color(0xFFAB4545);
    backgroundColor = Color.fromRGBO(171, 69, 69, 0.08);
  } else if (isCompleted) {
    statusColor = Color(0xFF359B5E);
    titleColor = Color(0xFF359B5E);
    borderColor = Color(0xFF359B5E);
    backgroundColor = Color.fromRGBO(53, 155, 94, 0.10);
  } else {
    statusColor = Color(0xFFCB9B0A);
    titleColor = Color(0xFFCB9B0A);
    borderColor = Color(0xFFE9B824);
    backgroundColor = Color.fromRGBO(233, 184, 36, 0.06);
  }

  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 1),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isRequest ? 'Permintaan Darah Anda' : 'Pendonoran Darah Anda',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: titleColor),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.local_hospital, color: Colors.grey),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hospital, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(distance, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: titleColor, width: 2),
                ),
                child: Text(
                  bloodType,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.bloodtype, color: Colors.grey, size: 20),
              SizedBox(width: 8),
              Text(
                'Telah terisi $bagCount dari 5 Kantong yang dibutuhkan',
                style: TextStyle(fontSize: 12, color: titleColor),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Container(
                height: 8,
                width: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}