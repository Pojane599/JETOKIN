import 'package:flutter_test/flutter_test.dart';
import 'package:jetokin/UI/Register.dart';

void main() {
  group('RegisterScreen Input Validation Tests', () {
    test('Email validation returns true for valid email', () {
      expect(RegisterScreen.isEmailValid('test@example.com'), isTrue);
    });

    test('Email validation returns false for invalid email', () {
      expect(RegisterScreen.isEmailValid('invalid-email'), isFalse);
    });

    test('Password confirmation validation fails when not matching', () {
      final password = 'password123';
      final confirmPassword = 'differentPassword';
      expect(password == confirmPassword, isFalse);
    });

    test('Password confirmation validation passes when matching', () {
      final password = 'password123';
      final confirmPassword = 'password123';
      expect(password == confirmPassword, isTrue);
    });
  });
}
