import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  static const String baseUrl = "http://10.0.2.2:8080/api/auth";

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    return jsonDecode(response.body);
  }
}
