import 'dart:convert';
import 'package:darahtanyoe_app/pages/authentication/personal_info.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import '../pages/authentication/login_page.dart';
import '../pages/mainpage/home_screen.dart';

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
  registrationData['phoneNumber'] = phone;

  try {
    loadingCallback?.call(true);
    print(phone);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      registrationData['phone'] = phone;
      await _saveToLocalStorage();
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


  /// **✅ Verifikasi OTP**
  Future<bool> verifyOTP(String otp, String phone, BuildContext context) async {
  try {
    loadingCallback?.call(true);
    final response = await http.post(
      Uri.parse('$baseUrl/users/verifyOTP'),
      body: jsonEncode({"token": otp, "phone": registrationData['phone']}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      if (responseData['user'] != null && responseData['user'].isNotEmpty) {
        registrationData['otpVerified'] = true;
        await _saveToLocalStorage();
        print("User ditemukan: ${responseData['user']}");

        successCallback?.call();

        // Navigasi ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return true;
      } else {
        print("User tidak ditemukan, mengarah ke LoginPage...");
        
        // Navigasi ke LoginPage
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
  Future<bool> saveAddress(String address, double latitude, double longitude) async {
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
  Future<bool> saveBloodInfo(String bloodType, String lastDonation, List<String> medicalHistory) async {
    try {
      loadingCallback?.call(true);
      final response = await http.post(
        Uri.parse('$baseUrl/users/daftar'),
        body: jsonEncode({
          registrationData,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        registrationData['bloodType'] = bloodType;
        registrationData['lastDonation'] = lastDonation;
        registrationData['medicalHistory'] = medicalHistory;
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
