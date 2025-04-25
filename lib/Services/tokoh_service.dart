import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetokin/Models/tokoh_model.dart';

class TokohService {
  final String baseUrl = 'http://192.168.95.117:5000/api';

  Future<List<Tokoh>> getAllTokoh() async {
    final response = await http.get(Uri.parse('$baseUrl/tokoh'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['tokoh_list'] as List).map((item) => Tokoh.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tokoh');
    }
  }

  Future<Tokoh> getTokohDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/tokoh/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Tokoh.fromJson(data['tokoh']);
    } else {
      throw Exception('Failed to load tokoh detail');
    }
  }
}
