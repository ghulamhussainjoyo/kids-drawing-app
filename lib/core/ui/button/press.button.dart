import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:provider/provider.dart';

/// The press behaviour every tappable thing in the app shares: one sound per
/// press, the little buzz, and the hold timing that keeps a quick tap from
/// flashing by.
///
/// Give it a [child] when the look does not change while it is held, or a
/// [builder] when it does.
class PressButton extends StatefulWidget {
  final Widget Function(BuildContext context, bool pressed)? builder;
  final Widget? child;
  final VoidCallback? onPressed;

  /// [PressSound.exit] for anything that leaves a screen.
  final PressSound sound;

  const PressButton({
    super.key,
    this.builder,
    this.child,
    this.onPressed,
    this.sound = PressSound.enter,
  }) : assert(
         builder != null || child != null,
         'PressButton needs a builder or a child',
       );

  /// How long a button takes to sink and rise again.
  static const pressDuration = Duration(milliseconds: 70);

  @override
  State<PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<PressButton> {
  /// Shortest time a press is shown for, so a fast tap is still visible.
  static const _minHold = Duration(milliseconds: 90);

  bool _pressed = false;
  DateTime? _pressedAt;
  Timer? _releaseTimer;

  bool get _enabled => widget.onPressed != null;

  /// Only the look. The sound waits for [_tap], because a finger that is
  /// starting a scroll also presses down, and that must stay silent.
  void _press() {
    if (!_enabled) {
      return;
    }
    _releaseTimer?.cancel();
    _pressedAt = DateTime.now();
    setState(() => _pressed = true);
  }

  void _release() {
    if (!_pressed) {
      return;
    }
    final held = DateTime.now().difference(_pressedAt ?? DateTime.now());
    final wait = held >= _minHold ? Duration.zero : _minHold - held;
    _releaseTimer?.cancel();
    _releaseTimer = Timer(wait, () {
      if (mounted) {
        setState(() => _pressed = false);
      }
    });
  }

  void _tap() {
    if (!_enabled) {
      return;
    }
    _playPressSound();
    widget.onPressed?.call();
  }

  void _playPressSound() {
    final sound = _sound();
    if (sound == null) {
      return;
    }
    if (widget.sound == PressSound.exit) {
      sound.pressOut();
      return;
    }
    sound.pressIn();
  }

  /// Null in a widget test that builds a button on its own.
  AppSound? _sound() {
    try {
      return context.read<AppSound>();
    } catch (_) {
      return null;
    }
  }

  Widget _look(BuildContext context) {
    final builder = widget.builder;
    if (builder != null) {
      return builder(context, _pressed);
    }
    return widget.child!;
  }

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: _tap,
      child: _look(context),
    );
  }
}
