import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class InstitutionService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';

  /// Fetch a single institution by ID. Tries /partners/:id then falls back to /partners list.
  static Future<Map<String, dynamic>?> getInstitutionById(String id) async {
    try {
      // Try direct endpoint
      final direct = await http.get(Uri.parse('$_baseUrl/partners/$id'));
      if (direct.statusCode == 200) {
        final data = jsonDecode(direct.body);
        final Map<String, dynamic>? inst = data['data'];
        if (inst != null) return inst;
      }
    } catch (_) {}

    try {
      // Fallback: fetch all partners then filter by id
      final all = await http.get(Uri.parse('$_baseUrl/partners'));
      if (all.statusCode == 200) {
        final data = jsonDecode(all.body);
        final List<dynamic> list = data['data'] ?? [];
        for (final item in list) {
          if (item is Map<String, dynamic> && (item['id']?.toString() == id)) {
            return item;
          }
        }
      }
    } catch (e) {
      // Intentionally empty - institution lookup error is handled by fallback return null
    }
    return null;
  }
}
