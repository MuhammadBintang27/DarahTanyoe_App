import 'package:flutter/material.dart';
import 'pages/DetailPermintaanDarah.dart';
import 'service/DonationService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get sample patient data from the service
    final patientData = DonationService.getSamplePatientData();
    
    // Get the current donation status (in this example, completed,rejected,pending,countdown,confirmed)
    final donationStatus = DonationService.getDonationStatus(DonationStatusType.countdown);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFFAB4545),
      ),
      home: BloodDonationDetailScreen(
        patientData: patientData,
        donationStatus: donationStatus,
      ),
    );
  }
}