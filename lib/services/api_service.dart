import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';

  Future<Map<String, dynamic>> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$_baseUrl/users/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final url = Uri.parse('$_baseUrl/users/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return {'statusCode': response.statusCode, 'body': responseBody};
    } else {
      return {'statusCode': response.statusCode, 'body': {}};
    }
  }

  Future<Map<String, dynamic>> createActivity(Map<String, dynamic> activityData) async {
    final url = Uri.parse('$_baseUrl/activities');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(activityData),
    );

    return {'statusCode': response.statusCode, 'body': jsonDecode(response.body)};
  }
}