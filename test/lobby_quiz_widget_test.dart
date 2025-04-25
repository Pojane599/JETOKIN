import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Quiz/LobbyQuiz.dart';

void main() {
  testWidgets('QuizWelcomeScreen displays UI correctly', (WidgetTester tester) async {
    // Mock user data
    final mockUserData = {'name': 'John Doe', 'email': 'john.doe@example.com'};

    // Build the QuizWelcomeScreen widget
    await tester.pumpWidget(MaterialApp(
      home: QuizWelcomeScreen(userData: mockUserData),
    ));

    // Check if the main title is present
    expect(find.text('Selamat Datang di Kuis Seru!'), findsOneWidget);

    // Check if the sub-title is present
    expect(find.text('Jelajahi pertanyaan menantang\n dan raih skor tertinggi!'), findsOneWidget);

    // Verify buttons are present
    expect(find.text('Mulai Kuis'), findsOneWidget);
    expect(find.text('Aturan Main'), findsOneWidget);

    // Test help dialog interaction
    await tester.tap(find.text('Aturan Main'));
    await tester.pumpAndSettle();

    // Verify the dialog appears
    expect(find.text('Aturan Main'), findsNWidgets(2)); // From button and dialog
    expect(find.text('1. Anda akan diberi waktu 1 menit untuk setiap sesi kuis.'), findsOneWidget);
  });
}
