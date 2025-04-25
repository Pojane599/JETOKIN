import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'mocks.mocks.dart'; // Impor file yang dihasilkan

void main() {
  group('SetNicknameScreen - Unit Tests', () {
    late MockClient mockClient;
    const baseUrl = 'http://192.168.95.117:5012';

    setUp(() {
      mockClient = MockClient();
    });

    test('Check Nickname Availability - Nickname available', () async {
      // Arrange: Stub respons sukses
      final testUri = Uri.parse('$baseUrl/api/check_nickname');

      when(mockClient.post(
        testUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'status': 'available'}), 200));

      // Act: Panggil fungsi yang ingin diuji
      final response = await mockClient.post(
        testUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': 'nickname123'}),
      );

      // Assert: Periksa hasilnya
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['status'], 'available');
    });

    test('Check Nickname Availability - Nickname taken', () async {
      // Arrange: Stub respons "taken"
      final testUri = Uri.parse('$baseUrl/api/check_nickname');

      when(mockClient.post(
        testUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({'status': 'taken'}), 200));

      // Act: Panggil fungsi yang ingin diuji
      final response = await mockClient.post(
        testUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nickname': 'nickname123'}),
      );

      // Assert: Periksa hasilnya
      expect(response.statusCode, 200);
      expect(jsonDecode(response.body)['status'], 'taken');
    });
  });
}
