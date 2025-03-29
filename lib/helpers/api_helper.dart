import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiHelper {
  static Future<String> getBaseUrl() async {
    String url;

    final prefs = await SharedPreferences.getInstance();
    final isProduction = prefs.getBool('isProduction') ?? false;

    if (isProduction) {
      url = 'https://clb-ingenieria.com/api';
    } else if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      // Verifica características comunes de emuladores
      bool isEmulator = androidInfo.isPhysicalDevice == false ||
          androidInfo.model.toLowerCase().contains('sdk') ||
          androidInfo.model.toLowerCase().contains('emulator') ||
          androidInfo.model.toLowerCase().contains('gphone');

      if (isEmulator) {
        // Usa 10.0.2.2 que es la dirección IP de la máquina host desde el emulador
        url = 'http://10.0.2.2:8000/api';
      } else {
        // Estás en un dispositivo físico
        url = 'http://192.168.100.2:8000/api';
      }
    } else {
      url = 'http://localhost:8000/api';
    }

    print('Using API URL: $url'); // Para verificar qué URL se está usando
    return url;
  }

  // Añadimos el método setProductionMode que faltaba
  static Future<void> setProductionMode(bool isProduction) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isProduction', isProduction);
  }

  static Future<String> getEndpoint(String path) async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl/$path';
  }

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
