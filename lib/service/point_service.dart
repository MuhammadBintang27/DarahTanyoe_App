import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';

Future<int?> fetchTotalPoints() async {
  final userData = await AuthService().getCurrentUser();
  final userId = userData?['id'];

  if (userId == null) return null;
  String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
  final url = Uri.parse('h$baseUrl/users/points/$userId');
  print(url);

  try {
    final response = await http.get(url);
    print(response.body);  
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_points'];
    } else {
      print("Gagal fetch data, status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error saat fetch poin: $e");
    return null;
  }
}