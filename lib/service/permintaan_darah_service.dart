import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';
import '../models/permintaan_darah_model.dart';
import 'package:http/http.dart' as http;

class PermintaanDarahService {
  static const String ASSET_DATA_PATH = 'assets/data/permintaan_darah.json';

  // List untuk menyimpan data di memory selama aplikasi berjalan
  static List<PermintaanDarahModel> _cachedData = [];
  static bool _isDataLoaded = false;

  // Memuat data dari assets file (hanya sekali)
  static Future<void> _loadInitialData() async {
    if (_isDataLoaded) return;

    try {
      final jsonString = await rootBundle.loadString(ASSET_DATA_PATH);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      _cachedData =
          jsonList.map((item) => PermintaanDarahModel.fromJson(item)).toList();

      _isDataLoaded = true;
      print('Data loaded from assets: ${_cachedData.length} items');
    } catch (e) {
      print('Error loading data from assets: $e');
      // Jika file tidak ditemukan atau error, mulai dengan list kosong
      _cachedData = [];
      _isDataLoaded = true;
    }
  }

  // Membaca semua data
  static Future<List<PermintaanDarahModel>> getAllPermintaan() async {
    await _loadInitialData();
    return List.from(_cachedData); // Return copy of data
  }

  // Menyimpan permintaan baru (hanya di memory)
  static Future<bool> simpanPermintaan(PermintaanDarahModel permintaan) async {
    const String url =
        "https://3a3c-103-47-133-149.ngrok-free.app/bloodReq/create";

    try {
      await _loadInitialData();

      // Konversi objek ke JSON
      Map<String, dynamic> data = {
        "requester_id": "a4d16fb8-4cf1-4f6e-ae61-e777782987f8",
        "partner_id": permintaan.partner_id,
        "blood_type": permintaan.bloodType,
        "quantity": permintaan.bloodBagsNeeded,
        "reason": permintaan.description,
        "patient_name": permintaan.patientName,
        "patient_age": permintaan.patientAge,
        "status": PermintaanDarahModel.STATUS_PENDING,
        "unique_code": "",
        "blood_bags_fulfilled": 0,
        "expiry_date": permintaan.expiry_date,
        "phone_number": permintaan.phoneNumber
      };

      // Kirim data ke server
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Data berhasil dikirim ke server');
        _cachedData.add(permintaan); // Simpan ke cache
        _printDebugData();
        return true;
      } else {
        print(
            'Gagal menyimpan data. Status: ${response.statusCode}, Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error menyimpan permintaan: $e');
      return false;
    }
  }

  // Mengambil permintaan berdasarkan uniqueCode
  static Future<PermintaanDarahModel?> getPermintaanByUniqueCode(
      String uniqueCode) async {
    await _loadInitialData();

    try {
      return _cachedData.firstWhere((item) => item.uniqueCode == uniqueCode);
    } catch (e) {
      return null; // Tidak ditemukan
    }
  }

  // Memperbarui status permintaan
  static Future<bool> updatePermintaan(
      PermintaanDarahModel updatedPermintaan) async {
    await _loadInitialData();

    for (var i = 0; i < _cachedData.length; i++) {
      if (_cachedData[i].uniqueCode == updatedPermintaan.uniqueCode) {
        _cachedData[i] = updatedPermintaan;

        print('Data updated in memory: ${updatedPermintaan.uniqueCode}');
        _printDebugData();

        return true;
      }
    }

    return false;
  }

  // Menghapus permintaan
  static Future<bool> deletePermintaan(String uniqueCode) async {
    await _loadInitialData();

    int initialLength = _cachedData.length;
    _cachedData.removeWhere((item) => item.uniqueCode == uniqueCode);

    bool success = _cachedData.length < initialLength;
    if (success) {
      print('Data deleted from memory: $uniqueCode');
      _printDebugData();
    }

    return success;
  }

  // Reset data ke initial state dari assets
  static Future<void> resetToInitial() async {
    _isDataLoaded = false;
    await _loadInitialData();
    print('Data reset to initial state');
  }

  // Menghasilkan kode unik
  static String generateUniqueCode() {
    final uuid = Uuid();
    String code = uuid.v4().substring(0, 8).toUpperCase();
    return 'BLD-$code';
  }

  // Helper untuk debugging - print data ke console
  static void _printDebugData() {
    print('=========== DATA PERMINTAAN DARAH ===========');
    for (var item in _cachedData) {
      print(
          '${item.uniqueCode} | ${item.patientName} | ${item.bloodType} | Status: ${item.status}');
    }
    print('============================================');
  }

  // Export data untuk debugging (bisa digunakan untuk menyimpan ke assets)
  static String exportDataAsJsonString() {
    final jsonList = _cachedData.map((item) => item.toJson()).toList();
    return JsonEncoder.withIndent('  ').convert(jsonList);
  }
}
