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
    final lip = diameter * 0.06;
    final faceHeight = diameter - lip;
    final graphicSize = getGraphicSize(diameter);
    final lipColor = Color.lerp(widget.color, const Color(0xFF000000), 0.25)!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: widget.onPressed,
      child: SizedBox(
        width: diameter,
        height: diameter, // ab square, pehle diameter + lip tha
        child: Stack(
          children: [
            // Neeche wala dark base: poora circle
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: lipColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Upar wali face: full width, height diameter - lip
            AnimatedPositioned(
              duration: _pressDuration,
              curve: Curves.easeOut,
              left: 0,
              right: 0,
              top: _pressed ? lip : 0,
              height: faceHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.all(
                    Radius.elliptical(diameter / 2, faceHeight / 2),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: graphicSize,
                    height: graphicSize,
                    child: FittedBox(fit: BoxFit.contain, child: widget.image),
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
