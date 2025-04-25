import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jetokin/UI/Login.dart';
import 'package:jetokin/UI/Home.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/NavBarProvider.dart';
import 'package:jetokin/base_url_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test - LoginScreen to Home navigation',
      (WidgetTester tester) async {
    const testBaseUrl = 'http://192.168.1.14:5012';

    // Render LoginScreen dengan MultiProvider
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavBarProvider()),
          ChangeNotifierProvider(
              create: (_) => BaseUrlProvider()..baseUrl),
        ],
        child: MaterialApp(
          home: LoginScreen(baseUrl: testBaseUrl),
        ),
      ),
    );

    // Input email dan password
    await tester.enterText(find.byType(TextField).at(0), 'uchiha@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'qwertyuio');

    // Tekan tombol login
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verifikasi bahwa HomePage ditampilkan
    expect(find.byType(HomePage), findsOneWidget);

    // Verifikasi nama di AppBar secara spesifik
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text("Madara"),
      ),
      findsOneWidget,
    );
  });
}
