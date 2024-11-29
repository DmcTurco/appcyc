import 'dart:io' show Platform;

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
}