import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/SentimentPage.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

// Mock class untuk http.Client
class MockClient extends Mock implements http.Client {}

// Mock class untuk BaseUrlProvider
class MockBaseUrlProvider extends Mock implements BaseUrlProvider {}

void main() {
  group('analyzeSentiment', () {
    testWidgets('returns message if the server responds with status 200', (WidgetTester tester) async {
      final client = MockClient();
      final baseUrl = 'http://example.com';
      final text = 'Saya suka aplikasi ini!';
      final responseJson = json.encode({'message': 'Terima kasih!'});

      // Mengatur mocking untuk client.post
      when(client.post(
        Uri.parse('$baseUrl/api/analyze_sentiment'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseJson, 200));  // Memastikan return Future<http.Response>

      // Mock BaseUrlProvider
      final baseUrlProvider = MockBaseUrlProvider();
      when(baseUrlProvider.baseUrl).thenReturn(baseUrl);

      // Membuat widget test dengan provider
      final widget = Provider<BaseUrlProvider>.value(
        value: baseUrlProvider,
        child: Builder(
          builder: (BuildContext context) {
            return FutureBuilder<String>(
              future: analyzeSentiment(text, context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text(snapshot.data ?? 'No Data');
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          },
        ),
      );

      // Memulai pengujian widget
      await tester.pumpWidget(widget);

      // Memastikan hasilnya sesuai dengan respons yang diharapkan
      expect(find.text('Terima kasih!'), findsOneWidget);
    });

    testWidgets('throws an exception if the server responds with error', (WidgetTester tester) async {
      final client = MockClient();
      final baseUrl = 'http://example.com';
      final text = 'Saya suka aplikasi ini!';

      // Mengatur mocking untuk client.post
      when(client.post(
        Uri.parse('$baseUrl/api/analyze_sentiment'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Not Found', 404)); // Memastikan return response error

      // Mock BaseUrlProvider
      final baseUrlProvider = MockBaseUrlProvider();
      when(baseUrlProvider.baseUrl).thenReturn(baseUrl);

      // Membuat widget test dengan provider
      final widget = Provider<BaseUrlProvider>.value(
        value: baseUrlProvider,
        child: Builder(
          builder: (BuildContext context) {
            return FutureBuilder<String>(
              future: analyzeSentiment(text, context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error');
                  } else {
                    return Text(snapshot.data ?? 'No Data');
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          },
        ),
      );

      // Memulai pengujian widget
      await tester.pumpWidget(widget);

      // Memastikan exception dilempar jika status code 404
      expect(find.text('Error'), findsOneWidget);
    });
  });
}
