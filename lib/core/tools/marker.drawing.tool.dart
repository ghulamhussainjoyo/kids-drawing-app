import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'marker.textures.dart';

/// Felt-tip marker: one crisp, even, translucent stroke (about 72%, measured
/// from the reference app). Dabs are opaque inside the stroke's layer, so a
/// stroke never darkens itself; a second stroke on top does.
class MarkerTool extends DrawingTool {
  MarkerTool() : textures = MarkerTextures(softEdge: crispEdge);

  final MarkerTextures textures;

  static const DabTip markerTip = DabTip(
    pixels: MarkerTextures.tipPixels,
    variants: MarkerTextures.tipVariants,
    spacing: 0.06,
    alpha: 1,
    tipScale: 1.15,
    tapDabs: 5,
  );

  /// Opacity of the whole stroke.
  static const double strokeOpacity = 0.72;

  /// Part of the tip radius that fades out: a thin fade keeps edges crisp.
  static const double crispEdge = 0.08;

  @override
  BrushType get type => BrushType.marker;

  @override
  DabTip get tip => markerTip;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    final layer = ui.Paint()
      ..color = const ui.Color(0xFF000000).withValues(alpha: strokeOpacity);
    canvas.saveLayer(dabber.bounds!, layer);
    stampDabs(canvas, textures.tips, dabber);
    canvas.restore();
  }

  @override
  void dispose() {
    textures.dispose();
  }
}
