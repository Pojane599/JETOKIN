import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/Quiz/HomeQuiz.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart'; // Tambahkan untuk audio

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const QuizScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<List<dynamic>> _quizQuestions;
  List<Map<String, dynamic>> _results = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeRemaining = 60; // Timer dalam detik
  Timer? _timer;
  bool _isCountdown = true; // Status untuk countdown
  int _countdown = 3; // Countdown dari 3
  String? _feedbackMessage;
  bool _showFeedback = false;
  final AudioPlayer _audioPlayer = AudioPlayer(); // Audio player instance
  Color? _feedbackColor; // Variabel untuk menyimpan warna feedback
  bool _isQuizStarted = false;

  void _showCustomDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(
                      context); // Kembali ke halaman sebelumnya (Lobby)
                  _resetQuizState(); // Reset status kuis
                },
                child: const Text(
                  'Kembali',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk mengambil soal kuis
  Future<List<dynamic>> fetchQuizQuestions(String baseUrl) async {
    final uri = Uri.parse(
        '$baseUrl/api/get_quizzes?user_id=${widget.userData['user_id']}');
    try {
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // Log response body

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['quizzes'] != null && data['quizzes'].isNotEmpty) {
          return data['quizzes'];
        } else {
          _showCustomDialog(
            context,
            'Tidak Ada Soal!',
            'Saat ini tidak ada soal kuis yang tersedia. Silakan coba lagi nanti.',
          );
          return [];
        }
      } else if (response.statusCode == 403) {
        // Jika pengguna sudah bermain hari ini
        _showCustomDialog(
          context,
          'Batas Kuis Tercapai!',
          'Anda sudah bermain kuis hari ini, Coba lagi besok!',
        );
        setState(() {
          _isQuizStarted = false;
        });
        _timer?.cancel(); // Hentikan timer jika berjalan

        return [];
      } else {
        _showCustomDialog(
          context,
          'Kesalahan Server',
          'Gagal memuat soal kuis. Silakan coba lagi nanti.',
        );
        throw Exception('Failed to load quiz questions');
      }
    } catch (e) {
      print('Error fetching quiz questions: $e'); // Debug error
      _showCustomDialog(
        context,
        'Terjadi Kesalahan',
        'Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda.',
      );
      throw Exception('Error fetching quiz questions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    _quizQuestions = fetchQuizQuestions(baseUrl);

    // Mulai countdown hanya jika kuis dimulai
    setState(() {
      _isQuizStarted = true; // Tandai bahwa kuis dimulai
    });
    _startCountdown();
  }

  void _resetQuizState() {
    setState(() {
      _isQuizStarted = false; // Tandai bahwa kuis tidak aktif
      _isCountdown = true; // Reset status countdown
      _countdown = 3; // Reset countdown
      _timeRemaining = 60; // Reset waktu tersisa
      _currentQuestionIndex = 0; // Reset indeks pertanyaan
      _score = 0; // Reset skor
      _results = []; // Kosongkan hasil kuis
      _feedbackMessage = null; // Hapus pesan feedback
      _showFeedback = false; // Sembunyikan feedback
    });
    _timer?.cancel(); // Hentikan timer jika berjalan
  }

  // Fungsi untuk memutar suara
  Future<void> _playCountdownSound() async {
    await _audioPlayer.play(AssetSource('audi/countdown.mp3')); // Path audio
  }

  // Fungsi untuk memutar suara 10 detik terakhir
  Future<void> _playLast10SecondsSound() async {
    await _audioPlayer.play(AssetSource(
        'audio/countdown_last10.mp3')); // Suara khusus untuk 10 detik terakhir
  }

  // Fungsi untuk memulai hitung mundur
  void _startCountdown() {
    if (!_isQuizStarted)
      return; // Jangan mulai countdown jika kuis belum dimulai

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _playCountdownSound(); // Mainkan suara hitung mundur
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountdown = false; // Selesai hitung mundur
        });
        _startTimer(); // Mulai timer kuis
      }
    });
  }

  // Fungsi untuk memulai timer kuis
  void _startTimer() {
    if (!_isQuizStarted) return; // Jangan mulai timer jika kuis belum dimulai

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 13) {
        setState(() {
          _timeRemaining--;
        });
      } else if (_timeRemaining <= 13 && _timeRemaining > 0) {
        // Mainkan suara khusus ketika tersisa 10 detik
        _playLast10SecondsSound();
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
        _saveQuizResults(); // Simpan hasil jika waktu habis
      }
    });
  }

  // Tambahkan variabel untuk menyimpan hasil jawaban
  void _nextQuestion(bool isCorrect, int quizId, int points) {
    setState(() {
      // Tampilkan feedback
      _feedbackMessage = isCorrect ? 'Benar!' : 'Salah!';
      _showFeedback = true;

      // Simpan hasil ke _results
      _results.add({
        'quiz_id': quizId,
        'score': isCorrect ? points : 0,
      });

      if (isCorrect) {
        _score += points;
      }

      // Delay 1 detik sebelum lanjut ke pertanyaan berikutnya
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _showFeedback = false; // Sembunyikan feedback
          if (_currentQuestionIndex < 9) {
            _currentQuestionIndex++;
          } else {
            _timer?.cancel();
            _saveQuizResults();
          }
        });
      });
    });
  }

  Future<void> _saveQuizResults() async {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
    final uri = Uri.parse('$baseUrl/api/save_quiz_results');

    try {
      // Debug data sebelum dikirim
      print('Mengirim data ke API:');
      print(jsonEncode({
        'user_id': widget.userData['user_id'],
        'results': _results,
      }));

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userData['user_id'],
          'results': _results,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final totalScore =
            responseData['total_score']; // Ambil skor total dari response

        // Reset status kuis
        _resetQuizState();

        // Navigasi ke layar hasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: totalScore, // Kirim skor total ke ResultScreen
              userData: widget.userData,
            ),
          ),
        );
      } else {
        // Debug: Cetak respons error
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to save quiz results');
      }
    } catch (e) {
      print('Error during saveQuizResults: $e'); // Debug error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to save quiz results'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Hentikan timer saat layar ditutup
    _audioPlayer.dispose(); // Bebaskan audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Nonaktifkan tombol kembali
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quiz'),
              Text(
                _isCountdown
                    ? "Countdown: $_countdown"
                    : "Time: $_timeRemaining sec", // Tampilkan waktu tersisa
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _quizQuestions,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No quiz questions available"));
            }

            if (_isCountdown) {
              return Center(
                child: Text(
                  "$_countdown",
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              );
            }

            if (_showFeedback) {
              return Center(
                child: Text(
                  _feedbackMessage!,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _feedbackColor, // Warna dinamis berdasarkan jawaban
                  ),
                ),
              );
            }

            final quizQuestions = snapshot.data!;
            final currentQuestion = quizQuestions[_currentQuestionIndex];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indikator progress
                  LinearProgressIndicator(
                    value:
                        (_currentQuestionIndex + 1) / 10, // Progress dari 0-1
                    backgroundColor: Colors.grey[300],
                    color: Colors.redAccent,
                  ),
                  const SizedBox(
                      height: 10), // Spasi antara indikator dan teks soal
                  Text(
                    "Pertanyaan ${_currentQuestionIndex + 1}/10",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQuestion['question'],
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                          height: 10), // Spasi antara pertanyaan dan poin
                      Text(
                        "Poin: ${currentQuestion['points']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors
                              .redAccent, // Warna merah untuk menonjolkan poin
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  ...(currentQuestion['options'] as List<dynamic>)
                      .map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: 10.0), // Jarak antar tombol
                      child: SizedBox(
                        width: double.infinity, // Lebar penuh
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            final isCorrect =
                                option == currentQuestion['correct_answer'];
                            setState(() {
                              // Tampilkan feedback dinamis
                              _feedbackMessage =
                                  isCorrect ? 'Benar!' : 'Salah!';
                              _feedbackColor =
                                  isCorrect ? Colors.green : Colors.red;
                              _showFeedback = true;
                            });

                            // Delay 1 detik sebelum lanjut ke pertanyaan berikutnya
                            Future.delayed(const Duration(seconds: 1), () {
                              _nextQuestion(
                                isCorrect, // Benar atau salah
                                currentQuestion['quiz_id'], // ID kuis
                                currentQuestion['points'], // Poin dari soal
                              );
                            });
                          },
                          child: Text(
                            option,
                            textAlign: TextAlign.center, // Pusatkan teks
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final Map<String, dynamic> userData;

  const ResultScreen({
    Key? key,
    required this.score,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF0000), // Merah Tua
              Color(0xFFFF7373), // Merah Muda
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Ilustrasi
            const Icon(
              Icons.emoji_events_rounded,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),

            // Judul
            const Text(
              'Selamat!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Pesan hasil
            Text(
              'Anda telah menyelesaikan kuis!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Tampilan skor
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Skor Anda:',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Tombol kembali ke beranda
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Homequiz(userData: userData),
                  ),
                );
              },
              child: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  color: Color(0xFFFF0000), // Warna teks merah
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
