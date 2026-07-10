import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/auth_validation_helper.dart';

void main() {
  group('AuthValidationHelper.calculatePasswordStrength', () {
    test('an empty password has zero strength', () {
      expect(AuthValidationHelper.calculatePasswordStrength(''), equals(0));
      expect(AuthValidationHelper.calculatePasswordStrength('   '), equals(0));
    });

    test('a password meeting all 4 rules scores 1.0', () {
      expect(
        AuthValidationHelper.calculatePasswordStrength('Passw0rd!'),
        equals(1.0),
      );
    });

    test('each missing rule costs exactly 0.25', () {
      // Long enough + digit + special char, but no uppercase -> 0.75
      expect(
        AuthValidationHelper.calculatePasswordStrength('passw0rd!'),
        equals(0.75),
      );
      // Only long enough -> 0.25
      expect(
        AuthValidationHelper.calculatePasswordStrength('lowercase'),
        equals(0.25),
      );
    });

    test('short passwords cannot reach full strength', () {
      expect(
        AuthValidationHelper.calculatePasswordStrength('A1!'),
        lessThan(1.0),
      );
    });
  });

  group('AuthValidationHelper.isValidEmail', () {
    test('accepts well-formed emails', () {
      expect(AuthValidationHelper.isValidEmail('user@example.com'), isTrue);
      expect(
        AuthValidationHelper.isValidEmail('user.name+alias@domain.co'),
        isTrue,
      );
    });

    test('rejects malformed emails', () {
      expect(AuthValidationHelper.isValidEmail('not-an-email'), isFalse);
      expect(AuthValidationHelper.isValidEmail('missing@domain'), isFalse);
      expect(AuthValidationHelper.isValidEmail('@example.com'), isFalse);
    });
  });

  group('AuthValidationHelper.extractNameFromEmail', () {
    test('returns the local part before the @', () {
      expect(
        AuthValidationHelper.extractNameFromEmail('jane.doe@example.com'),
        equals('jane.doe'),
      );
    });

    test('falls back to "Anonymous" for null, empty or malformed input', () {
      expect(
        AuthValidationHelper.extractNameFromEmail(null),
        equals('Anonymous'),
      );
      expect(
        AuthValidationHelper.extractNameFromEmail(''),
        equals('Anonymous'),
      );
      expect(
        AuthValidationHelper.extractNameFromEmail('no-at-sign'),
        equals('Anonymous'),
      );
    });
  });
}
