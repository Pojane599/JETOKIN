import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Quiz/Homequiz.dart';
import 'package:jetokin/UI/Quiz/LobbyQuiz.dart';

void main() {
  testWidgets('Navigation from Homequiz to QuizWelcomeScreen', (WidgetTester tester) async {
    // Mock user data
    final mockUserData = {'nickname': 'John Doe', 'email': 'john.doe@example.com'};

    // Build the MaterialApp with Homequiz as the initial screen
    await tester.pumpWidget(MaterialApp(
      home: Homequiz(userData: mockUserData),
    ));

    // Verify that the button or trigger for navigation is present
    expect(find.text('Mau Main Quiz?'), findsOneWidget);

    // Simulate a tap on the navigation trigger
    await tester.tap(find.text('Mau Main Quiz?'));

    // Allow navigation animation to complete
    await tester.pumpAndSettle();

    // Verify that the navigation successfully pushed QuizWelcomeScreen
    expect(find.byType(QuizWelcomeScreen), findsOneWidget);
  });
}
