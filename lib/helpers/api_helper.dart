import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static String getBaseUrl() {
    final url = Platform.isAndroid
        ? 'http://192.168.100.2:8000/api'
        : 'http://localhost:8000/api';
    print('Using API URL: $url'); // Para verificar qué URL se está usando
    return url;
  }

  static String getEndpoint(String path) => '${getBaseUrl()}/$path';

  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return getHeaders(token: token);
  }
}
