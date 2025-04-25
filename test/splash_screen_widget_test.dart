import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/SplashScreen.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Widget Testing - SplashScreen UI and button click', (WidgetTester tester) async {
    // Atur ukuran layar untuk pengujian
    await tester.binding.setSurfaceSize(const Size(1080, 1920));

    // Arrange: Render SplashScreen dalam provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BaseUrlProvider(),
        child: const MaterialApp(home: SplashScreen()),
      ),
    );

    // Pastikan UI sudah sepenuhnya dirender
    await tester.pumpAndSettle();

    // Assert: Verifikasi elemen UI
    expect(find.text('Jejak Tokoh Indonesia'), findsOneWidget); // Ubah teks yang diuji
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byKey(const Key('incrementButton')), findsNothing);

    // Act: Klik tombol "Mulai"
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(); // Tunggu hingga navigasi selesai

    // Tambahkan validasi navigasi jika diperlukan di tes berikutnya
  });
}
