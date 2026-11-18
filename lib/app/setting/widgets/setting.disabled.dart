import 'package:flutter/cupertino.dart';

/// Fade + block taps while disabled.
class SettingDisabled extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const SettingDisabled({
    super.key,
    required this.disabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: disabled ? 0.45 : 1,
        child: child,
      ),
    );
  }
}
