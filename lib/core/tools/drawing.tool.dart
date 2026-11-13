import 'dart:ui';

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../engine/stroke.dabber.dart';

abstract class DrawingTool {
  BrushType get type;

  StrokeDabber createDabber(DrawingStroke stroke);

  void paint(Canvas canvas, StrokeDabber dabber);

  void dispose() {}

  StrokeDabber replay(DrawingStroke stroke) {
    final dabber = createDabber(stroke);
    for (final point in stroke.points) {
      dabber.addPoint(point);
    }
    return dabber..finish();
  }
}
