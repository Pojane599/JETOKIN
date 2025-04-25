import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/SplashScreen.dart';

void main() {
  group('Unit Testing - SplashScreen', () {
    test('SplashScreen should create without errors', () {
      // Tes apakah SplashScreen dapat dibuat tanpa error
      expect(() => const SplashScreen(), returnsNormally);
    });

    test('SplashScreen should accept mock HTTP client', () {
      final mockClient = http.Client();
      expect(() => SplashScreen(mockClient: mockClient), returnsNormally);
    });
  });
}
