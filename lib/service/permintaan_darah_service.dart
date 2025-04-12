import 'dart:convert';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../models/permintaan_darah_model.dart';
import 'package:http/http.dart' as http;

class PermintaanDarahService {
  static const String ASSET_DATA_PATH = 'assets/data/permintaan_darah.json';
  static List<PermintaanDarahModel> _cachedData = [];
  static bool _isDataLoaded = false;

  // Memuat data dari file assets hanya sekali
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
      _cachedData = [];
      _isDataLoaded = true;
    }
  }

  // Mengambil semua permintaan darah
  static Future<List<PermintaanDarahModel>> getAllPermintaan() async {
    await _loadInitialData();
    return List.from(_cachedData); // Mengembalikan salinan daftar
  }

  // Menyimpan permintaan baru ke server dan cache
  static Future<bool> simpanPermintaan(PermintaanDarahModel permintaan) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
    String url = "$baseUrl/bloodReq/create";
    final user = await AuthService().getCurrentUser();
    String userid = user?['id'];

    try {
      await _loadInitialData();

      Map<String, dynamic> data = {
        "requester_id": userid,
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

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Data berhasil dikirim ke server');
        _cachedData.add(permintaan);
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
      return null;
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

  // Menghapus permintaan dari cache
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

  // Reset data ke kondisi awal dari assets
  static Future<void> resetToInitial() async {
    _isDataLoaded = false;
    await _loadInitialData();
    print('Data reset to initial state');
  }

  // Generate kode unik
  // static String generateUniqueCode() {
  //   final uuid = Uuid();
  //   return 'BLD-${uuid.v4().substring(0, 8).toUpperCase()}';
  // }

  // Debugging - print data di console
  static void _printDebugData() {
    print('=========== DATA PERMINTAAN DARAH ===========');
    for (var item in _cachedData) {
      print(
          '${item.uniqueCode} | ${item.patientName} | ${item.bloodType} | Status: ${item.status}');
    }
    print('============================================');
  }

  // Export data sebagai JSON string
  static String exportDataAsJsonString() {
    final jsonList = _cachedData.map((item) => item.toJson()).toList();
    return JsonEncoder.withIndent('  ').convert(jsonList);
  }
}
