import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/parent_gate/screen/ask.grown.up.screen.dart';

/// Global parental gate. Call from any screen that has a [BuildContext].
class ParentGate {
  ParentGate._();

  /// Returns `true` only when the grown-up answers correctly.
  /// Returns `false` when the user closes with X or the route is dismissed.
  static Future<bool> request(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      CupertinoPageRoute<bool>(
        fullscreenDialog: true,
        builder: (context) => const AskGrownUpScreen(),
      ),
    );
    return result == true;
  }
}
