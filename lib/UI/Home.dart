import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jetokin/NavBar/NavBar.dart';
import 'package:jetokin/UI/DaftarPahlawan/Daftar_Pahlawan.dart';
import 'package:jetokin/UI/EditProfil.dart';
import 'package:jetokin/UI/Quiz/HomeQuiz.dart';
import 'package:jetokin/UI/SentimentPage.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:jetokin/NavBarProvider.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final http.Client?
      client; // Tambahkan parameter client untuk inject MockClient

  const HomePage({super.key, required this.userData, this.client});

  @override
  _HomePageState createState() => _HomePageState();
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  bool _isLoading = false;
  String _predictionResult = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print('User Data di HomePage: ${widget.userData}');

    // Inisialisasi notifikasi lokal
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
        }
      },
    );

    // Periksa apakah ada hari penting untuk menampilkan notifikasi
    _checkImportantDayForNotification();
  }

  Future<void> _checkImportantDayForNotification() async {
    final importantDay = await fetchImportantDay();

    if (importantDay != null) {
      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id',
        'Hari Penting',
        channelDescription: 'Notifikasi Hari Penting',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true, // Untuk suara notifikasi
        enableVibration: true,
        showWhen: true,
      );

      const platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        0, // ID notifikasi
        'Hari Penting!',
        'Hari ini adalah"${importantDay['nama']}"',
        platformChannelSpecifics,
        payload: 'Hari penting: ${importantDay['nama']}', // Tambahkan payload
      );
    }
  }

  Future<Map<String, dynamic>?> fetchImportantDay() async {
    // Ambil URL base dari BaseUrlProvider
    final String baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    // Gabungkan baseUrl dengan endpoint API
    final String apiUrl = '$baseUrl/api/hari-penting';

    try {
      // Kirim permintaan HTTP GET ke API Flask
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Ubah respons API ke dalam bentuk JSON
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['data']; // Hanya kembalikan data penting (jika ada)
      } else {
        return null; // Jika gagal, kembalikan null
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null; // Jika terjadi error, kembalikan null
    }
  }

  //---Fungsi Pilih gambar
  Future<void> _pickImage() async {
    // Pilih gambar dari galeri atau kamera
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isLoading = true;
      });

      // Upload gambar ke server Flask untuk deteksi
      await _uploadImage();
    }
  }

  //---Fungsi upload gambar
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    setState(() {
      _isLoading = true;
    });

    final String baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    final uri = Uri.parse('$baseUrl/api/upload_image');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        // Jika berhasil, baca hasil prediksi dari respons
        final result = await response.stream.bytesToString();
        final Map<String, dynamic> resultData = jsonDecode(result);

        if (resultData['status'] == 'success') {
          final predictedClass = resultData['data']['predicted_class'];
          final List<dynamic> tokohList = resultData['data']['tokoh'];

          setState(() {
            _predictionResult = 'Hasil Deteksi: $predictedClass\n\n';
            _predictionResult += 'Tokoh Terkait:\n';
            for (var tokoh in tokohList) {
              _predictionResult +=
                  '- ${tokoh['name']}: ${tokoh['description']}\n';
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _predictionResult =
                'Gagal mendeteksi gambar: ${resultData['message']}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _predictionResult =
              'Gagal menghubungi server. Kode: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Kesalahan saat mengunggah gambar: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final navBarProvider = Provider.of<NavBarProvider>(context);
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
    final userName = widget.userData['nickname'] ?? 'Pengguna';

    void _navigateToPage(int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userData: widget.userData),
            ),
          );
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Homequiz(userData: widget.userData)),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HeroSearchScreenWithButton(
                baseUrl: baseUrl,
                userData: widget.userData,
              ),
            ),
          );
          break;
        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditProfilePage(userEmail: widget.userData['email'] ?? ''),
            ),
          );
          break;
      }
    }

    navBarProvider.addListener(() {
      _navigateToPage(navBarProvider.currentIndex);
    });

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.red,
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 32.0, 16.0, 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Selamat Datang,",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            // Membungkus Column agar bisa di-scroll
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Penataan horizontal
              children: [
                // Menampilkan Hari Penting
                FutureBuilder<Map<String, dynamic>?>(
                  future: fetchImportantDay(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          strokeWidth: 3.5,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Terjadi kesalahan saat memuat data.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      final importantDay = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_month_rounded,
                                  color: Colors.white, size: 32),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Memperingati "${importantDay['nama']}"',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                const SizedBox(height: 30),

                // Teks ajakan untuk coba fitur deteksi
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Ayo Coba Fitur Deteksi Pahlawan Kami!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: _pickImage, // Fungsi untuk memilih gambar
                    borderRadius: BorderRadius.circular(
                        12), // Efek melingkar saat ditekan
                    child: Container(
                      width: double.infinity, // Lebar penuh
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Pilih Gambar untuk Deteksi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Menampilkan Gambar yang Dipilih
                _imageFile != null
                    ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              100), // Menjadikan gambar bulat
                          child: Image.file(
                            _imageFile!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 20),

                // Menampilkan Status Loading atau Hasil Prediksi
                // Menampilkan Status Loading atau Hasil Prediksi
                _isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LinearProgressIndicator(
                              backgroundColor: Colors.blueGrey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Memproses...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_predictionResult.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.teal, Colors.blueAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Hasil Deteksi:',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _predictionResult,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox()),

                // Tombol Arahkan ke Halaman Sentimen
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      // Navigasi ke halaman SentimentPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SentimentPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(
                        12), // Efek melingkar saat ditekan
                    child: Container(
                      width: double.infinity, // Lebar penuh
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.comment_outlined,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Berikan Komentar Anda",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const NavBar(),
      ),
    );
  }
}
