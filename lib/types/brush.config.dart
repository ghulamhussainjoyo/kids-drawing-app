import 'brush.type.dart';
import 'paint.color.dart';

/// Snapshot of the brush used for one stroke. Changing the active brush never
/// mutates completed strokes.
class BrushConfig {
  final double size;
  final BrushType type;
  final PaintColor paintColor;

  /// Image asset the stroke paints with: a pattern tile or a sticker.
  final String? texture;

  const BrushConfig({
    required this.type,
    required this.paintColor,
    required this.size,
    this.texture,
  });

  BrushConfig copyWith({
    double? size,
    BrushType? type,
    PaintColor? paintColor,
    String? texture,
  }) {
    return BrushConfig(
      type: type ?? this.type,
      paintColor: paintColor ?? this.paintColor,
      size: size ?? this.size,
      texture: texture ?? this.texture,
    );
  }
}
