import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Login.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'mocks.mocks.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  group('Unit Testing - LoginScreen', () {
    late MockClient mockClient;
    const baseUrl = 'https://example.com';

    setUp(() {
      mockClient = MockClient();
    });

    testWidgets('Login API call returns success', (WidgetTester tester) async {
      // Arrange: Stub respons sukses
      final testUri = Uri.parse('$baseUrl/api/login');

      when(mockClient.post(
        testUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
          jsonEncode({
            'user': {'user_id': '1', 'email': 'test@example.com'}
          }),
          200));

      // Render LoginScreen
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(baseUrl: baseUrl, client: mockClient),
      ));

      // Masukkan email dan password
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');

      // Tekan tombol login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Mulai login proses

      // Tunggu animasi, Timer, dan Future.delayed selesai
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi bahwa mockClient.post dipanggil
      verify(mockClient.post(
        testUri,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'test@example.com', 'password': 'password123'}),
      )).called(1);
    });

    testWidgets('Login API call returns error', (WidgetTester tester) async {
      // Arrange: Stub respons error
      final testUri = Uri.parse('$baseUrl/api/login');

      when(mockClient.post(
        testUri,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Unauthorized', 401));

      // Render LoginScreen
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(baseUrl: baseUrl, client: mockClient),
      ));

      // Masukkan email dan password
      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

      // Tekan tombol login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Mulai login proses

      // Tunggu animasi, Timer, dan Future.delayed selesai
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifikasi bahwa mockClient.post dipanggil
      verify(mockClient.post(
        testUri,
        headers: anyNamed('headers'),
        body: jsonEncode({'email': 'test@example.com', 'password': 'wrongpassword'}),
      )).called(1);
    });
  });
}
