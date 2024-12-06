import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static String getBaseUrl() {
    return Platform.isAndroid
        ? 'http://10.0.2.2:8000/api'
        : 'http://localhost:8000/api';
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
