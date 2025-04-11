import 'package:darahtanyoe_app/models/permintaan_darah_model.dart';
import 'package:darahtanyoe_app/service/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PermintaanTerdekat {
  Future<List<PermintaanDarahModel>> fetchBloodRequests(String userId) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
    try {
      final url = '$baseUrl/bloodReq/bloodRequestsNearby/$userId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'SUCCESS' && jsonResponse['data'] != null) {
          return (jsonResponse['data'] as List)
              .map((item) => PermintaanDarahModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else {
        throw Exception('Failed to load blood requests: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching blood requests: $e');
    }
  }
}
