import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jetokin/UI/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:jetokin/UI/Home.dart'; // Import HomePage
import 'package:jetokin/NavBarProvider.dart'; // Import NavBarProvider
import 'package:jetokin/NavBar/NavBar.dart';

class EditProfilePage extends StatefulWidget {
  final String userEmail;

  const EditProfilePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Map<String, dynamic> userData = {};
  late TextEditingController fullnameController;
  late TextEditingController nicknameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController();
    nicknameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/api/get_user/${widget.userEmail}'))
          .timeout(const Duration(seconds: 10)); // Timeout setelah 10 detik

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);

          setState(() {
            userData = responseData;
            fullnameController.text = userData['fullname'] ?? '';
            nicknameController.text = userData['nickname'] ?? '';
            emailController.text = userData['email'] ?? '';

            // Gunakan langsung URL dari backend
            String profilePictureUrl = userData['profile_picture'] ?? '';
            userData['profile_picture'] = profilePictureUrl.isNotEmpty
                ? profilePictureUrl
                : '$baseUrl/static/uploads/default.png';
          });
        } catch (e) {
          print("Error parsing user data: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data pengguna tidak valid')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data pengguna')),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data: Waktu habis')),
      );
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data: Tidak ada koneksi')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _updateUserProfile() async {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    if (fullnameController.text.trim().isEmpty ||
        !RegExp(r"^[a-zA-Z ]+$").hasMatch(fullnameController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap tidak valid')),
      );
      return;
    }

    if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email tidak valid')),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak cocok')),
      );
      return;
    }

    final updateData = {
      'user_id': userData['user_id'].toString(),
      'fullname': fullnameController.text,
      'nickname': nicknameController.text,
      'email': emailController.text,
      'gender': userData['gender'],
      'password': newPasswordController.text.isNotEmpty
          ? newPasswordController.text
          : passwordController.text,
      'profile_picture':
          userData['profile_picture']?.replaceFirst(baseUrl, '') ?? '',
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/update_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui profil')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

// Fungsi untuk Mengunggah Foto Profil ke Server
  Future<void> _uploadProfilePicture(String filePath) async {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload_profile_picture'),
      );

      // Tambahkan `user_id` yang diperlukan untuk pengenalan user
      request.fields['user_id'] = userData['user_id'].toString();

      // Tambahkan file yang akan diunggah
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      // Kirim permintaan ke server
      var response = await request.send();

      if (response.statusCode == 200) {
        // Mengambil response dari server
        var responseData = await response.stream.bytesToString();
        var decodedData = jsonDecode(responseData);

        // Update data foto profil dengan URL yang diterima
        setState(() {
          userData['profile_picture'] = decodedData['path']; // path dari server
        });

        // Memanggil ulang fungsi untuk mengambil data terbaru (refresh data profil)
        await _fetchUserData();

        // Tampilkan notifikasi berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui')),
        );
      } else {
        // Jika ada error pada server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal memperbarui foto profil: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // Tangani error jika gagal meng-upload
      print("Error uploading profile picture: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

// Fungsi untuk ambil gambar di perangkat
  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Tampilkan gambar di UI terlebih dahulu
      setState(() {
        userData['profile_picture'] = pickedFile.path;
      });

      // Unggah gambar ke server setelah dipilih
      _uploadProfilePicture(pickedFile.path);
    } else {
      // Jika tidak ada file yang dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada gambar yang dipilih')),
      );
    }
  }

  Future<void> _logout() async {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print("Logout berhasil di server");

        // Clear session and navigate to LoginPage
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen(baseUrl: '')),
            (route) => false, // Hapus semua halaman dari stack
          );
        });
      } else {
        print("Gagal logout di server: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal logout di server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk menampilkan dialog konfirmasi penghapusan akun
  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus Akun'),
          content: const Text('Apakah Anda yakin ingin menghapus akun ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  /// Fungsi untuk menghapus akun
  Future<void> _deleteAccount() async {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/delete_account/${userData['user_id']}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dihapus')),
        );

        // Navigasi ke halaman Login
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginScreen(baseUrl: '')),
            (route) => false,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus akun')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // Tinggi AppBar disesuaikan
        child: AppBar(
          automaticallyImplyLeading: false, // Hilangkan tombol back
          backgroundColor: Colors.red,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 32.0, 16.0, 16.0), // Padding manual
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/img/Logo Apps.png',
                        height: 40, // Sesuaikan ukuran logo
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'JETOKIN',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
          ),
        ),
      ),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Tempatkan tombol di kanan
                      children: [
                        ElevatedButton(
                          onPressed: _showDeleteAccountDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: const Text(
                            "Hapus Akun?",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          backgroundImage:
                              userData['profile_picture'] != null &&
                                      userData['profile_picture'].isNotEmpty
                                  ? NetworkImage(userData['profile_picture'])
                                  : const AssetImage('assets/img/Logo Apps.png')
                                      as ImageProvider,
                          onBackgroundImageError: (_, __) {
                            // Jika gambar gagal dimuat
                            print(
                                "Failed to load image: ${userData['profile_picture']}");
                            setState(() {
                              userData['profile_picture'] =
                                  '$baseUrl/static/uploads/default.png'; // Fallback
                            });
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.blue,
                              size: 30,
                            ),
                            onPressed: _pickProfilePicture,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                        label: 'Nama', controller: fullnameController),
                    buildTextField(
                        label: 'Nama Panggilan',
                        controller: nicknameController),
                    buildTextField(
                        label: 'Email',
                        controller: emailController,
                        readOnly: true),
                    buildGenderField(gender: userData['gender'] ?? 'Perempuan'),
                    buildPasswordField(
                        label: 'Kata Sandi Lama',
                        controller: passwordController),
                    buildPasswordField(
                        label: 'Kata Sandi Baru',
                        controller: newPasswordController),
                    buildPasswordField(
                        label: 'Masukkan Lagi',
                        controller: confirmPasswordController),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text(
                        'Simpan Perubahan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavBar(),
    );
  }

  Widget buildGenderField({required String gender}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: gender,
        decoration: const InputDecoration(
          labelText: 'Jenis Kelamin',
          border: OutlineInputBorder(),
        ),
        items: const [
          DropdownMenuItem(
            value: 'Perempuan',
            child: Text('Perempuan'),
          ),
          DropdownMenuItem(
            value: 'Laki-laki',
            child: Text('Laki-laki'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            userData['gender'] = value;
          });
        },
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly, // Membuat field tidak dapat diedit
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  readOnly ? Colors.grey : Colors.black, // Border saat read-only
            ),
          ),
          labelStyle: TextStyle(
            color: readOnly
                ? Colors.grey
                : Colors.black, // Warna label saat read-only
          ),
          fillColor: readOnly
              ? Colors.grey[200]
              : null, // Background warna saat read-only
          filled: readOnly, // Aktifkan background jika read-only
        ),
        style: TextStyle(
          color: readOnly
              ? Colors.grey
              : Colors.black, // Warna teks saat read-only
        ),
      ),
    );
  }

  Widget buildPasswordField(
      {required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
