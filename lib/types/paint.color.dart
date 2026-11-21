import 'dart:ui';

/// The paint a stroke is laid down with.
///
/// One entry in [colors] paints solid. Several entries blend from one to the
/// next along the stroke and loop, so any palette works without extra code.
class PaintColor {
  PaintColor({required this.id, required List<Color> colors})
    : assert(colors.isNotEmpty),
      colors = List.unmodifiable(colors);

  PaintColor.solid({required this.id, required Color color})
    : colors = List.unmodifiable([color]);

  /// Stroke length, in artwork units, to travel from one color to the next.
  static const double distancePerColor = 120;

  final String id;
  final List<Color> colors;

  /// Main color, used where a single swatch is needed.
  Color get color => colors.first;

  bool get isGradient => colors.length > 1;

  /// Color at [distance] along a stroke. [seed] shifts where the palette
  /// starts so neighbouring strokes do not all begin on the same color.
  Color colorAt(double distance, int seed) {
    if (!isGradient) return color;
    final count = colors.length;
    final position = (seed * 0.37 + distance / distancePerColor) % count;
    final index = position.floor();
    final next = (index + 1) % count;
    return Color.lerp(colors[index], colors[next], position - index)!;
  }
}
