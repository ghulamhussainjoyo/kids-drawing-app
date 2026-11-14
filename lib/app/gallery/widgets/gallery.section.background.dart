import 'package:flutter/cupertino.dart';

/// Picks the gallery backdrop from scroll center across genre sections.
class GallerySectionBackground {
  final List<String> sectionIds;
  final Map<String, Color> colors;
  final double Function(String sectionId) sectionWidth;

  const GallerySectionBackground({
    required this.sectionIds,
    required this.colors,
    required this.sectionWidth,
  });

  Color colorAt({
    required double scrollOffset,
    required double screenWidth,
  }) {
    if (sectionIds.isEmpty) {
      return const Color(0xFF7EC8E3);
    }

    var x = scrollOffset + screenWidth / 2;
    var index = 0;
    while (index < sectionIds.length - 1) {
      final width = sectionWidth(sectionIds[index]);
      if (x < width) {
        break;
      }
      x = x - width;
      index = index + 1;
    }

    final sectionId = sectionIds[index];
    final color = colors[sectionId] ?? const Color(0xFF7EC8E3);
    if (index == sectionIds.length - 1) {
      return color;
    }

    final width = sectionWidth(sectionId);
    var fadeStart = width - screenWidth;
    if (fadeStart < 0) {
      fadeStart = 0;
    }
    if (x < fadeStart) {
      return color;
    }

    final fadeLength = width - fadeStart;
    final blend = ((x - fadeStart) / fadeLength).clamp(0.0, 1.0);
    final nextId = sectionIds[index + 1];
    final nextColor = colors[nextId] ?? const Color(0xFF7EC8E3);
    return Color.lerp(color, nextColor, blend)!;
  }
}
