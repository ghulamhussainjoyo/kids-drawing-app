import 'dart:ui';

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../engine/stroke.dabber.dart';

abstract class DrawingTool {
  BrushType get type;

  StrokeDabber createDabber(DrawingStroke stroke);

  void paint(Canvas canvas, StrokeDabber dabber);

  /// Animated overlay for this tool's visible paint, such as glitter glints.
  /// [coverage] draws opaque pixels wherever the paint shows; the overlay is
  /// kept only there. Most tools have none.
  void paintShimmer(
    Canvas canvas, {
    required Rect bounds,
    required double seconds,
    required void Function(Canvas canvas) coverage,
  }) {}

  void dispose() {}

  StrokeDabber replay(DrawingStroke stroke) {
    final dabber = createDabber(stroke);
    for (final point in stroke.points) {
      dabber.addPoint(point);
    }
    return dabber..finish();
  }
}
