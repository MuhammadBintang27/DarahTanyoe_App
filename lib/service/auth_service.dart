import 'dart:convert';
import 'package:darahtanyoe_app/pages/authentication/login_page.dart';
import 'package:darahtanyoe_app/pages/authentication/personal_info.dart';
import 'package:darahtanyoe_app/pages/mainpage/main_screen.dart';
import 'animation_service.dart';
import 'toast_service.dart';
import 'push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, dynamic> registrationData = {};
  Function(bool isLoading)? loadingCallback;
  Function(String message)? errorCallback;
  Function()? successCallback;
  String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
  final storage = FlutterSecureStorage();

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
  Future<bool> sendOTP(String phone, [BuildContext? context]) async {
    var request = http.Request('POST', Uri.parse('$baseUrl/users/masuk'));
    request.headers.addAll({
      'Content-Type': 'application/json',
    });
    request.body = jsonEncode({"phone": phone}); // <-- MENAMBAHKAN BODY REQUEST

    try {
      // Tampilkan loading jika context tersedia
      loadingCallback?.call(true);
      if (context != null) {
        AnimationService.showLoading(context);
      }

      // Kirim request
      http.StreamedResponse response = await request.send();

      // Baca response body sebagai string
      String responseBody = await response.stream.bytesToString();

      // Sembunyikan loading jika context tersedia
      if (context != null) {
        AnimationService.hideLoading(context);
      }

      if (response.statusCode == 200) {
        successCallback?.call();

        if (context != null) {
          await AnimationService.showSuccess(
            context,
            message: 'OTP berhasil dikirim!',
          );
        }

        return true;
      } else {
        final errorMsg = jsonDecode(responseBody)['message'];

        errorCallback?.call(errorMsg);

        if (context != null) {
          await AnimationService.showError(context, message: errorMsg);
        }

        return false;
      }
    } catch (e) {
      errorCallback?.call(e.toString());

      if (context != null) {
        AnimationService.hideLoading(context);
        await AnimationService.showError(context, message: e.toString());
      }

      return false;
    } finally {
      loadingCallback?.call(false);
    }
  }

  /// **✅ Verifikasi OTP**
  Future<bool> verifyOTP(String otp, String phone, BuildContext context) async {
    try {
      // Call original loading callback
      loadingCallback?.call(true);

      // Show animation
      AnimationService.showLoading(context);
      final response = await http.post(
        Uri.parse('$baseUrl/users/verifyOTP'),
        body: jsonEncode({"token": otp, "phone": phone}),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      // Hide animation
      AnimationService.hideLoading(context);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String? accessToken =
        responseData['data']['session']['access_token'];
        final String? expires_at =
        responseData['data']['session']['expires_at'];
        final userData = responseData['user'];
        final userId = userData['id'];

        if (accessToken != null) {
          await storage.write(key: 'access_token', value: accessToken);
          await storage.write(key: 'expiry_date', value: expires_at);
          await storage.write(key: 'userData', value: jsonEncode(userData));
        }

        if (responseData['user'] != null && responseData['user'].isNotEmpty) {
          registrationData['otpVerified'] = true;
          await _saveToLocalStorage();

          // ✅ Register FCM token untuk user yang login
          try {
            final pushNotificationService = PushNotificationService();
            await pushNotificationService.registerFCMTokenForUser(userId);
          } catch (fcmError) {
            // Non-blocking error, continue dengan login
          }

          // Call original success callback
          successCallback?.call();

          // Show success and navigate
          await AnimationService.showSuccess(
            context,
            message: 'Verifikasi berhasil!',
            onComplete: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MainScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return AnimationService.buildPageTransition(
                      child: child,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                    );
                  },
                ),
              );
            },
          );
          return true;
        } else {
          // ✅ Register FCM token juga untuk user baru yang belum lengkap profile
          try {
            final pushNotificationService = PushNotificationService();
            await pushNotificationService.registerFCMTokenForUser(userId);
          } catch (fcmError) {
            // Non-blocking error, continue dengan navigation
          }

          // Show success and navigate to personal info
          await AnimationService.showSuccess(
            context,
            message: 'Verifikasi berhasil! Silahkan lengkapi data diri',
            onComplete: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PersonalInfo(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return AnimationService.buildPageTransition(
                      child: child,
                      animation: animation,
                      secondaryAnimation: secondaryAnimation,
                    );
                  },
                ),
              );
            },
          );
          return false;
        }
      } else {
        final errorMsg = jsonDecode(response.body)['message'];

        // Call original error callback
        errorCallback?.call(errorMsg);

        // Show error animation
        await AnimationService.showError(context, message: errorMsg);
        return false;
      }
    } catch (e) {
      // Call original error callback
      errorCallback?.call(e.toString());

      // Hide loading and show error
      AnimationService.hideLoading(context);
      await AnimationService.showError(context, message: e.toString());
      return false;
    } finally {
      // Call original loading callback
      loadingCallback?.call(false);
    }
  }

  Future<bool> savePersonalInfo(String name, DateTime dateOfBirth, String email,
      [BuildContext? context]) async {
    try {
      // Aktifkan loading
      loadingCallback?.call(true);

      // Tampilkan animasi loading jika ada context
      if (context != null) {
        AnimationService.showLoading(context);
      }

      registrationData['full_name'] = name;
      registrationData['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0]; // Format YYYY-MM-DD
      registrationData['email'] = email;
      await _saveToLocalStorage();

      // Callback sukses
      successCallback?.call();

      // Tampilkan animasi sukses jika ada context
      if (context != null) {
        await AnimationService.showSuccess(context,
            message: 'Informasi pribadi tersimpan!');
      }

      return true;
    } catch (e) {
      // Callback error
      errorCallback?.call(e.toString());

      // Tampilkan animasi error jika ada context
      if (context != null) {
        await AnimationService.showError(context, message: e.toString());
      }

      return false;
    } finally {
      // Matikan loading
      loadingCallback?.call(false);

      // Sembunyikan animasi loading jika ada context
      if (context != null) {
        AnimationService.hideLoading(context);
      }
    }
  }

  /// **✅ Simpan Alamat**
  Future<bool> saveAddress(String address, double latitude, double longitude,
      [BuildContext? context]) async {
    try {
      // Aktifkan loading
      loadingCallback?.call(true);

      // Tampilkan animasi loading jika ada context
      if (context != null) {
        AnimationService.showLoading(context);
      }

      registrationData['address'] = address;
      registrationData['latitude'] = latitude;
      registrationData['longitude'] = longitude;
      await _saveToLocalStorage();

      // Callback sukses
      successCallback?.call();

      // Tampilkan animasi sukses jika ada context
      if (context != null) {
        await AnimationService.showSuccess(context,
            message: 'Alamat tersimpan!');
      }

      return true;
    } catch (e) {
      // Callback error
      errorCallback?.call(e.toString());

      // Tampilkan animasi error jika ada context
      if (context != null) {
        await AnimationService.showError(context, message: e.toString());
      }

      return false;
    } finally {
      // Matikan loading
      loadingCallback?.call(false);

      // Sembunyikan animasi loading jika ada context
      if (context != null) {
        AnimationService.hideLoading(context);
      }
    }
  }

  /// **✅ Simpan Informasi Darah dan Selesaikan Registrasi**
  Future<bool> saveBloodInfo(
      String bloodType, String lastDonation, String medicalHistory, [BuildContext? context]) async {
    try {
      // Aktifkan loading
      loadingCallback?.call(true);

      // Tampilkan animasi loading jika ada context
      if (context != null) {
        AnimationService.showLoading(context);
      }

      // Simpan data ke registrationData
      registrationData['blood_type'] = bloodType;
      registrationData['last_donation_date'] = lastDonation;
      registrationData['health_notes'] = medicalHistory;

      final String? accessToken = await storage.read(key: 'access_token');
      if (accessToken == null) {
        throw "Access token tidak ditemukan";
      }

      // Buat salinan data tanpa phoneNumber
      final Map<String, dynamic> dataToSend = Map.from(registrationData);

      final response = await http.post(
        Uri.parse('$baseUrl/users/daftar'),
        body: jsonEncode(dataToSend),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        await _saveToLocalStorage();
        // Ambil data user dari response body
        final responseBody = jsonDecode(response.body);
        final userData = responseBody['user'];
        final userId = userData['id'];

        // Simpan ke SecureStorage dalam bentuk JSON string
        await storage.write(key: 'userData', value: jsonEncode(userData));

        // ✅ Register FCM token untuk user baru
        try {
          final pushNotificationService = PushNotificationService();
          await pushNotificationService.registerFCMTokenForUser(userId);
        } catch (fcmError) {
          // Non-blocking error, continue dengan registration
        }

        // Tampilkan animasi sukses dan navigasi jika ada context
        if (context != null) {
          await AnimationService.showSuccess(context,
              message: 'Registrasi berhasil!', onComplete: () {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MainScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return AnimationService.buildPageTransition(
                    child: child,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                  );
                },
              ),
              (route) => false,
            );
          });
        }

        return true;
      } else {
        final errorMsg = jsonDecode(response.body)['message'];
        throw errorMsg;
      }
    } catch (e) {
      // Callback error
      errorCallback?.call(e.toString());

      // Tampilkan animasi error jika ada context
      if (context != null) {
        await AnimationService.showError(context, message: e.toString());
      }

      return false;
    } finally {
      // Matikan loading
      loadingCallback?.call(false);

      // Sembunyikan animasi loading jika ada context
      if (context != null) {
        AnimationService.hideLoading(context);
      }
    }
  }

  /// **✅ Reset Data Registrasi**
  Future<void> resetRegistration() async {
    final box = Hive.box('authBox');
    await box.delete('registrationData');
    registrationData.clear();
  }
  /// **✅ Logout** - WITH ANIMATION
  Future<void> logout(BuildContext context) async {
  try {
    // Get current user ID before clearing storage
    final userDataJson = await storage.read(key: 'userData');
    if (userDataJson != null) {
      final userData = jsonDecode(userDataJson);
      final userId = userData['id'];
      
      // Unregister FCM token for this user
      if (userId != null) {
        final pushNotificationService = PushNotificationService();
        await pushNotificationService.unregisterFCMTokenForUser(userId);
      }
    }
    
    // Clear all data from SecureStorage
    await storage.deleteAll();
    
    // Reset registration data from Hive
    await resetRegistration();
    
    // Navigate to the login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  } catch (e) {
    // Handle any errors during logout
    
    // Show error message to user via ToastService
    ToastService.showError(
      context,
      message: 'Logout gagal: ${e.toString()}',
    );
  }
}

  /// **🔹 Check Login Status** - Tidak memerlukan context
  Future<bool> isLoggedIn() async {
    try {
      final accessToken = await storage.read(key: 'access_token');
      final userData = await storage.read(key: 'userData');

      // User dianggap login jika kedua data tersedia
      return accessToken != null && userData != null;
    } catch (e) {
      return false;
    }
  }

  /// **🔹 Get Current User** - Tidak memerlukan context
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final userDataString = await storage.read(key: 'userData');
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// **🔹 Get Access Token** - Tidak memerlukan context
  Future<String?> getAccessToken() async {
    try {
      return await storage.read(key: 'access_token');
    } catch (e) {
      return null;
    }
  }

  /// **🔹 Update User Data** - Merge update dengan data user existing (jangan timpa)
  Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      // Get current userData
      final currentUserString = await storage.read(key: 'userData');
      Map<String, dynamic> currentUser = {};
      
      if (currentUserString != null) {
        currentUser = jsonDecode(currentUserString) as Map<String, dynamic>;
      }
      
      // Merge updates dengan current data
      final mergedData = {...currentUser, ...updates};
      
      final userDataString = jsonEncode(mergedData);
      await storage.write(key: 'userData', value: userDataString);
    } catch (e) {
    }
  }
  
}