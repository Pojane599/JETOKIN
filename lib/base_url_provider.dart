import 'package:flutter/material.dart';

class BaseUrlProvider with ChangeNotifier {
  String _baseUrl = "https://bb5c-140-213-163-210.ngrok-free.app"; // Localhost

  String get baseUrl => _baseUrl;

  set baseUrl(String newBaseUrl) {
    if (_baseUrl != newBaseUrl) {
      // Tambahkan pengecekan jika nilai baseUrl berubah
      _baseUrl = newBaseUrl;
      notifyListeners();
    }
  }
}
