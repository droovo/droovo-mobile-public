// Smoke test: proves the (screen-less) demo app boots and renders the
// sample helper output. All real coverage lives in the other test files,
// one per helper in lib/helpers/.

import 'package:flutter_test/flutter_test.dart';

import 'package:droovo_mobile_public/main_public.dart';

void main() {
  testWidgets('DroovoPublicHelpersApp boots and shows sample helper output',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DroovoPublicHelpersApp());

    expect(find.textContaining('no product screens'), findsOneWidget);
    expect(find.textContaining('Tunis → Sfax distance'), findsOneWidget);
    expect(find.textContaining('suggested price/seat'), findsOneWidget);
  });
}
