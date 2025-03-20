import 'package:flutter/material.dart';
import '../pages/detail_permintaan/detail_permintaan_darah.dart';

class DonationService {
  // Method to get sample patient data
  static PatientDonationData getSamplePatientData() {
    return PatientDonationData(
      patientName: 'Budi Santoso',
      patientAge: 20,
      phoneNumber: '+628131231445',
      bloodType: 'O',
      rhesus: 'Negatif (-)',
      bloodBagsNeeded: 5,
      description: 'Butuh darah cepat setelah cuci darah',
      donationLocation: 'RSUD Zainul Abidin',
      deadline: DateTime.now().add(const Duration(days: 1)), //sisa waktu diatur disini
    );
  }

  // Method to get donation status based on status type
  static DonationStatus getDonationStatus(DonationStatusType statusType) {
    switch (statusType) {
      case DonationStatusType.pending:
        return DonationStatus(
          uniqueCode: '', // Kode unik kosong saat masih pending
          filledBags: 0, 
          status: DonationStatusType.pending,
          onCancelRequest: () {
            print('Permintaan dibatalkan!');
          },
        );
        
      case DonationStatusType.countdown:
        return DonationStatus(
          uniqueCode: '',
          filledBags: 2,
          status: DonationStatusType.countdown,
          remainingTime: DateTime.now().add(const Duration(hours: 12, minutes: 20, seconds: 6)),
          onCancelRequest: () {
            print('Permintaan dibatalkan!');
          },
        );
        
      case DonationStatusType.confirmed:
        return DonationStatus(
          uniqueCode: 'ACG834', // Sudah dapat kode unik
          filledBags: 2, // Sudah terisi 2 kantong
          status: DonationStatusType.confirmed,
          onCancelRequest: () {
            print('Permintaan dibatalkan!');
          },
        );
        
      case DonationStatusType.rejected:
        return DonationStatus(
          uniqueCode: 'ACG834',
          filledBags: 5, // Tetap menampilkan jumlah kantong yang terisi
          status: DonationStatusType.rejected,
        );
        
      case DonationStatusType.completed:
        return DonationStatus(
          uniqueCode: 'ACG834',
          filledBags: 5, // Semua kantong terisi
          status: DonationStatusType.completed,
        );
    }
  }
}