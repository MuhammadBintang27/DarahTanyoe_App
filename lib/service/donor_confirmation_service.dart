import 'dart:convert';
import 'package:darahtanyoe_app/models/donor_confirmation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service untuk mengelola konfirmasi donor terhadap campaign
/// Maps ke /fulfillment dan donor confirmation endpoints
class DonorConfirmationService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

  /// Confirm donasi dari donor
  /// Maps: POST /fulfillment/donor-confirm
  /// Returns: DonorConfirmationModel dengan status 'confirmed' dan uniqueCode yang auto-generated
  static Future<DonorConfirmationModel?> confirmDonation({
    required String fulfillmentRequestId,
    required String campaignId,
    required String donorId,
  }) async {
    try {
      final body = {
        'fulfillment_request_id': fulfillmentRequestId,
        'campaign_id': campaignId,
        'donor_id': donorId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/fulfillment/donor-confirm'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return DonorConfirmationModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error confirming donation: $e');
      return null;
    }
  }

  /// Reject donasi
  /// Maps: POST /fulfillment/donor-reject
  static Future<bool> rejectDonation({
    required String fulfillmentRequestId,
    required String donorId,
    String? reason,
  }) async {
    try {
      final body = {
        'fulfillment_request_id': fulfillmentRequestId,
        'donor_id': donorId,
        'rejection_reason': reason,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/fulfillment/donor-reject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error rejecting donation: $e');
      return false;
    }
  }

  /// Get pending confirmations untuk donor
  /// Maps: GET /donor-confirmations/pending/:donorId
  static Future<List<DonorConfirmationModel>> getPendingConfirmations(
      String donorId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/donor-confirmations/pending/$donorId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> confirmations = data['data'] ?? [];
        return confirmations
            .map((item) =>
                DonorConfirmationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching pending confirmations: $e');
      return [];
    }
  }

  /// Get confirmation history
  /// Maps: GET /donor-confirmations/:donorId
  static Future<List<DonorConfirmationModel>> getConfirmationHistory(
      String donorId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/donor-confirmations/$donorId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> confirmations = data['data'] ?? [];
        return confirmations
            .map((item) =>
                DonorConfirmationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching confirmation history: $e');
      return [];
    }
  }

  /// Verify kode unik di PMI
  /// Maps: POST /fulfillment/verify-code
  static Future<bool> verifyCode({
    required String uniqueCode,
    required String pmiId,
  }) async {
    try {
      final body = {
        'unique_code': uniqueCode,
        'pmi_id': pmiId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/fulfillment/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  /// Get confirmation detail berdasarkan ID
  /// Maps: GET /donor-confirmations/:confirmationId
  static Future<DonorConfirmationModel?> getConfirmationDetail(
      String confirmationId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/donor-confirmations/$confirmationId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonorConfirmationModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching confirmation detail: $e');
      return null;
    }
  }

  /// Get confirmation by unique code
  /// Maps: GET /donor-confirmations/code/:uniqueCode
  static Future<DonorConfirmationModel?> getConfirmationByCode(
      String uniqueCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/donor-confirmations/code/$uniqueCode'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DonorConfirmationModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      print('Error fetching confirmation by code: $e');
      return null;
    }
  }
}
