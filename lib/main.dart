import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/UI/SplashScreen.dart';
import 'package:jetokin/base_url_provider.dart';
import 'package:jetokin/NavBarProvider.dart'; // Import NavBarProvider
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print("Firebase initialized successfully");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BaseUrlProvider()), // Provider untuk Base URL
        ChangeNotifierProvider(create: (_) => NavBarProvider()),  // Provider untuk NavBar
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final http.Client? mockClient; // Tambahkan parameter opsional untuk MockClient

  const MyApp({super.key, this.mockClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jejak Tokoh Indonesia',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(mockClient: mockClient), // Teruskan mockClient ke SplashScreen
    );
  }
}
