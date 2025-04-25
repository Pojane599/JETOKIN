import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/Login.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart'; // Pastikan sudah di-import

class SplashScreen extends StatelessWidget {
  final http.Client? mockClient; // Tambahkan parameter opsional
  const SplashScreen({Key? key, this.mockClient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ambil baseUrl dari Provider
    final baseUrl = Provider.of<BaseUrlProvider>(context).baseUrl;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9E1B1B), Color(0xFF874D4F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Konten utama
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animasi Logo
                Hero(
                  tag: 'appLogo',
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/img/Logo Apps.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Teks Judul dengan efek fade
                const Text(
                  'Jejak Tokoh Indonesia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Deskripsi singkat
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Temukan kisah menarik dan inspiratif dari tokoh-tokoh hebat Indonesia. Dari masa lalu hingga masa kini!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                // Tombol Mulai dengan animasi hover
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman Login
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            baseUrl: baseUrl,
                            client: mockClient, // Teruskan mockClient ke LoginScreen
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      shadowColor: Colors.black.withOpacity(0.2),
                      elevation: 10,
                    ),
                    child: const Text(
                      'Mulai',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9E1B1B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Animasi teks di bagian bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Powered by JETOKIN © 2024',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
