import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jetokin/UI/Home.dart';
import 'package:jetokin/UI/Quiz/HomeQuiz.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/NavBarProvider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test - HomePage navigation works correctly',
      (WidgetTester tester) async {
    const testUserData = {
      'nickname': 'Madara Uchiha',
      'email': 'madara@gmail.com',
    };

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavBarProvider()),
          ChangeNotifierProvider(create: (_) => BaseUrlProvider()..baseUrl),
        ],
        child: MaterialApp(
          home: HomePage(userData: testUserData),
        ),
      ),
    );

    // Verifikasi teks selamat datang tampil
    expect(find.text("Selamat Datang,"), findsOneWidget);
    expect(find.text("Madara"), findsOneWidget);

    // Navigasi ke halaman Quiz
    await tester.tap(find.byIcon(Icons.quiz));
    await tester.pumpAndSettle();

    // Verifikasi halaman Quiz ditampilkan
    expect(find.byType(Homequiz), findsOneWidget);
  });
}
