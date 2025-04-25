import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetokin/Models/HariPenting/HariPenting.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<List<Map<String, dynamic>>> fetchHeroes(
      {String? query, String? letter}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/tokoh').replace(queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (letter != null && letter.isNotEmpty) 'letter': letter,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['tokoh_list'] as List)
            .map((hero) => hero as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception('Failed to fetch heroes: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching heroes: $e');
    }
  }

  Future<Map<String, dynamic>> fetchHeroDetail(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/tokoh/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['tokoh'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch hero detail: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching hero detail: $e');
    }
  }

  // Fungsi untuk mengambil data timeline berdasarkan heroId
  Future<List<Map<String, dynamic>>> fetchHeroTimeline(int heroId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/get_timeline/$heroId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debugging respons API
        print("Timeline API Response: $data");

        // Validasi struktur data
        if (data is Map && data.containsKey('timelines')) {
          return (data['timelines'] as List).map((timeline) {
            // Debugging setiap item timeline
            print("Timeline Item: $timeline");

            return {
              "timeline_id": timeline["timeline_id"] ?? 0,
              "nama_timeline": timeline["nama_timeline"] ?? "Tidak ada nama",
              "deskripsi": timeline["deskripsi"] ?? "Tidak ada deskripsi",
              "media": timeline["media"] ?? []
            };
          }).toList();
        } else {
          throw Exception("Invalid response structure");
        }
      } else {
        throw Exception('Failed to fetch timeline: ${response.body}');
      }
    } catch (e) {
      print("Error fetching timeline: $e");
      throw Exception('Error fetching timeline: $e');
    }
  }

  // Fetch tokoh hari ini
  Future<Map<String, dynamic>?> fetchTokohHariIni() async {
    final response = await http.get(Uri.parse('$baseUrl/api/tokoh-hari-ini'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.isNotEmpty ? data[0] : null;
    }
    return null;
  }

  // Fetch hari penting
  Future<HariPenting?> fetchHariPentingHariIni() async {
    final response = await http.get(Uri.parse('$baseUrl/api/hari-penting'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final today = DateTime.now();
      final todayFormatted =
          "${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      for (var item in data) {
        if (item['tanggal'] == todayFormatted) {
          return HariPenting.fromJson(item);
        }
      }
    }
    return null;
  }
}
