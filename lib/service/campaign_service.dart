import 'dart:convert';
import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service untuk mengelola campaign (permintaan darah)
/// Menggantikan PermintaanDarahService dan PermintaanTerdekat
class CampaignService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

  /// Get detail campaign berdasarkan ID
  /// Maps: GET /campaigns/:id
  static Future<PermintaanDarahModel?> getCampaignById(String campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/campaigns/$campaignId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PermintaanDarahModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching campaign: $e');
      return null;
    }
  }

  /// Get semua campaign yang aktif
  /// Maps: GET /campaigns (with status=active filter)
  static Future<List<PermintaanDarahModel>> getAllActiveCampaigns() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/campaigns?status=active'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> campaigns = data['data'] ?? [];
        return campaigns
            .map((item) => PermintaanDarahModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching campaigns: $e');
      return [];
    }
  }

  /// Get campaigns terdekat dari donor berdasarkan lokasi
  /// Maps: GET /campaigns/nearby/:userId
  /// Returns campaigns (both event & fulfillment type) sorted by distance
  static Future<List<PermintaanDarahModel>> getNearestCampaigns(
    String userId, {
    int radiusKm = 20,
    String? bloodType,
  }) async {
    try {
      String url = '$_baseUrl/campaigns/nearby/$userId?radiusKm=$radiusKm';
      if (bloodType != null) {
        url += '&bloodType=$bloodType';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> campaigns = data['data'] ?? [];
        
        print('✅ Fetched ${campaigns.length} nearby campaigns');
        
        return campaigns
            .map((item) => PermintaanDarahModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ Error: API returned ${response.statusCode}');
      }
      return [];
    } catch (e) {
      print('❌ Error fetching nearest campaigns: $e');
      return [];
    }
  }

  /// Get campaign berdasarkan blood type
  /// Maps: GET /campaigns?blood_type=O
  static Future<List<PermintaanDarahModel>> getCampaignsByBloodType(String bloodType) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/campaigns?blood_type=$bloodType'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> campaigns = data['data'] ?? [];
        return campaigns
            .map((item) => PermintaanDarahModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching campaigns by blood type: $e');
      return [];
    }
  }
}
