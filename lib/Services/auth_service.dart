import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetokin/Models/user_models.dart';

class AuthService {
  final String baseUrl = 'http://192.168.1.126:5000/api'; // Sesuaikan dengan URL API Anda

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['user']);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<String> register(String fullname, String email, String password, String gender) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'password': password,
        'gender': gender,
      }),
    );

    if (response.statusCode == 201) {
      return "Registration successful";
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }
}