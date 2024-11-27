// lib/helpers/api_helper.dart
import 'dart:io' show Platform;

class ApiHelper {
  static String getBaseUrl() {
    // En desarrollo usamos 10.0.2.2 para Android y localhost para iOS
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:8000/api';
    }
    return 'http://localhost:8000/api'; // fallback
  }

  // Obtener la URL completa para un endpoint
  static String getEndpoint(String path) {
    return '${getBaseUrl()}/$path';
  }
  
  // Headers comunes para las peticiones
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}