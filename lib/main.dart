// Default `flutter run` entry point — forwards to main_public.dart so that
// both `flutter run` and `flutter run -t lib/main_public.dart` behave the
// same way.
import 'main_public.dart' as public_app;

void main() => public_app.main();
