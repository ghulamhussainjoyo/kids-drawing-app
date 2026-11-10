import 'dart:ui';

import 'drawing.region.dart';

/// Line art plus its paintable regions, in a square artwork coordinate space.
class ColoringArtwork {
  const ColoringArtwork({
    required this.id,
    required this.size,
    required this.regions,
    required this.detailLines,
    required this.outlineWidth,
  });

  final String id;

  /// Width and height of the artwork coordinate space.
  final double size;

  /// Ordered front to back.
  final List<DrawingRegion> regions;

  /// Decorative open lines (highlights, veins, page lines). Never paintable.
  final List<Path> detailLines;

  final double outlineWidth;

  double get detailWidth => outlineWidth * 0.7;
}
