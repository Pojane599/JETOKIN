import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/SetNicknameScreen.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  // Tambahkan metode publik untuk validasi email
  static bool isEmailValid(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isLoading = false; // Loading indicator

  String? _selectedGender;
  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  // Toggle untuk password
  void _togglePasswordVisibility() {
    setState(() {
      _obscureTextPassword = !_obscureTextPassword;
    });
  }

  // Toggle untuk konfirmasi password
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
    });
  }

  // Fungsi untuk memvalidasi email dengan regex
  bool _isEmailValid(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi input email
    if (email.isEmpty || !_isEmailValid(email)) {
      _showErrorDialog('Masukkan alamat email yang valid');
      return;
    }

    // Validasi password
    if (password != confirmPassword) {
      _showErrorDialog('Konfirmasi kata sandi tidak sesuai');
      return;
    }

    // Validasi checkbox syarat dan ketentuan
    if (!_agreeToTerms) {
      _showErrorDialog('Anda harus menyetujui syarat dan ketentuan');
      return;
    }

    // Validasi input lainnya
    if (name.isEmpty || password.isEmpty || _selectedGender == null) {
      _showErrorDialog('Harap isi semua kolom');
      return;
    }

    // Pastikan gender yang dikirimkan sesuai dengan format yang diterima server
    String genderToSend = _selectedGender ?? 'Laki-laki';

    setState(() {
      _isLoading = true; // Set loading menjadi true
    });

    // Ambil baseUrl dari Provider
    final baseUrl =
        Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;

    // Tentukan URL foto profil default
    String defaultProfilePicture = 'default.png';

    // Proses registrasi
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'), // Gunakan baseUrl dari provider
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': name,
          'email': email,
          'password': password,
          'gender': genderToSend,
          'profile_picture':
              defaultProfilePicture, // Kirim URL default foto profil
        }),
      );

      setState(() {
        _isLoading = false; // Set loading menjadi false setelah proses selesai
      });

      if (response.statusCode == 201) {
        // Jika registrasi berhasil
        final responseData = jsonDecode(response.body);

        // Ambil userId dari respons server
        final userId = responseData['user_id'];
        print('User ID received: $userId');

        // Simpan userId di SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);

        // Tampilkan dialog sukses
        await _showSuccessDialog('Pendaftaran berhasil!');

        // Arahkan ke halaman berikutnya
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetNicknameScreen(
              email: email,
              userData: {
                'user_id': userId,
                'email': email
              }, // Tambahkan user_id
            ),
          ),
        );
      } else {
        // Jika registrasi gagal
        final data = jsonDecode(response.body);
        _showErrorDialog(data['message'] ?? 'Terjadi kesalahan pada server');
      }
    } catch (e) {
      setState(() {
        _isLoading = false; // Set loading menjadi false jika gagal
      });
      _showErrorDialog('Gagal terhubung ke server: $e');
    }
  }

  // Fungsi untuk menampilkan dialog kesalahan
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kesalahan'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog sukses kustom
  Future<void> _showSuccessDialog(String message) async {
    // Tampilkan dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan klik di luar
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 50,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    // Tunggu 2 detik sebelum menutup dialog
    await Future.delayed(const Duration(seconds: 2));

    // Tutup dialog
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image and overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/Background login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.white.withOpacity(0.7),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 100),
                    const Text(
                      'Buat Akun!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mendaftar untuk memulai',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                        _nameController, 'Nama Lengkap', Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(
                        _emailController, 'Alamat Email', Icons.email),
                    const SizedBox(height: 10),
                    _buildPasswordField(_passwordController, 'Kata Sandi',
                        _obscureTextPassword, _togglePasswordVisibility),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                        _confirmPasswordController,
                        'Konfirmasi Kata Sandi',
                        _obscureTextConfirmPassword,
                        _toggleConfirmPasswordVisibility),
                    const SizedBox(height: 20),
                    _buildGenderDropdown(),
                    const SizedBox(height: 20),
                    _buildTermsCheckbox(),
                    _isLoading
                        ? const CircularProgressIndicator() // Spinner saat loading
                        : _buildRegisterButton(),
                    // const SizedBox(height: 10),
                    // const Text('Atau terhubung melalui'),
                    // _buildSocialLoginButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscureText, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      hint: const Text('Pilih Jenis Kelamin'),
      items: _genders.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: <Widget>[
        Checkbox(
          value: _agreeToTerms,
          onChanged: (bool? value) {
            setState(() {
              _agreeToTerms = value ?? false;
            });
          },
        ),
        const Text('Saya setuju dengan syarat dan ketentuan'),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 245, 105, 92),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: const Text(
        'Daftar',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  // Widget _buildSocialLoginButtons() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: <Widget>[
  //       _buildSocialLoginButton('Google', 'assets/img/google_logo.png'),
  //       const SizedBox(width: 20),
  //     ],
  //   );
  // }

  // Widget _buildSocialLoginButton(String label, String imagePath) {
  //   return ElevatedButton(
  //     onPressed: () {
  //       // Tindakan login berdasarkan label
  //     },
  //     style: ElevatedButton.styleFrom(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       padding: const EdgeInsets.all(12),
  //     ),
  //     child: Image.asset(
  //       imagePath,
  //       height: 40,
  //       width: 40,
  //     ),
  //   );
  // }
}
