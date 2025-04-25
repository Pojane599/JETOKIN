import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Login.dart';

void main() {
  testWidgets('Widget Testing - LoginScreen UI', (WidgetTester tester) async {
    const testBaseUrl = 'http://192.168.1.14:5012';

    // Render LoginScreen
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(baseUrl: testBaseUrl),
      ),
    );

    // Verifikasi elemen UI utama
    expect(find.text('Selamat Datang Kembali!'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // Input email dan password
    await tester.enterText(find.byType(TextField).at(0), 'uchiha@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'qwertyuio');

    // Tekan tombol login
    await tester.tap(find.text('Masuk'));
    await tester.pump();
  });
}
