import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/Models/Quiz/LeaderboardItem.dart';
import 'package:jetokin/NavBar/NavBar.dart';
import 'package:jetokin/UI/Quiz/LobbyQuiz.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

class Homequiz extends StatefulWidget {
  final Map<String, dynamic> userData;
  final http.Client? client; // Tambahkan parameter client

  const Homequiz({Key? key, required this.userData, this.client})
      : super(key: key);

  @override
  _HomequizScreenState createState() => _HomequizScreenState();
}

class _HomequizScreenState extends State<Homequiz> {
  // Gunakan widget.client atau buat instance default jika null
  late http.Client client;
  late Future<List<LeaderboardItem>> _thisWeekData;
  bool _showThisWeek = true; // Default ke data This Week

  Future<List<LeaderboardItem>> fetchLeaderboardData(
      String baseUrl, String weekType) async {
    final uri = Uri.parse(
        '$baseUrl/api/leaderboard?week=$weekType'); // Tambahkan parameter week
    print("Requesting leaderboard data: $uri"); // Debugging
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Response Data: $data"); // Log untuk melihat respons API

      if (data != null && data.containsKey('leaderboard')) {
        final leaderboard = data['leaderboard'];
        if (leaderboard is List) {
          return leaderboard
              .map((item) => LeaderboardItem.fromJson(item, baseUrl))
              .toList();
        } else {
          throw Exception('Invalid leaderboard format');
        }
      } else {
        throw Exception('Missing leaderboard in response');
      }
    } else {
      throw Exception('Failed to load leaderboard data');
    }
  }

  Future<Map<String, dynamic>> fetchPlayerPerformance(
      String baseUrl, int? userId, bool isThisWeek) async {
    // Validasi parameter awal
    if (baseUrl.isEmpty) {
      throw Exception('Base URL belum diinisialisasi.');
    }
    if (userId == null) {
      throw Exception('User ID belum diinisialisasi.');
    }

    final uri = Uri.parse(
        '$baseUrl/api/player-performance/${isThisWeek ? "this-week" : "last-week"}/$userId');

    // Tambahkan log untuk debugging
    print("Fetching player performance for user ID: $userId");
    print("Week type: ${isThisWeek ? 'this-week' : 'last-week'}");
    print("Request URL: $uri");

    try {
      final response = await client.get(uri);

      // Log response status
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Validasi data yang diterima
        if (data == null || data.isEmpty) {
          throw Exception('Data kosong atau tidak valid dari API.');
        }

        // Pastikan data memiliki field yang diharapkan
        final totalScore = data['total_score'];
        final ranking = data['ranking'];
        final betterThanPercentage = data['better_than_percentage'];

        // Validasi tambahan untuk field data
        if (totalScore == null ||
            ranking == null ||
            betterThanPercentage == null) {
          throw Exception(
              'Field penting dalam data API tidak ditemukan atau bernilai null.');
        }

        // Log data yang diterima
        print('Total Score: $totalScore');
        print('Ranking: $ranking');
        print('Better Than Percentage: $betterThanPercentage');

        return data;
      } else {
        // Log error jika status code bukan 200
        print("Error: ${response.statusCode}, Response: ${response.body}");
        throw Exception(
            'Failed to load player performance, status code: ${response.statusCode}');
      }
    } catch (e) {
      // Tangani error jaringan atau parsing
      print("Error during fetchPlayerPerformance: $e");
      throw Exception('Error fetching player performance: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    print("HomeQuiz screen initialized");

    // Pastikan user_id ada di widget.userData
    if (widget.userData['user_id'] == null) {
      print("User ID tidak ditemukan di widget.userData");
    } else {
      print("User ID ditemukan: ${widget.userData['user_id']}");
    }

    // Set default values if necessary
    widget.userData['total_score'] ??= 0;
    widget.userData['ranking'] ??= 'N/A';
    widget.userData['better_than_percentage'] ??= 0;
    client = widget.client ?? http.Client();
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 18) {
      return "Selamat Siang";
    } else {
      return "Selamat Sore";
    }
  }

  Widget _buildPlayerPerformanceWidget(bool isThisWeek) {
    print(
        "Building Player Performance Widget for: ${isThisWeek ? 'this-week' : 'last-week'}");

    return FutureBuilder<Map<String, dynamic>>(
      key: ValueKey("${isThisWeek}-${DateTime.now()}"),
      future: fetchPlayerPerformance(
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl,
        widget.userData['user_id'],
        isThisWeek,
      ),
      builder: (context, snapshot) {
        print("Snapshot ConnectionState: ${snapshot.connectionState}");
        print("Snapshot Error: ${snapshot.error}");
        print("Snapshot Data: ${snapshot.data}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return const Text("Tidak ada data performa tersedia.");
        }

        final data = snapshot.data!;
        final totalScore =
            int.tryParse(data['total_score']?.toString() ?? '0') ?? 0;
        print("Data received: $data"); // Periksa data yang diterima
        final ranking = data['ranking'] ?? 'N/A';
        final betterThanPercentage = data['better_than_percentage'] ?? 0;

        print(
            "Total Score: $totalScore, Ranking: $ranking, Better Than: $betterThanPercentage");

        final weekText = isThisWeek ? "minggu ini" : "minggu lalu";

        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isThisWeek ? Colors.orangeAccent : Colors.blueAccent,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isThisWeek ? Colors.orange : Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  "#$ranking",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  "Anda melakukan lebih baik dari $betterThanPercentage% pemain pada $weekText!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // Tinggi AppBar disesuaikan
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.red,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 32.0, 16.0, 16.0), // Padding atas dan samping
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.end, // Elemen di bawah AppBar
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Column untuk Greeting Message dan Username
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getGreetingMessage(), // Greeting Message
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4), // Jarak antara teks
                          Text(
                            widget.userData['nickname'] ??
                                'Player', // Username di bawah
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Button "Mau Main Quiz?"
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuizWelcomeScreen(userData: widget.userData),
                          ),
                        );
                      },
                      child: const Text(
                        "Mau Main Quiz?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Container untuk "Papan Peringkat"
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            alignment: Alignment.center,
            child: Text(
              "Papan Peringkat",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // FutureBuilder untuk Player Performance
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _showThisWeek
                ? _buildPlayerPerformanceWidget(true) // Widget untuk minggu ini
                : _buildPlayerPerformanceWidget(
                    false), // Widget untuk minggu lalu
          ),

          // Tabs for This Week and Last Week
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showThisWeek = false; // Berpindah ke Last Week
                    });
                    print(
                        "Tab berubah ke: Minggu Lalu, State diperbarui: $_showThisWeek");
                  },
                  child: Text(
                    "Minggu Lalu",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !_showThisWeek ? Colors.purple : Colors.grey,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showThisWeek = true; // Berpindah ke This Week
                    });
                    print(
                        "Tab berubah ke: Minggu Ini, State diperbarui: $_showThisWeek");
                  },
                  child: Text(
                    "Minggu ini",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _showThisWeek ? Colors.purple : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Leaderboard Data
          Expanded(
            child: FutureBuilder<List<LeaderboardItem>>(
              future: fetchLeaderboardData(
                Provider.of<BaseUrlProvider>(context, listen: false).baseUrl,
                _showThisWeek
                    ? "this-week"
                    : "last-week", // Parameter week untuk API
              ),
              builder: (context, snapshot) {
                // Debugging untuk melihat state FutureBuilder
                print("ConnectionState: ${snapshot.connectionState}");
                print("Error: ${snapshot.error}");
                print("Data: ${snapshot.data}");

                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error State
                if (snapshot.hasError) {
                  print("Error Occurred: ${snapshot.error}");
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Empty State
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print("No Data Found");
                  return const Center(
                    child: Text(
                      "No leaderboard data available.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  );
                }

                // Debugging Data
                for (var item in snapshot.data!) {
                  print(
                      "User: ${item.nickname}, Score: ${item.score}, Rank: ${item.ranking}");
                }

                // Success State
                final leaderboardList = snapshot.data!;
                print("Leaderboard Data Loaded Successfully: $leaderboardList");

                // Render leaderboard
                return _buildThisWeekLeaderboard(leaderboardList);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  // Widget for This Week Leaderboard
  Widget _buildThisWeekLeaderboard(List<LeaderboardItem> leaderboardList) {
    final top3 = leaderboardList.take(3).toList(); // Top 3 players
    final remaining =
        leaderboardList.skip(3).toList(); // Remaining players (4-10)

    return Stack(
      children: [
        // Bagian Podium (Top 3)
        Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Posisi Kedua (Top 2)
                      Transform.translate(
                        offset: const Offset(25, 40), // Geser lebih ke bawah
                        child: _buildTopPosition(
                            top3.length > 1 ? top3[1] : null, 2),
                      ),
                      const SizedBox(width: 16),
                      // Posisi Pertama (Top 1)
                      _buildTopPosition(top3.isNotEmpty ? top3[0] : null, 1),
                      const SizedBox(width: 16),
                      // Posisi Ketiga (Top 3)
                      Transform.translate(
                        offset: const Offset(-25, 80), // Geser lebih ke bawah
                        child: _buildTopPosition(
                            top3.length > 2 ? top3[2] : null, 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Jarak antara avatar dan podium
                  // Gambar podium di bawah avatar
                  _buildPodium(),
                ],
              ),
            ),
          ],
        ),

        // Container untuk Top 4–10
        Positioned(
          top: 350, // Sesuaikan posisi agar menimpa podium
          left: 0,
          right: 0,
          bottom: -40,
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 16.0), // Margin kiri/kanan
            padding: const EdgeInsets.only(top: 16.0), // Padding atas
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0), // Membulatkan sudut
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4), // Shadow di bawah
                ),
              ],
            ),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16.0),
              itemCount:
                  remaining.length, // Jumlah item di remaining (top 4–10)
              itemBuilder: (context, index) {
                final leaderboard = remaining[index];
                final rank = index + 4; // Mulai dari posisi ke-4
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    leading: CircleAvatar(
                      radius: 28.0,
                      backgroundImage: leaderboard.profilePicture.isNotEmpty
                          ? NetworkImage(leaderboard.profilePicture)
                          : null,
                      backgroundColor: Colors.grey.shade300,
                      child: leaderboard.profilePicture.isEmpty
                          ? Text(
                              rank.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      leaderboard.nickname,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: Text(
                      '${leaderboard.score} poin',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                      ),
                    ),
                    trailing: Text(
                      '#$rank',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 26.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Top Position Card
  Widget _buildTopPosition(LeaderboardItem? item, int position) {
    final double avatarSize = position == 1 ? 80 : 70; // Ukuran avatar

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar pemain
          CircleAvatar(
            radius: avatarSize / 2,
            backgroundImage: item?.profilePicture.isNotEmpty == true
                ? NetworkImage(item!.profilePicture)
                : null,
            backgroundColor: position == 1
                ? Colors.yellowAccent
                : position == 2
                    ? Colors.grey
                    : Colors.brown,
            child: item?.profilePicture.isEmpty == true
                ? Text(
                    '${item?.nickname.substring(0, 1) ?? '-'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),

          // Nama pemain
          Text(
            item?.nickname ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Skor pemain
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${item?.score ?? 0} poin',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Posisi kedua (kiri)
        Expanded(
          child: Image.asset(
            'assets/img/Podium.png', // Path gambar podium
            height: 280, // Tinggi podium
            alignment: Alignment.bottomCenter,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
