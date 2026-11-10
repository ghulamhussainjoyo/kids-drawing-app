import 'dart:ui';

import 'brush.config.dart';

/// One finger-down-to-lift stroke. Points are in artwork coordinates.
class DrawingStroke {
  DrawingStroke({
    required this.id,
    required this.regionId,
    required this.brush,
    required this.seed,
    List<Offset>? points,
  }) : points = points ?? <Offset>[];

  final int id;

  /// The region resolved from the first touch. Every point is clipped to it.
  final String regionId;
  final BrushConfig brush;

  /// Drives per-stroke texture variation so replays render identically.
  final int seed;
  final List<Offset> points;
}
