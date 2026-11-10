import 'brush.type.dart';
import 'paint.color.dart';

/// Snapshot of the brush used for one stroke. Changing the active brush never
/// mutates completed strokes.
class BrushConfig {
  const BrushConfig({
    required this.type,
    required this.paintColor,
    required this.size,
  });

  final BrushType type;
  final PaintColor paintColor;

  /// Stroke width in artwork units.
  final double size;

  BrushConfig copyWith({BrushType? type, PaintColor? paintColor, double? size}) {
    return BrushConfig(
      type: type ?? this.type,
      paintColor: paintColor ?? this.paintColor,
      size: size ?? this.size,
    );
  }
}
