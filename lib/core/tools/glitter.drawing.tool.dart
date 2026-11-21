import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show Matrix4;

import '../../types/brush.type.dart';
import '../../types/drawing.stroke.dart';
import '../engine/dab.buffer.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'glitter.textures.dart';

/// Glitter glue: an opaque band in the stroke's colors, sprinkled with
/// sparkle flecks that stay fixed to the page.
class GlitterTool extends DrawingTool {
  GlitterTool() : textures = GlitterTextures();

  final GlitterTextures textures;

  static const DabTip glitterTip = DabTip(
    pixels: GlitterTextures.tipPixels,
    variants: 1,
    spacing: 0.08,
    alpha: 1,
    tipScale: 1,
    tapDabs: 1,
  );

  @override
  BrushType get type => BrushType.glitter;

  @override
  StrokeDabber createDabber(DrawingStroke stroke) {
    final paintColor = stroke.brush.paintColor;
    return StrokeDabber(
      tip: glitterTip,
      width: stroke.brush.size,
      seed: stroke.seed,
      colorAt: (distance) => paintColor.colorAt(distance, stroke.seed),
    );
  }

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    final bounds = dabber.bounds;
    if (bounds == null) return;
    if (dabber.dabs.count + dabber.tail.count == 0) return;
    final atlasPaint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
    canvas.saveLayer(bounds, ui.Paint());
    _stamp(canvas, dabber.dabs, atlasPaint);
    _stamp(canvas, dabber.tail, atlasPaint);
    canvas.drawRect(bounds, _sparkles(dabber.seed));
    canvas.restore();
  }

  /// Seconds for one glint set to fade in and back out.
  static const double shimmerPeriod = 1.2;

  /// Paints twinkling glints over [bounds], kept only where [coverage]
  /// draws opaque pixels (the glitter visible on the page). [seconds] drives
  /// the twinkle.
  @override
  void paintShimmer(
    ui.Canvas canvas, {
    required ui.Rect bounds,
    required double seconds,
    required void Function(ui.Canvas canvas) coverage,
  }) {
    canvas.saveLayer(bounds, ui.Paint());
    final sets = textures.glints.length;
    for (var i = 0; i < sets; i++) {
      final wave = math.sin(math.pi * (seconds / shimmerPeriod + i / sets));
      final opacity = wave * wave;
      if (opacity < 0.02) continue;
      canvas.drawRect(
        bounds,
        _tilePaint(textures.glints[i], 41 + i * 59)
          ..color = ui.Color.fromRGBO(255, 255, 255, opacity),
      );
    }
    canvas.saveLayer(bounds, ui.Paint()..blendMode = ui.BlendMode.dstIn);
    coverage(canvas);
    canvas.restore();
    canvas.restore();
  }

  @override
  void dispose() => textures.dispose();

  void _stamp(ui.Canvas canvas, DabBuffer buffer, ui.Paint atlasPaint) {
    if (buffer.count == 0) return;
    canvas.drawRawAtlas(
      textures.tip,
      buffer.transforms,
      buffer.rects,
      buffer.colors,
      ui.BlendMode.modulate,
      null,
      atlasPaint,
    );
  }

  /// Flecks drawn only where paint already is (srcATop), anchored to the page
  /// and shifted per stroke so overlapping strokes don't line up.
  ui.Paint _sparkles(int seed) =>
      _tilePaint(textures.sparkles, seed)..blendMode = ui.BlendMode.srcATop;

  /// Repeating texture tile fixed to the page, shifted by [seed].
  ui.Paint _tilePaint(ui.Image tile, int seed) {
    const size = GlitterTextures.sparkleTile;
    final matrix =
        Matrix4.translationValues((seed * 53) % size, (seed * 29) % size, 0)
          ..scaleByDouble(
            1 / GlitterTextures.sparklePixelsPerUnit,
            1 / GlitterTextures.sparklePixelsPerUnit,
            1,
            1,
          );
    return ui.Paint()
      ..shader = ui.ImageShader(
        tile,
        ui.TileMode.repeated,
        ui.TileMode.repeated,
        matrix.storage,
        filterQuality: ui.FilterQuality.none,
      );
  }
}
