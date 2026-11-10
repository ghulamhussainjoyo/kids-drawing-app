import 'dart:ui';

import '../../../core/engine/canvas.engine.dart';

/// Snapshot of a two-finger zoom at the moment the pinch started.
class CanvasPinch {
  const CanvasPinch({
    required this.startView,
    required this.anchorArtwork,
    required this.startDistance,
  });

  final CanvasViewTransform startView;
  final Offset anchorArtwork;
  final double startDistance;
}
