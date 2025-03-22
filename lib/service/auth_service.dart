import 'dart:convert';
import 'package:darahtanyoe_app/pages/authentication/personal_info.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_navigasi_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/authentication/login_page.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, dynamic> registrationData = {};
  Function(bool isLoading)? loadingCallback;
  Function(String message)? errorCallback;
  Function()? successCallback;

  static const String baseUrl = "https://darahtanyoe-api.vercel.app";

  /// **🔹 Inisialisasi Hive**
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('authBox');
  }

  Future<void> _saveToLocalStorage() async {
    final box = Hive.box('authBox');
    await box.put('registrationData', registrationData);
  }

  Future<void> _loadFromLocalStorage() async {
    final box = Hive.box('authBox');
    final data = box.get('registrationData');
    if (data != null && data is Map<String, dynamic>) {
      registrationData.clear();
      registrationData.addAll(data);
    }
  }

  Future<void> loadRegistrationData() async {
    await _loadFromLocalStorage();
  }

  /// **✅ Kirim OTP**
  Future<bool> sendOTP(String phone) async {
    var request = http.Request('POST', Uri.parse('$baseUrl/users/masuk'));
    request.body = jsonEncode({"phone": phone});
    request.headers.addAll({'Content-Type': 'application/json'});

    try {
      loadingCallback?.call(true);
      print("Mengirim OTP ke: $phone");

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        successCallback?.call();
        return true;
      } else {
        throw jsonDecode(await response.stream.bytesToString())['message'];
      }
    } catch (e) {
      errorCallback?.call(e.toString());
      return false;
    } finally {
      loadingCallback?.call(false);
    }
  }

  final storage = FlutterSecureStorage();

  /// **✅ Verifikasi OTP**
  Future<bool> verifyOTP(String otp, String phone, BuildContext context) async {
    try {
      loadingCallback?.call(true);
      final response = await http.post(
        Uri.parse('$baseUrl/users/verifyOTP'),
        body: jsonEncode({"token": otp, "phone": phone}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String? accessToken =
            responseData['data']['session']['access_token'];
        print("Access token: $accessToken");
        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken);
          print("Access token berhasil disimpan.");
        }

        if (responseData['user'] != null && responseData['user'].isNotEmpty) {
          registrationData['otpVerified'] = true;
          await _saveToLocalStorage();
          successCallback?.call();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
          return true;
        } else {
          print("User tidak ditemukan, mengarah ke PersonalInfo...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PersonalInfo()),
          );
          return false;
        }
      } else {
        throw jsonDecode(response.body)['message'];
      }
    } catch (e) {
      errorCallback?.call(e.toString());
      return false;
    } finally {
      loadingCallback?.call(false);
    }
  }

  /// **✅ Simpan Informasi Pribadi**
  Future<bool> savePersonalInfo(String name, int age, String email) async {
    try {
      loadingCallback?.call(true);
      registrationData['full_name'] = name;
      registrationData['age'] = age;
      registrationData['email'] = email;
      await _saveToLocalStorage();
      successCallback?.call();
      return true;
    } catch (e) {
      errorCallback?.call(e.toString());
      return false;
    } finally {
      loadingCallback?.call(false);
    }
  }

  /// **✅ Simpan Alamat**
  Future<bool> saveAddress(
      String address, double latitude, double longitude) async {
    try {
      loadingCallback?.call(true);
      registrationData['address'] = address;
      registrationData['latitude'] = latitude;
      registrationData['longitude'] = longitude;
      await _saveToLocalStorage();
      successCallback?.call();
      return true;
    } catch (e) {
      errorCallback?.call(e.toString());
      return false;
    } finally {
      loadingCallback?.call(false);
    }
  }

  /// **✅ Simpan Informasi Darah dan Selesaikan Registrasi**
  Future<bool> saveBloodInfo(String bloodType, String lastDonation,
    String medicalHistory) async {
  try {
    loadingCallback?.call(true);

    // Simpan data ke registrationData
    registrationData['blood_type'] = bloodType;
    registrationData['last_donation_date'] = lastDonation;
    registrationData['health_notes'] = medicalHistory;
    registrationData['user_type'] = "pendonor_peminta";
    print("Updated Registration Data: ${jsonEncode(registrationData)}");

    final String? accessToken = await storage.read(key: 'access_token');
    if (accessToken == null) throw "Access token tidak ditemukan";

    // Buat salinan data tanpa phoneNumber
    final Map<String, dynamic> dataToSend = Map.from(registrationData);
    dataToSend.remove('phoneNumber');

    final response = await http.post(
      Uri.parse('$baseUrl/users/daftar'),
      body: jsonEncode(dataToSend), // Kirim data tanpa phoneNumber
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("Final Registration Data Sent: ${jsonEncode(dataToSend)}");

    if (response.statusCode == 201) {
      await _saveToLocalStorage();
      successCallback?.call();
      return true;
    } else {
      throw jsonDecode(response.body)['message'];
    }
  } catch (e) {
    errorCallback?.call(e.toString());
    return false;
  } finally {
    loadingCallback?.call(false);
  }
}


  /// **✅ Reset Data Registrasi**
  Future<void> resetRegistration() async {
    final box = Hive.box('authBox');
    await box.delete('registrationData');
    registrationData.clear();
  }
}
