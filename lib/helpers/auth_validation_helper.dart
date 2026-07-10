/// Regex-based auth validation rules ported from `AuthConstants` /
/// `AuthHelper` in the private app.
class AuthValidationHelper {
  AuthValidationHelper._();

  static final RegExp _passwordMinLengthRegex = RegExp(r'.{6,}');
  static final RegExp _passwordUppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _passwordDigitRegex = RegExp(r'[0-9]');
  static final RegExp _passwordSpecialCharRegex =
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-=+~`]');

  static final RegExp _emailRegex = RegExp(
    r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@'
    r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|'
    r'(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  /// Score in `{0.0, 0.25, 0.5, 0.75, 1.0}`: one quarter for each of
  /// length (≥6), an uppercase letter, a digit, and a special character.
  static double calculatePasswordStrength(String password) {
    if (password.trim().isEmpty) return 0;

    double strength = 0;
    if (_passwordMinLengthRegex.hasMatch(password)) strength += 0.25;
    if (_passwordUppercaseRegex.hasMatch(password)) strength += 0.25;
    if (_passwordDigitRegex.hasMatch(password)) strength += 0.25;
    if (_passwordSpecialCharRegex.hasMatch(password)) strength += 0.25;

    return strength.clamp(0, 1);
  }

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  /// Best-effort display name derived from an email's local part, e.g.
  /// "jane.doe@x.com" → "jane.doe".
  static String extractNameFromEmail(String? email) {
    if (email == null || email.isEmpty || !email.contains('@')) {
      return 'Anonymous';
    }
    final name = email.split('@').first;
    return name.isNotEmpty ? name : 'Anonymous';
  }
}
