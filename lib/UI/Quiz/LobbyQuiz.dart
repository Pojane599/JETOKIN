import 'package:flutter/material.dart';
import 'package:jetokin/UI/Quiz/QuizScreen.dart';

class QuizWelcomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const QuizWelcomeScreen({Key? key, required this.userData}) : super(key: key);

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Aturan Main',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Anda akan diberi waktu 1 menit untuk setiap sesi kuis.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '2. Setelah sesi kuis dimulai, Anda tidak dapat kembali.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '3. Pilih jawaban yang menurut Anda benar dalam waktu yang diberikan.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '4. Skor Anda dihitung berdasarkan jawaban yang benar.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '5. Pastikan koneksi internet Anda stabil sebelum memulai.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Mengerti',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("User Data in QuizWelcomeScreen: $userData"); // Debug log
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE52D27), // Warna merah terang
              Color(0xFFB31217), // Warna merah gelap
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Aplikasi
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Image.asset(
                'assets/img/Logo Quiz.png',
                height: 150,
              ),
            ),

            // Judul
            const Text(
              'Selamat Datang di Kuis Seru!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black54,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // Subjudul
            const Text(
              'Jelajahi pertanyaan menantang\n dan raih skor tertinggi!',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Tombol Mulai Kuis
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: Colors.black26,
                elevation: 10,
              ),
              onPressed: () {
                // Navigasi ke QuizScreen dan bawa data user
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(userData: userData),
                  ),
                );
              },
              child: const Text(
                'Mulai Kuis',
                style: TextStyle(
                  color: Color(0xFFB31217), // Merah gelap
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tombol Help
            TextButton.icon(
              onPressed: () {
                _showHelpDialog(context);
              },
              icon: const Icon(Icons.help_outline, color: Colors.white),
              label: const Text(
                'Aturan Main',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Dekorasi Bawah
            const Text(
              'Bersiaplah untuk pengalaman seru!',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
