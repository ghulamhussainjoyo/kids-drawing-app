import 'dart:ui';

import '../../data/models/brush.type.dart';
import '../../data/models/drawing.stroke.dart';
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
