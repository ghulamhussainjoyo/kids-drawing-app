import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class CircleButton extends StatefulWidget {
  /// Design size (jaise 48). Andar se device ke hisab se scale hota hai.
  final double size;
  final Widget image;
  final Color color;
  final double? imageSize;
  final VoidCallback? onPressed;

  /// Parent pehle hi scaled size de raha ho to false kar do.
  final bool responsive;

  const CircleButton({
    super.key,
    required this.image,
    this.onPressed,
    this.size = 48,
    this.imageSize,
    this.responsive = true,
    this.color = const Color(0xFFC5C5C5),
  });

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  bool _pressed = false;
  DateTime? _pressedAt;
  Timer? _releaseTimer;
  bool get _enabled => widget.onPressed != null;
  static const _pressDuration = Duration(milliseconds: 70);
  static const _minHold = Duration(milliseconds: 90);

  void _press() {
    if (!_enabled) return;
    _releaseTimer?.cancel();
    _pressedAt = DateTime.now();
    setState(() => _pressed = true);
    HapticFeedback.selectionClick();
  }

  void _release() {
    if (!_pressed) return;
    final held = DateTime.now().difference(_pressedAt ?? DateTime.now());
    final wait = held >= _minHold ? Duration.zero : _minHold - held;
    _releaseTimer?.cancel();
    _releaseTimer = Timer(wait, () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  double getGraphicSize(double diameter) {
    double graphicSize;
    if (widget.imageSize == null) {
      graphicSize = diameter * 0.5;
    } else if (widget.responsive) {
      graphicSize = context.rs(widget.imageSize!);
    } else {
      graphicSize = widget.imageSize!;
    }
    return graphicSize;
  }

  @override
  void dispose() {
    _releaseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = widget.responsive ? context.rs(widget.size) : widget.size;
    final lip = diameter * 0.08;
    final graphicSize = getGraphicSize(diameter);
    final radius = BorderRadius.circular(diameter / 2);
    final lipColor = Color.lerp(widget.color, const Color(0xFF000000), 0.25)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: widget.onPressed,
      child: SizedBox(
        width: diameter,
        height: diameter + lip,
        child: Stack(
          children: [
            // Neeche wali dark circle (fixed)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: diameter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: lipColor,
                  borderRadius: radius,
                ),
              ),
            ),
            // Upar wali circle: press pe lip jitna neeche
            AnimatedPositioned(
              duration: _pressDuration,
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _pressed ? lip : 0,
              height: diameter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: radius,
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Center(
                    child: SizedBox(
                      width: graphicSize,
                      height: graphicSize,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: widget.image,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
