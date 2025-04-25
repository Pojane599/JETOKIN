import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Register.dart';

void main() {
  testWidgets('RegisterScreen displays and validates input fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RegisterScreen(),
    ));

    // Verifikasi tampilan UI
    expect(find.text('Buat Akun!'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));

    // Tunggu rendering widget sepenuhnya
    await tester.pumpAndSettle();

    // Masukkan input ke TextField
    await tester.enterText(find.byType(TextField).at(0), 'John Doe');
    await tester.enterText(find.byType(TextField).at(1), 'john@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'password123');
    await tester.enterText(find.byType(TextField).at(3), 'password123');

    // Pilih jenis kelamin
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Laki-laki').last);
    await tester.pumpAndSettle();

    // Checklist syarat dan ketentuan
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Cari dan klik tombol Daftar
    final registerButton = find.widgetWithText(ElevatedButton, 'Daftar').first;
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Verifikasi jika tombol Daftar dapat diklik dan tidak error
    expect(find.text('Buat Akun!'), findsOneWidget);
  });
}
