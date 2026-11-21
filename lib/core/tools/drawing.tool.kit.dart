import '../../types/brush.type.dart';
import 'drawing.tool.dart';
import 'glitter.drawing.tool.dart';
import 'marker.drawing.tool.dart';
import 'pencil.drawing.tool.dart';

/// Long-lived paint engines for stationary categories.
class DrawingToolKit {
  DrawingToolKit()
      : pencil = PencilTool(),
        marker = MarkerTool(),
        glitter = GlitterTool();

  final PencilTool pencil;
  final MarkerTool marker;
  final GlitterTool glitter;

  DrawingTool forCategory(String name) {
    if (name == 'marker') {
      return marker;
    }
    if (name == 'glitter') {
      return glitter;
    }
    return pencil;
  }

  DrawingTool forType(BrushType type) {
    if (type == BrushType.marker) {
      return marker;
    }
    if (type == BrushType.glitter) {
      return glitter;
    }
    return pencil;
  }

  Future<void> preload() => glitter.ensureLoaded();

  void dispose() {
    pencil.dispose();
    marker.dispose();
    glitter.dispose();
  }
}