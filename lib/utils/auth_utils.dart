// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:flutter/services.dart';

// class AuthUtils {
//   static final LocalAuthentication auth = LocalAuthentication();

//   static Future<bool> authenticateWithBiometricsOrPassword({
//     required BuildContext context,
//     required String correctPassword,
//   }) async {
//     try {
//       bool canCheckBiometrics = await auth.canCheckBiometrics;
//       bool isAuthenticated = false;

//       if (canCheckBiometrics) {
//         isAuthenticated = await auth.authenticate(
//           localizedReason: 'Konfirmasi identitas Anda untuk melanjutkan',
//           options: const AuthenticationOptions(
//             biometricOnly: true,
//           ),
//         );
//       }

//       if (isAuthenticated) {
//         return true;
//       } else {
//         return await _showPasswordDialog(
//           context: context,
//           correctPassword: correctPassword,
//         );
//       }
//     } on PlatformException catch (e) {
//       return await _showPasswordDialog(
//         context: context,
//         correctPassword: correctPassword,
//       );
//     }
//   }

//   static Future<bool> _showPasswordDialog({
//     required BuildContext context,
//     required String correctPassword,
//   }) async {
//     TextEditingController passwordController = TextEditingController();
//     bool isPasswordCorrect = false;

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Masukkan Kata Sandi'),
//           content: TextField(
//             obscureText: true,
//             controller: passwordController,
//             decoration: const InputDecoration(
//               labelText: 'Kata Sandi',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Batal'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (passwordController.text == correctPassword) {
//                   isPasswordCorrect = true;
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Kata sandi salah')),
//                   );
//                 }
//               },
//               child: const Text('Konfirmasi'),
//             ),
//           ],
//         );
//       },
//     );

//     return isPasswordCorrect;
//   }
// }
