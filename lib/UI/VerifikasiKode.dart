import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jetokin/UI/AturKataSandiBaru.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/base_url_provider.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  VerificationScreen({super.key, required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isLoading = false;

  /// Fungsi untuk masking email (privasi)
  String maskEmail(String email) {
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];
    final maskedLocal = local.length > 3
        ? '${local.substring(0, 1)}***${local.substring(local.length - 1)}'
        : '***';
    return '$maskedLocal@$domain';
  }

  Future<void> _verifyCode(BuildContext context, String code) async {
    if (code.isEmpty || code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode verifikasi 6 digit')),
      );
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada koneksi internet')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl =
          Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/verify_reset_code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'code': code}),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: widget.email,
              code: code,
            ),
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Kode verifikasi salah')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memverifikasi kode: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendCode(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada koneksi internet')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl =
          Provider.of<BaseUrlProvider>(context, listen: false).baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/send_reset_code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kode verifikasi telah dikirim ulang')),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error['message'] ?? 'Gagal mengirim ulang kode')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ulang kode: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.email.isEmpty) {
      return Scaffold(
        body: Center(
          child: const Text(
            'Kesalahan: Email tidak tersedia.',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

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
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Masukkan Kode Verifikasi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Kami telah mengirimkan 6 digit kode verifikasi ke email ${maskEmail(widget.email)}. Silakan masukkan kode di bawah.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 30),
                      OtpTextField(
                        numberOfFields: 6,
                        borderColor: const Color(0xFF512DA8),
                        showFieldAsBox: true,
                        onSubmit: (String code) {
                          _verifyCode(context, code);
                        },
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () {
                          _resendCode(context);
                        },
                        child: const Text(
                          'Belum dapat emailnya? Kirim ulang email',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Ubah Email',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
