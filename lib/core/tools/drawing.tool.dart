import 'dart:ui';

import 'package:flutter/rendering.dart' show Matrix4;

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../engine/dab.buffer.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';

abstract class DrawingTool {
  BrushType get type;

  /// Dab shape and spacing this tool stamps along a stroke.
  DabTip get tip;

  /// Whether this tool's paint has an animated [paintShimmer] overlay.
  bool get hasShimmer => false;

  /// Whether one tap paints the whole region under it, whatever the clip
  /// mode (paint bucket).
  bool get fillsRegion => false;

  /// Whether the stroke sits above the outlines on the whole page instead of
  /// inside a region (stickers).
  bool get paintsOverOutlines => false;

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

  StrokeDabber createDabber(DrawingStroke stroke) {
    return StrokeDabber(
      tip: tip,
      width: stroke.brush.size,
      seed: stroke.seed,
      texture: stroke.brush.texture,
      colorAt: (distance) =>
          stroke.brush.paintColor.colorAt(distance, stroke.seed),
    );
  }

  StrokeDabber replay(DrawingStroke stroke) {
    final dabber = createDabber(stroke);
    for (final point in stroke.points) {
      dabber.addPoint(point);
    }
    return dabber..finish();
  }

  /// Stamps every dab of [dabber] (laid-out and tail) from the [tips] atlas,
  /// tinted by each dab's color.
  void stampDabs(Canvas canvas, Image tips, StrokeDabber dabber) {
    final atlasPaint = Paint()..filterQuality = FilterQuality.medium;
    _stampBuffer(canvas, tips, dabber.dabs, atlasPaint);
    _stampBuffer(canvas, tips, dabber.tail, atlasPaint);
  }

  /// Repeating [tile] fixed to the page, moved by [shift] artwork units so
  /// strokes with different seeds do not line up. The tile has
  /// [pixelsPerUnit] image pixels per artwork unit.
  Paint tiledPaint(
    Image tile, {
    required Offset shift,
    required double pixelsPerUnit,
    required FilterQuality quality,
  }) {
    final scale = 1 / pixelsPerUnit;
    final matrix = Matrix4.translationValues(shift.dx, shift.dy, 0)
      ..scaleByDouble(scale, scale, 1, 1);
    return Paint()
      ..shader = ImageShader(
        tile,
        TileMode.repeated,
        TileMode.repeated,
        matrix.storage,
        filterQuality: quality,
      );
  }

  void _stampBuffer(
    Canvas canvas,
    Image tips,
    DabBuffer buffer,
    Paint atlasPaint,
  ) {
    if (buffer.count == 0) return;
    canvas.drawRawAtlas(
      tips,
      buffer.transforms,
      buffer.rects,
      buffer.colors,
      BlendMode.modulate,
      null,
      atlasPaint,
    );
  }
}
