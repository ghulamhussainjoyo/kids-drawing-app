import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';

/// `PressButton` is what every tappable thing in the app is made of, and it
/// has to work with no [AppSound] above it — which is how it is built here.
void main() {
  testWidgets('a tap calls back, and no provider is not an error', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      CupertinoApp(
        home: PressButton(
          onPressed: () => taps++,
          child: const SizedBox(width: 80, height: 40),
        ),
      ),
    );

    await tester.tap(find.byType(PressButton));
    await tester.pumpAndSettle();

    expect(taps, 1);
  });

  testWidgets('a button with no handler does nothing', (tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: PressButton(child: SizedBox(width: 80, height: 40)),
      ),
    );

    await tester.tap(find.byType(PressButton));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
