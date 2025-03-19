// auth_service.dart
class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Untuk menyimpan semua data registrasi
  final Map<String, dynamic> registrationData = {};

  // Callback untuk notifikasi status
  Function(bool isLoading)? loadingCallback;
  Function(String message)? errorCallback;
  Function()? successCallback;

  // Fungsi untuk mengirim OTP
  Future<bool> sendOTP(String phoneNumber) async {
    try {
      if (loadingCallback != null) loadingCallback!(true);
      
      // Simulasi request ke server untuk mengirim OTP
      await Future.delayed(const Duration(seconds: 2));
      registrationData['phoneNumber'] = phoneNumber;
      
      if (loadingCallback != null) loadingCallback!(false);
      if (successCallback != null) successCallback!();
      return true;
    } catch (e) {
      if (loadingCallback != null) loadingCallback!(false);
      if (errorCallback != null) errorCallback!(e.toString());
      return false;
    }
  }
  
  // Fungsi untuk verifikasi OTP
  Future<bool> verifyOTP(String otp) async {
    try {
      if (loadingCallback != null) loadingCallback!(true);
      
      // Simulasi verifikasi OTP
      await Future.delayed(const Duration(seconds: 2));
      registrationData['otpVerified'] = true;
      
      if (loadingCallback != null) loadingCallback!(false);
      if (successCallback != null) successCallback!();
      return true;
    } catch (e) {
      if (loadingCallback != null) loadingCallback!(false);
      if (errorCallback != null) errorCallback!(e.toString());
      return false;
    }
  }
  
  // Fungsi untuk menyimpan data pribadi
  Future<bool> savePersonalInfo(String name, int age, String email) async {
    try {
      if (loadingCallback != null) loadingCallback!(true);
      
      registrationData['name'] = name;
      registrationData['age'] = age;
      registrationData['email'] = email;
      
      if (loadingCallback != null) loadingCallback!(false);
      if (successCallback != null) successCallback!();
      return true;
    } catch (e) {
      if (loadingCallback != null) loadingCallback!(false);
      if (errorCallback != null) errorCallback!(e.toString());
      return false;
    }
  }
  
  // Fungsi untuk menyimpan alamat
  Future<bool> saveAddress(String address, double latitude, double longitude) async {
    try {
      if (loadingCallback != null) loadingCallback!(true);
      
      registrationData['address'] = address;
      registrationData['latitude'] = latitude;
      registrationData['longitude'] = longitude;
      
      if (loadingCallback != null) loadingCallback!(false);
      if (successCallback != null) successCallback!();
      return true;
    } catch (e) {
      if (loadingCallback != null) loadingCallback!(false);
      if (errorCallback != null) errorCallback!(e.toString());
      return false;
    }
  }
  
  // Fungsi untuk menyimpan informasi darah dan menyelesaikan registrasi
  Future<bool> saveBloodInfo(String bloodType, String rhesus, String lastDonation, List<String> medicalHistory) async {
    try {
      if (loadingCallback != null) loadingCallback!(true);
      
      // Simulasi request ke server untuk menyelesaikan registrasi
      await Future.delayed(const Duration(seconds: 2));
      
      registrationData['bloodType'] = bloodType;
      registrationData['rhesus'] = rhesus;
      registrationData['lastDonation'] = lastDonation;
      registrationData['medicalHistory'] = medicalHistory;
      
      // Pada tahap terakhir, kita kirim semua data ke server
      print('Registrasi selesai dengan data: $registrationData');
      
      if (loadingCallback != null) loadingCallback!(false);
      if (successCallback != null) successCallback!();
      return true;
    } catch (e) {
      if (loadingCallback != null) loadingCallback!(false);
      if (errorCallback != null) errorCallback!(e.toString());
      return false;
    }
  }
}