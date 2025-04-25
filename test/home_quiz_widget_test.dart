// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/mockito.dart';
// import 'package:jetokin/UI/Quiz/HomeQuiz.dart';
// import 'package:jetokin/base_url_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;

// // Mock untuk HTTP Client
// class MockClient extends Mock implements http.Client {}

// void main() {
//   group('HomeQuiz Widget Test', () {
//     late MockClient mockClient;
//     const testBaseUrl = 'http://192.168.95.117:5012';

//     setUp(() {
//       mockClient = MockClient();
//     });

//     testWidgets('HomeQuiz displays leaderboard and player performance',
//         (WidgetTester tester) async {
//       const testUserData = {
//         'nickname': 'Madara',
//         'user_id': 5,
//       };

//       // Stub untuk leaderboard data
//       when(mockClient.get(
//         captureAny,
//       )).thenAnswer((invocation) async {
//         final Uri uri = invocation.positionalArguments.first;

//         if (uri.toString().contains('/api/leaderboard?week=this-week')) {
//           return http.Response(
//               '{"leaderboard": [{"nickname": "Madara", "score": 990, "ranking": 1, "profile_picture": "default.png"}]}',
//               200);
//         } else if (uri.toString().contains('/api/player-performance/this-week/5')) {
//           return http.Response(
//               '{"total_score": 990, "ranking": 1, "better_than_percentage": 66.67}',
//               200);
//         }
//         return http.Response('Not Found', 404);
//       });

//       // Build widget dengan MockClient
//       await tester.pumpWidget(
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(
//               create: (_) => BaseUrlProvider()..baseUrl = testBaseUrl,
//             ),
//           ],
//           child: MaterialApp(
//             home: Homequiz(userData: testUserData, client: mockClient),
//           ),
//         ),
//       );

//       // Verifikasi loading spinner muncul
//       expect(find.byType(CircularProgressIndicator), findsOneWidget);

//       // Tunggu Future selesai
//       await tester.pumpAndSettle();

//       // Verifikasi teks greeting dan nama pengguna
//       expect(find.textContaining("Selamat"), findsOneWidget);
//       expect(find.text("Madara"), findsOneWidget);

//       // Verifikasi leaderboard muncul
//       expect(find.textContaining("990 poin"), findsOneWidget);

//       // Verifikasi performa pemain
//       expect(find.textContaining("Anda melakukan lebih baik"), findsOneWidget);

//       // Verifikasi panggilan metode GET dua kali
//       verify(mockClient.get(
//         argThat(isA<Uri>().having((u) => u.toString(), 'leaderboard endpoint',
//             contains('/api/leaderboard?week=this-week'))),
//       )).called(1);

//       verify(mockClient.get(
//         argThat(isA<Uri>().having((u) => u.toString(), 'player-performance endpoint',
//             contains('/api/player-performance/this-week/5'))),
//       )).called(1);
//     });
//   });
// }
