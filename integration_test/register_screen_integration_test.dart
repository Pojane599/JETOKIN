import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jetokin/UI/Register.dart';
import 'package:jetokin/UI/SetNicknameScreen.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Integration Test - RegisterScreen to SetNicknameScreen',
      (WidgetTester tester) async {
    const testBaseUrl = 'http://192.168.95.117:5012';

    // Render RegisterScreen dengan Provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BaseUrlProvider()..baseUrl,
        child: const MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle(); // Tunggu rendering selesai

    // Input data registrasi
    await tester.enterText(find.byType(TextField).at(0), 'John Doe'); // Nama Lengkap
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com'); // Email
    await tester.enterText(find.byType(TextField).at(2), 'password123'); // Password
    await tester.enterText(find.byType(TextField).at(3), 'password123'); // Konfirmasi Password

    // Interaksi DropdownButtonFormField
    await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Pilih Jenis Kelamin'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laki-laki').last);
    await tester.pumpAndSettle();

    // Checklist syarat dan ketentuan
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Tekan tombol Daftar
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verifikasi navigasi ke SetNicknameScreen
    expect(find.byType(SetNicknameScreen), findsOneWidget);
  });
}
