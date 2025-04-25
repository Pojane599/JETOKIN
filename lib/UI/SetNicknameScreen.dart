import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/Home.dart';
import 'package:jetokin/UI/Login.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/base_url_provider.dart';

class SetNicknameScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic>
      userData; // Tambahkan userData untuk membawa userId

  const SetNicknameScreen(
      {super.key, required this.email, required this.userData});

  @override
  _SetNicknameScreenState createState() => _SetNicknameScreenState();
}

class _SetNicknameScreenState extends State<SetNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNicknameAvailable = true; // Flag untuk mengecek ketersediaan nickname
  late int userId; // Menyimpan userId

  @override
  void initState() {
    super.initState();
    userId = widget.userData['user_id'] ?? 0; // Ambil userId dari userData
  }

  // Fungsi untuk menampilkan custom SnackBar
  void _showCustomSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
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
        borderRadius: BorderRadius.circular(10.0),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Fungsi untuk memeriksa ketersediaan nickname
  Future<void> _checkNicknameAvailability() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      _showCustomSnackBar(
        'Nama panggilan tidak boleh kosong',
        isError: true,
      );
      return;
    }

    try {
      final baseUrl =
          Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/check_nickname'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nickname': nickname,
        }),
      );

      // Cek status kode respons
      if (response.statusCode == 200) {
        // Jika nickname tersedia
        final data = jsonDecode(response.body);
        setState(() {
          _isNicknameAvailable = data['status'] != 'taken';
        });

        if (_isNicknameAvailable) {
          _showCustomSnackBar(
            'Nama panggilan tersedia. Anda dapat menggunakannya.',
            isError: false,
          );
        } else {
          _showCustomSnackBar(
            'Nama panggilan sudah digunakan. Silakan pilih nama lain.',
            isError: true,
          );
        }
      } else if (response.statusCode == 400) {
        // Jika server mengembalikan pesan error untuk bad request
        final data = jsonDecode(response.body);
        final errorMessage =
            data['message'] ?? 'Terjadi kesalahan pada server.';
        _showCustomSnackBar(errorMessage, isError: true);
      } else {
        // Jika respons bukan 200 atau 400
        _showCustomSnackBar(
          'Terjadi kesalahan pada server: ${response.statusCode}',
          isError: true,
        );
      }
    } catch (e) {
      _showCustomSnackBar(
        'Gagal terhubung ke server. Silakan periksa koneksi Anda.',
        isError: true,
      );
    }
  }

  // Fungsi untuk menyimpan nickname ke server
  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      _showCustomSnackBar('Nama panggilan tidak boleh kosong.', isError: true);
      return;
    }

    if (!_isNicknameAvailable) {
      _showCustomSnackBar('Nama panggilan sudah digunakan.', isError: true);
      return;
    }

    try {
      final baseUrl =
          Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/save_nickname'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.email,
          'nickname': nickname,
          'user_id': userId, // Kirim userId ke server
        }),
      );

      // Log respons server
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _showCustomSnackBar('Nama panggilan berhasil disimpan!');

          // Navigasi ke HomePage dengan membawa userId dan nickname
          print('Navigasi ke HomePage dengan userData: ${widget.userData}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userData: {
                  'email': widget.email,
                  'nickname': nickname,
                  'user_id': widget.userData[
                      'user_id'], // Langsung ambil dari widget.userData
                },
                client: null,
              ),
            ),
          );
        } else {
          _showCustomSnackBar(data['message'] ?? 'Terjadi kesalahan.',
              isError: true);
        }
      } else {
        final errorData = jsonDecode(response.body);
        _showCustomSnackBar(errorData['message'] ?? 'Kesalahan server.',
            isError: true);
      }
    } catch (e) {
      _showCustomSnackBar('Gagal terhubung ke server: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Nama Panggilan'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buat Nama Panggilan Anda',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nama Panggilan Anda akan digunakan di dalam aplikasi.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Nama Panggilan',
                  hintText: 'Masukkan Nama Panggilan Anda',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _checkNicknameAvailability,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (!_isNicknameAvailable)
              const Text(
                'Nama Panggilan sudah digunakan, pilih yang lain.',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _saveNickname,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
