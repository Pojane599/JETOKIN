import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Home.dart';
import 'package:jetokin/UI/Quiz/HomeQuiz.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/NavBarProvider.dart';

void main() {
  testWidgets('HomePage displays welcome message and navigates correctly',
      (WidgetTester tester) async {
    const testUserData = {
      'nickname': 'Madara Uchiha',
      'email': 'madara@example.com',
    };

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavBarProvider()),
          ChangeNotifierProvider(
              create: (_) =>
                  BaseUrlProvider()..baseUrl),
        ],
        child: MaterialApp(
          home: HomePage(userData: testUserData),
          routes: {
            '/home': (context) => HomePage(userData: testUserData),
            '/quiz': (context) => const Homequiz(userData: {
                  'nickname': 'Madara Uchiha',
                  'performance': 100, // Nilai default untuk data
                }),
            '/daftar_pahlawan': (context) =>
                Scaffold(body: Text('Daftar Pahlawan')),
            '/profil': (context) => Scaffold(body: Text('Profil')),
          },
        ),
      ),
    );

    // Verifikasi teks selamat datang
    expect(find.text("Selamat Datang,"), findsOneWidget);
    expect(find.text("Madara Uchiha"), findsOneWidget);

    // Verifikasi BottomNavigationBar tampil
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Tekan navigasi ke halaman Quiz (index 1)
    await tester.tap(find.byIcon(Icons.quiz_outlined));
    await tester.pumpAndSettle();

    // // Tes navigasi berhasil (opsional jika halaman Quiz diuji)
    expect(find.textContaining('Mau Main Quiz?'), findsOneWidget);
  });
}
