import 'dart:ui';

import 'drawing.region.dart';

/// Line art plus its paintable regions, in a square artwork coordinate space.
class ColoringArtwork {
  final String id;
  final double size;
  final double outlineWidth;
  final List<Path> detailLines;
  final List<DrawingRegion> regions;
  double get detailWidth => outlineWidth * 0.7;
  const ColoringArtwork({
    required this.id,
    required this.size,
    required this.regions,
    required this.detailLines,
    required this.outlineWidth,
  });
}
