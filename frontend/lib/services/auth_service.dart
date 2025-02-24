import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
<<<<<<< HEAD
  static const baseUrl = 'http://localhost:8080/api/auth';
  static const tokenKey = 'auth_token';
=======
  static const String baseUrl = 'http://localhost:8080';
>>>>>>> feature

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
<<<<<<< HEAD
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _saveToken(token);
      return token;
=======
      final data = json.decode(response.body);
      return data['token'];
>>>>>>> feature
    } else {
      throw Exception('Ошибка авторизации');
    }
  }

  Future<String> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
<<<<<<< HEAD
      final data = jsonDecode(response.body);
      final token = data['token'];
      await _saveToken(token);
      return token;
=======
      final data = json.decode(response.body);
      return data['token'];
>>>>>>> feature
    } else {
      throw Exception('Ошибка регистрации');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }
} 