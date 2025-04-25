import 'package:flutter/material.dart';

class NavBarProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  // Menambahkan metode untuk memperbarui currentIndex
  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners(); // Memberi tahu listener bahwa nilai telah berubah
  }
}