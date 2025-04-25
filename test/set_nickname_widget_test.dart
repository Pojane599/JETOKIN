import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/SetNicknameScreen.dart';

void main() {
  testWidgets('SetNicknameScreen displays and interacts correctly',
      (WidgetTester tester) async {
    // Persiapkan data user untuk pengujian
    final Map<String, dynamic> userData = {'user_id': 123};

    await tester.pumpWidget(
      MaterialApp(
        home: SetNicknameScreen(
          email: 'test@example.com',
          userData: userData, // Pastikan userData tidak null
        ),
      ),
    );

    // Verifikasi widget utama tampil
    expect(find.text('Atur Nama Panggilan'), findsOneWidget);  // Perbaiki judul
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);  // Perbaiki teks tombol

    // Input nickname
    await tester.enterText(find.byType(TextField), 'nickname123');
    expect(find.text('nickname123'), findsOneWidget);

    // Tekan tombol cek nickname
    await tester.tap(find.byIcon(Icons.check));
    await tester.pump(); // Perbarui UI setelah tombol ditekan

    // Tekan tombol Simpan
    await tester.tap(find.text('Simpan'));
    await tester.pump(); // Perbarui UI setelah tombol ditekan

    // Tambahkan pemeriksaan lain yang mungkin diperlukan, seperti SnackBar
  });
}
