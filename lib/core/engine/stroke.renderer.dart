import 'dart:ui';

import '../tools/drawing.tool.dart';
import 'stroke.dabber.dart';

/// Draws strokes in artwork coordinates, clipped to their region.
class StrokeRenderer {
  void paint(Canvas canvas, StrokeDabber dabber, Path clip, DrawingTool tool) {
    canvas.save();
    canvas.clipPath(clip);
    tool.paint(canvas, dabber);
    canvas.restore();
  }
}
