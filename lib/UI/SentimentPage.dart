import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:jetokin/base_url_provider.dart'; // Pastikan ini diimpor

class SentimentPage extends StatefulWidget {
  @override
  _SentimentPageState createState() => _SentimentPageState();
}

Future<String> analyzeSentiment(String text, BuildContext context) async {
  final String baseUrl =
      Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
  final String apiUrl =
      '$baseUrl/api/analyze_sentiment'; // Menggunakan baseUrl dari provider

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['message']; // Ambil pesan dari respons server
    } else {
      throw Exception('Gagal mengirim komentar.');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Tidak dapat terhubung ke server.');
  }
}

class _SentimentPageState extends State<SentimentPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;

  void _submitText() async {
    if (_controller.text.trim().isEmpty) {
      _showSnackBar('Komentar tidak boleh kosong', isError: true);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final message = await analyzeSentiment(_controller.text, context);
      _showSnackBar(message); // Tampilkan pesan dari server
      _controller.clear(); // Kosongkan input setelah submit
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Berikan Komentar'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Bagikan pendapat Anda!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Masukan Anda akan sangat membantu kami untuk meningkatkan kualitas aplikasi.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input Box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Ketik komentar Anda di sini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _loading ? null : _submitText,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim Komentar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Illustration Section
            Center(
              child: Column(
                children: [
                  // Image.asset(
                  //   'assets/img/comment.png', // Pastikan file ini tersedia
                  //   height: 180,
                  // ),
                  const SizedBox(height: 10),
                  const Text(
                    'Terima kasih atas dukungan Anda!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
