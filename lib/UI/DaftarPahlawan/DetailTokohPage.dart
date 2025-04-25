import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jetokin/Services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

import '../../Widget/video_player_screen.dart';

class HeroDetailScreen extends StatefulWidget {
  final String baseUrl;
  final int heroId;

  const HeroDetailScreen(
      {Key? key, required this.baseUrl, required this.heroId})
      : super(key: key);

  @override
  _HeroDetailScreenState createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  late ApiService apiService;
  late Future<List<Map<String, dynamic>>> _timelineData;
  String _deskripsi = ''; // Untuk menyimpan deskripsi yang dipilih
  bool _isTimelineSelected =
      false; // Menandakan apakah timeline dipilih atau tidak
  final List<Map<String, String>> chatMessages = []; // Riwayat obrolan chatbot
  final TextEditingController messageController = TextEditingController();
  bool isLoading = false; // Indikator chatbot sedang mengetik
  List<Map<String, dynamic>> _selectedMedia = [];
  List<Map<String, dynamic>> timelineList = [];
  final ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    apiService = ApiService(baseUrl: widget.baseUrl);
    _timelineData = apiService
        .fetchHeroTimeline(widget.heroId); // Ambil timeline saat inisialisasi
  }

  void didUpdateWidget(covariant HeroDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    scrollToBottom();
  }

  /// **Render Gambar Pahlawan dengan Efek Rounded yang Lebih Besar**
  Widget _buildHeroImage(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      return const CircleAvatar(
        radius: 150, // Ukuran lebih besar dari sebelumnya
        backgroundImage: AssetImage('assets/img/default_profile.png'),
      );
    }

    return CircleAvatar(
      radius: 150, // Ukuran lebih besar dari sebelumnya
      backgroundImage: NetworkImage(photoUrl), // Gambar dari URL
    );
  }

  // Fungsi untuk mengganti deskripsi
  void _updateDeskripsi(String deskripsi) {
    setState(() {
      _deskripsi = deskripsi;
      _isTimelineSelected = true;

      if (timelineList.isEmpty) {
        _selectedMedia = [];
        return;
      }

      // Cari timeline yang cocok
      final selectedTimeline = timelineList.firstWhere(
        (timeline) =>
            timeline.containsKey('deskripsi') &&
            timeline['deskripsi'] == deskripsi,
        orElse: () => {},
      );

      // Validasi `selectedTimeline` dan `media`
      if (selectedTimeline.isNotEmpty &&
          selectedTimeline.containsKey('media') &&
          selectedTimeline['media'] is List) {
        _selectedMedia = List<Map<String, dynamic>>.from(
          selectedTimeline['media'].where((media) {
            // Filter hanya media yang valid (media_url tidak null)
            return media.containsKey('media_url') &&
                media['media_url'] != null &&
                media['media_url'].isNotEmpty;
          }),
        );
      } else {
        _selectedMedia = []; // Kosongkan jika tidak ada media valid
      }
    });
  }

  // Fungsi untuk mengirim pesan ke chatbot
  void sendMessage(String userMessage, StateSetter bottomSheetSetState) async {
    if (isLoading) return; // Hindari pengiriman pesan ganda

    bottomSheetSetState(() {
      isLoading = true;
      chatMessages.add({"user": userMessage}); // Tambahkan pesan pengguna
    });

    scrollToBottom(); // Scroll ke bawah setelah user mengirim pesan

    try {
      final response = await http.post(
        Uri.parse("${widget.baseUrl}/api/chat/${widget.heroId}"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('response')) {
          final chatbotResponse = data['response'];
          bottomSheetSetState(() {
            chatMessages.add({"bot": chatbotResponse}); // Tambahkan respons bot
          });
          scrollToBottom(); // Scroll ke bawah setelah bot merespons
        } else {
          throw Exception("Format respons tidak valid: ${response.body}");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (error) {
      bottomSheetSetState(() {
        chatMessages
            .add({"bot": "Maaf, terjadi kesalahan. Silakan coba lagi."});
      });
      print("Error during sendMessage: $error");
    } finally {
      bottomSheetSetState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk menampilkan bottom sheet chatbot
  void showChatbotBottomSheet(BuildContext context) async {
    const validTokohIds = [11, 114, 21, 31, 89, 2, 90, 65, 23, 33];

    if (!validTokohIds.contains(widget.heroId)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Chatbot Tidak Tersedia"),
            content: const Text("Chatbot untuk tokoh ini belum tersedia :("),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Tampilkan Bottom Sheet tanpa pengiriman pesan awal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomSheetSetState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                minChildSize: 0.4,
                maxChildSize: 0.8,
                expand: false,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Chat dengan Tokoh",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            reverse: true,
                            itemCount: chatMessages.length,
                            itemBuilder: (context, index) {
                              final chat =
                                  chatMessages[chatMessages.length - 1 - index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Align(
                                  alignment: chat['user'] != null
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: chat['user'] != null
                                          ? Colors.blueAccent
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      chat['user'] ?? chat['bot']!,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Bot sedang mengetik..."),
                                const SizedBox(width: 8),
                                const CircularProgressIndicator(strokeWidth: 2),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: const InputDecoration(
                                    hintText: "Tulis pesan Anda...",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  final userMessage =
                                      messageController.text.trim();
                                  if (userMessage.isNotEmpty) {
                                    sendMessage(
                                        userMessage, bottomSheetSetState);
                                    messageController.clear();
                                  }
                                },
                                icon: const Icon(Icons.send,
                                    color: Colors.blueAccent),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } catch (e) {
      print("Error saat memeriksa status chatbot: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Kesalahan"),
            content: Text("Terjadi kesalahan: $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: widget.baseUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pahlawan"),
        backgroundColor: Colors.redAccent[700],
        foregroundColor: Colors.white,
      ),
      drawer: FutureBuilder<List<Map<String, dynamic>>>(
        future: _timelineData, // Mengambil data timeline dari API
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Drawer(
                child: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Drawer(
              child: Center(
                  child: Text("Gagal memuat timeline: ${snapshot.error}")),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Drawer(
              child: Center(child: Text("Timeline tidak ditemukan")),
            );
          }

          // Simpan data ke `timelineList`
          timelineList = snapshot.data!;

          return Drawer(
            child: SafeArea(
              child: SingleChildScrollView(
                // Bungkus keseluruhan Column
                child: Column(
                  children: [
                    Container(
                      width: double.infinity, // Lebar penuh
                      color: Colors.red[700], // Warna untuk header drawer
                      padding: const EdgeInsets.all(16.0),
                      child: const Text(
                        'Timeline Pahlawan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap:
                          true, // Penting untuk mendukung scroll di SingleChildScrollView
                      physics:
                          const NeverScrollableScrollPhysics(), // Matikan scroll internal
                      itemCount: timelineList.length,
                      itemBuilder: (context, index) {
                        final timeline = timelineList[index];

                        if (!timeline.containsKey('nama_timeline') ||
                            !timeline.containsKey('deskripsi')) {
                          return const ListTile(
                            title: Text("Data tidak valid"),
                          );
                        }

                        return ListTile(
                          title: Text(timeline['nama_timeline']),
                          onTap: () {
                            // Ketika salah satu item timeline dipilih
                            _updateDeskripsi(timeline['deskripsi']);
                            Navigator.pop(
                                context); // Menutup drawer setelah pemilihan
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: apiService.fetchHeroDetail(widget.heroId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan"));
          }

          final hero = snapshot.data!;
          final baseUrl = context.read<BaseUrlProvider>().baseUrl;
          final fullPhotoUrl =
              "$baseUrl/static/images/Pahlawan/${hero["photo_url"]}";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Pahlawan
                Center(
                  child:
                      _buildHeroImage(fullPhotoUrl), // URL penuh untuk gambar
                ),
                const SizedBox(height: 16),

                // Nama Pahlawan
                Text(
                  "Nama:",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(hero['name'] ?? "Nama tidak tersedia"),

                // Menampilkan timeline jika sudah dipilih
                if (_isTimelineSelected) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Deskripsi Timeline:",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(_deskripsi),

                  // Tampilkan Media Terkait hanya jika `_selectedMedia` tidak kosong
                  if (_selectedMedia.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Media Terkait:",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // ListView.builder untuk media
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedMedia.length,
                      itemBuilder: (context, index) {
                        final media = _selectedMedia[index];

                        // Ambil atribut media dengan default
                        final mediaType = media['media_type'] ?? 'unknown';
                        final mediaUrl = media['media_url'] ??
                            ''; // Langsung gunakan media_url
                        final mediaDescription =
                            media['description'] ?? 'Tanpa deskripsi';

                        // Validasi jika URL kosong
                        if (mediaUrl.isEmpty) {
                          return ListTile(
                            leading: const Icon(Icons.error, color: Colors.red),
                            title: const Text("Media tidak valid"),
                            subtitle: Text(mediaDescription),
                          );
                        }

                        return ListTile(
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: mediaType == 'image'
                                ? CachedNetworkImage(
                                    imageUrl: mediaUrl,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.video_library),
                          ),
                          title: Text(
                            mediaType == 'image' ? 'Gambar' : 'Video',
                          ),
                          subtitle: Text(mediaDescription),
                          onTap: () {
                            // Aksi ketika media di-tap
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(mediaType == 'image'
                                      ? 'Gambar'
                                      : 'Video'),
                                  content: mediaType == 'image'
                                      ? Image.network(mediaUrl)
                                      : AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: VideoPlayerScreen(
                                            url: mediaUrl,
                                          ),
                                        ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Tutup'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    )
                  ],
                ]
                // Jika timeline belum dipilih, tampilkan bagian ini:
                else ...[
                  const SizedBox(height: 16),
                  Text(
                    "Peran:",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(hero['peran_utama'] ?? "Peran tidak diketahui"),
                  const SizedBox(height: 16),
                  Text(
                    "Tanggal Lahir:",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(hero['birth_date'] ?? "Tanggal lahir tidak diketahui"),
                  const SizedBox(height: 16),
                  Text(
                    "Biografi Singkat:",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(hero['description'] ?? "Deskripsi tidak tersedia"),
                ]
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showChatbotBottomSheet(context),
        child: const Icon(Icons.chat),
      ),
    );
  }
}
