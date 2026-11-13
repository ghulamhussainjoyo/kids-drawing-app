import 'dart:math' as math;
import 'dart:ui';

import '../../types/coloring.artwork.dart';
import '../../types/drawing.region.dart';

/// Resolves which region a stroke belongs to, from its first touch only.
class RegionEngine {
  RegionEngine(this.artwork)
    : _regionsById = {for (final r in artwork.regions) r.id: r},
      _edgeSamples = _sampleEdges(artwork);

  final ColoringArtwork artwork;
  final Map<String, DrawingRegion> _regionsById;
  final List<_EdgeSample> _edgeSamples;

  static const double _sampleSpacing = 2;
  static const int _ringPoints = 12;

  DrawingRegion? regionById(String id) => _regionsById[id];

  /// The region a stroke starting at [point] colors.
  ///
  /// A point inside a region picks the front-most one, even right next to an
  /// outline. Otherwise (on an outline, or on paper beside the art) the
  /// region nearest to [point] within [pickRadius] is picked, so parts
  /// smaller than a fingertip still take color. Null means blank paper.
  /// Detail lines (leaf vein, page lines) sit inside a region and belong to it.
  DrawingRegion? regionAt(Offset point, {double pickRadius = 0}) {
    final inside = _frontMostAt(point);
    if (inside != null || pickRadius <= 0) return inside;

    DrawingRegion? nearest;
    var nearestDistance = double.infinity;

    final reachSquared = pickRadius * pickRadius;
    for (final sample in _edgeSamples) {
      final dSquared = (sample.position - point).distanceSquared;
      if (dSquared <= reachSquared &&
          dSquared < nearestDistance * nearestDistance) {
        nearestDistance = math.sqrt(dSquared);
        nearest = sample.region;
      }
    }

    // Edge samples of a thin part can hide under a neighbor's outline, so
    // also probe rings around the touch for any part the disc overlaps.
    for (final radius in [pickRadius / 2, pickRadius]) {
      if (radius >= nearestDistance) break;
      for (var i = 0; i < _ringPoints; i++) {
        final angle = i * 2 * math.pi / _ringPoints;
        final hit = _frontMostAt(
          point + Offset(math.cos(angle), math.sin(angle)) * radius,
        );
        if (hit != null) {
          nearest = hit;
          nearestDistance = radius;
          break;
        }
      }
    }
    return nearest;
  }

  DrawingRegion? _frontMostAt(Offset point) {
    for (final region in artwork.regions) {
      if (region.path.contains(point)) return region;
    }
    return null;
  }

  static List<_EdgeSample> _sampleEdges(ColoringArtwork artwork) {
    final samples = <_EdgeSample>[];
    for (final region in artwork.regions) {
      for (final metric in region.path.computeMetrics()) {
        for (double d = 0; d <= metric.length; d += _sampleSpacing) {
          final tangent = metric.getTangentForOffset(d);
          if (tangent != null)
            samples.add(_EdgeSample(tangent.position, region));
        }
      }
    }
    return samples;
  }
}

class _EdgeSample {
  const _EdgeSample(this.position, this.region);

  final Offset position;
  final DrawingRegion region;
}
