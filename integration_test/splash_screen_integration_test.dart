import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jetokin/UI/Login.dart';
import 'package:jetokin/UI/SplashScreen.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Testing - SplashScreen to LoginScreen navigation',
      (WidgetTester tester) async {
    // Arrange: Render SplashScreen dengan Provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BaseUrlProvider(),
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    // Assert: SplashScreen tampil
    expect(find.text('Jejak Tokoh Indonesia'), findsOneWidget);

    // Act: Tekan tombol "Mulai"
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Assert: LoginScreen tampil setelah navigasi
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
