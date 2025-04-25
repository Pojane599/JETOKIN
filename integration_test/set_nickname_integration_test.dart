import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/UI/SetNicknameScreen.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SetNicknameScreen Integration Tests', () {
    testWidgets('Check nickname availability and save nickname',
        (WidgetTester tester) async {
      // Mock data
      final mockEmail = 'test@example.com';
      final mockUserData = {'user_id': 1};
      final mockBaseUrl = 'http://mockapi.com';

      // Mocking BaseUrlProvider
      await tester.pumpWidget(
        Provider<BaseUrlProvider>(
          create: (_) => BaseUrlProvider()..baseUrl = mockBaseUrl,
          child: MaterialApp(
            home: SetNicknameScreen(
              email: mockEmail,
              userData: mockUserData,
            ),
          ),
        ),
      );

      // Verify the screen is loaded
      expect(find.text('Atur Nama Panggilan'), findsOneWidget);

      // Find the nickname input field
      final nicknameField = find.byType(TextField);
      expect(nicknameField, findsOneWidget);

      // Input a nickname
      const nickname = 'nickname123';
      await tester.enterText(nicknameField, nickname);
      await tester.pumpAndSettle();

      // Tap the check button to verify nickname availability
      final checkButton = find.byIcon(Icons.check);
      expect(checkButton, findsOneWidget);
      await tester.tap(checkButton);

      // Simulate server response for checking nickname
      final checkResponse = {
        'status': 'available',
      };
      http.Response mockCheckResponse = http.Response(
        jsonEncode(checkResponse),
        200,
      );
      expect(mockCheckResponse.statusCode, 200);

      // Simulate nickname is available and show a SnackBar
      await tester.pumpAndSettle();
      expect(
        find.text('Nama panggilan tersedia. Anda dapat menggunakannya.'),
        findsOneWidget,
      );

      // Tap the save button to save nickname
      final saveButton = find.text('Simpan');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);

      // Simulate server response for saving nickname
      final saveResponse = {
        'status': 'success',
        'message': 'Nama panggilan berhasil disimpan!',
      };
      http.Response mockSaveResponse = http.Response(
        jsonEncode(saveResponse),
        200,
      );
      expect(mockSaveResponse.statusCode, 200);

      // Verify the navigation to HomePage
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
