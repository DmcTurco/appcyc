import 'package:http/http.dart' as http;
import 'api_helper.dart';

class ConnectionHelper {
  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse(ApiHelper.getEndpoint('check-connection')))
          .timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiHelper.getEndpoint('profile')),
        headers: ApiHelper.getHeaders(token: token),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}