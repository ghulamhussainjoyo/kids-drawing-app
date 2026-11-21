import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../engine/dab.buffer.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'marker.textures.dart';

/// Semi-opaque smooth marker stroke.
class MarkerTool extends DrawingTool {
  MarkerTool() : textures = MarkerTextures();

  final MarkerTextures textures;

  static const DabTip markerTip = DabTip(
    pixels: MarkerTextures.tipPixels,
    variants: MarkerTextures.tipVariants,
    spacing: 0.22,
    alpha: 0.5,
    tipScale: 1.15,
    tapDabs: 5,
  );

  @override
  BrushType get type => BrushType.marker;

  @override
  StrokeDabber createDabber(DrawingStroke stroke) {
    return StrokeDabber(
      tip: markerTip,
      width: stroke.brush.size,
      seed: stroke.seed,
      colorAt: (_) => stroke.brush.paintColor.color,
    );
  }

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    final bounds = dabber.bounds;
    if (bounds == null) return;
    if (dabber.dabs.count + dabber.tail.count == 0) return;
    final atlasPaint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    canvas.saveLayer(bounds, ui.Paint());
    stamp(canvas, dabber.dabs, atlasPaint);
    stamp(canvas, dabber.tail, atlasPaint);
    canvas.restore();
  }

  @override
  void dispose() {
    textures.dispose();
  }

  void stamp(ui.Canvas canvas, DabBuffer buffer, ui.Paint atlasPaint) {
    if (buffer.count == 0) return;
    canvas.drawRawAtlas(
      textures.tips,
      buffer.transforms,
      buffer.rects,
      buffer.colors,
      ui.BlendMode.modulate,
      null,
      atlasPaint,
    );
  }
}