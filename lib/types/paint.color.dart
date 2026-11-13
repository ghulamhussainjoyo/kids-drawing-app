import 'dart:ui';

/// A color stick in the rail. [isRainbow] strokes cycle through hues instead
/// of using [color].
class PaintColor {
  final String id;
  final Color color;
  final bool isRainbow;
  const PaintColor({
    required this.id,
    required this.color,
    this.isRainbow = false,
  });
}
