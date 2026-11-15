import 'dart:ui';

import 'brush.config.dart';

/// One finger-down-to-lift stroke. Points are in artwork coordinates.
class DrawingStroke {
  /// Stroke painted with clip-to-region off; clipped to the full page only.
  static const String freeRegionId = 'free';

  DrawingStroke({
    required this.id,
    required this.regionId,
    required this.brush,
    required this.seed,
    List<Offset>? points,
  }) : points = points ?? <Offset>[];

  final int id;

  /// Region from first touch, or [freeRegionId] when clip mode is off.
  final String regionId;
  final BrushConfig brush;

  /// Drives per-stroke texture variation so replays render identically.
  final int seed;
  final List<Offset> points;
}
