import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../engine/dab.buffer.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'glitter.textures.dart';

/// Spaced sparkle stamps along the stroke path.
class GlitterTool extends DrawingTool {
  GlitterTool() : textures = GlitterTextures();

  final GlitterTextures textures;

  DabTip get _tip => DabTip(
    alpha: 1,
    tapDabs: 2,
    spacing: 0.32,
    tipScale: 2.0,
    pixels: GlitterTextures.stampCell,
    variants: GlitterTextures.variantCount,
  );

  void stamp(
    ui.Canvas canvas,
    ui.Image grain,
    DabBuffer buffer,
    ui.Paint atlasPaint,
  ) {
    if (buffer.count == 0) return;
    canvas.drawRawAtlas(
      grain,
      buffer.transforms,
      buffer.rects,
      buffer.colors,
      ui.BlendMode.modulate,
      null,
      atlasPaint,
    );
  }

  @override
  BrushType get type => BrushType.glitter;

  @override
  StrokeDabber createDabber(DrawingStroke stroke) {
    return StrokeDabber(
      tip: _tip,
      width: stroke.brush.size,
      seed: stroke.seed,
      colorAt: (_) => stroke.brush.paintColor.color,
    );
  }

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    final grain = textures.grain;
    if (grain == null) return;
    final bounds = dabber.bounds;
    if (bounds == null) return;
    if (dabber.dabs.count + dabber.tail.count == 0) return;
    final atlasPaint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    stamp(canvas, grain, dabber.dabs, atlasPaint);
    stamp(canvas, grain, dabber.tail, atlasPaint);
  }

  @override
  void dispose() {
    textures.dispose();
  }

  Future<void> ensureLoaded() => textures.ensureLoaded();
}