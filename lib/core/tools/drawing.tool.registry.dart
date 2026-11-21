import '../../types/brush.type.dart';
import 'drawing.tool.dart';
import 'glitter.drawing.tool.dart';
import 'pencil.drawing.tool.dart';

/// Owns one renderer per brush and picks the right one for each stroke.
class DrawingToolRegistry {
  final DrawingTool _pencil = PencilTool();
  final GlitterTool glitter = GlitterTool();

  DrawingTool toolFor(BrushType type) {
    return switch (type) {
      BrushType.glitter => glitter,
      _ => _pencil,
    };
  }

  void dispose() {
    _pencil.dispose();
    glitter.dispose();
  }
}
