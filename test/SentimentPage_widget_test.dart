import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/SentimentPage.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('SentimentPage Widget Test', (WidgetTester tester) async {
    // Menyediakan BaseUrlProvider
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (context) => BaseUrlProvider(),
          child: SentimentPage(),
        ),
      ),
    );

    // Memastikan widget SentimentPage dimuat dengan benar
    expect(find.text('Berikan Komentar'), findsOneWidget);
    expect(find.text('Ketik komentar Anda di sini...'), findsOneWidget);

    // Memasukkan teks dan mengklik tombol kirim
    await tester.enterText(find.byType(TextField), 'Saya suka aplikasi ini!');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verifikasi SnackBar ditampilkan
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
