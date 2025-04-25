import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jetokin/UI/SetNicknameScreen.dart';
import 'LupaSandi.dart';
import 'Register.dart';
import 'Home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final String baseUrl; // Base URL untuk API Flask
  final http.Client? client; // Tambahkan parameter opsional untuk MockClient

  const LoginScreen({Key? key, required this.baseUrl, this.client})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false; // Untuk indikator loading

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap masukkan email dan kata sandi')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Gunakan client yang diinject atau default ke http.Client
      final client = widget.client ?? http.Client();

      // Pastikan baseUrl valid
      final baseUrl = widget.baseUrl;
      if (baseUrl == null || baseUrl.isEmpty) {
        throw const FormatException('Base URL tidak ditemukan');
      }

      // Log URL yang akan diakses
      final apiUrl = Uri.parse('$baseUrl/api/login');
      print('Mengakses URL: $apiUrl');

      // Kirim permintaan ke API Login
      final response = await client.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Log respons dari server
      print('Respons server: ${response.body}');
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = data['user'];
        setState(() {
          _isLoading = false;
        });

        // Tampilkan dialog sukses
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
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
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'LOGIN BERHASIL',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Tunggu 2 detik sebelum navigasi
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);

        // Navigasi ke HomePage atau SetNicknameScreen
        if (userData['nickname'] == null || userData['nickname'].isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SetNicknameScreen(
                userData: userData['user_id'],
                email: userData['email'],
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(userData: userData),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        final errorMessage = data['message'] ?? 'Login gagal';
        print('Error dari server: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } on FormatException catch (e) {
      print('Kesalahan format URL: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak valid')),
      );
    } on SocketException catch (e) {
      print('Kesalahan jaringan: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal terhubung ke server')),
      );
    } on http.ClientException catch (e) {
      print('Kesalahan HTTP Client: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kesalahan saat mengirim permintaan ke server')),
      );
    } catch (e) {
      print('Kesalahan tidak terduga: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kesalahan: ${e.toString()}')),
      );
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true; // Menampilkan indikator loading
    });

    try {
      // 1. Proses Google Sign-In
      print('Memulai proses Google Sign-In...');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Jika pengguna membatalkan login
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proses login dibatalkan')),
        );
        setState(() {
          _isLoading = false; // Menyembunyikan indikator loading
        });
        return;
      }

      // Log data Google Sign-In
      print('Google User Email: ${googleUser.email}');
      print('Google User Name: ${googleUser.displayName}');
      print('Google User ID: ${googleUser.id}');

      // 2. Dapatkan token autentikasi dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Jika token autentikasi tidak tersedia
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan token autentikasi')),
        );
        return;
      }

      // Log Access Token dan ID Token
      print('Access Token: ${googleAuth.accessToken}');
      print('ID Token: ${googleAuth.idToken}');

      // 3. Firebase Authentication menggunakan token Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Jika Firebase gagal mengautentikasi pengguna
      if (user == null) {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal mendapatkan data pengguna Google')),
        );
        return;
      }

      // Log informasi pengguna dari Firebase
      print('Firebase User Email: ${user.email}');
      print('Firebase User Name: ${user.displayName}');
      print('Firebase User Photo: ${user.photoURL}');

      // 4. Pastikan data fullname dan profile_picture tidak null
      final fullname = user.displayName ?? "Pengguna Google";
      final profilePicture = user.photoURL ?? "";

      // 5. Panggil API Flask
      final response = await http
          .post(
            Uri.parse('${widget.baseUrl}/api/google-login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': user.email,
              'fullname': fullname,
              'profile_picture': profilePicture,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // 6. Cek status kode dari respons API
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Parsing JSON respons

        // Log respons dan tipe data
        print('Respons dari server: ${response.body}');
        print('Tipe data respons: ${data.runtimeType}');

        // 7. Cek tipe data user
        if (data is Map<String, dynamic>) {
          final userData = data['user'];

          // Log tipe data userData
          print('Tipe data userData: ${userData.runtimeType}');

          // Validasi tipe data userData
          if (userData is Map<String, dynamic>) {
            print('User Data: $userData');

            // 8. Navigasi berdasarkan kondisi nickname
            if (userData['nickname'] == null || userData['nickname'].isEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SetNicknameScreen(
                    userData: userData, // Kirim seluruh userData
                    email: userData['email'] ?? '',
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    userData: userData, // Kirim seluruh userData
                  ),
                ),
              );
            }
          } else {
            throw "Unexpected user data format: ${userData.runtimeType}";
          }
        } else {
          throw "Unexpected response format: ${data.runtimeType}";
        }
      } else {
        // Jika status kode bukan 200
        print('Gagal menyimpan data, respons dari server: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: ${response.body}')),
        );
      }
    } catch (e) {
      // Tangani error yang terjadi
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal login dengan Google: $e')),
      );
    } finally {
      // Menyembunyikan indikator loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Selamat Datang Kembali!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Masukkan informasi akun Anda untuk lanjut',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Alamat Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lupa Sandi?',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Atau masuk dengan'),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _buildSocialIconButton(
                            'assets/img/google_logo.png',
                            _loginWithGoogle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ', // Teks biasa, tidak bisa ditekan
                            style: TextStyle(
                              color: Colors.black, // Warna teks
                            ),
                          ),
                          TextButton(
                            onPressed:
                                _navigateToRegister, // Fungsi untuk navigasi ke halaman pendaftaran
                            child: const Text(
                              'Daftar di sini!', // Teks tombol yang bisa ditekan
                              style: TextStyle(
                                color: Colors.red, // Warna teks tombol
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIconButton(String imagePath, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(
          imagePath,
          height: 40.0,
          width: 40.0,
        ),
      ),
    );
  }
}
