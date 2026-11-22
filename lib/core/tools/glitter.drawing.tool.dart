import 'dart:math' as math;
import 'dart:ui' as ui;

import '../../types/brush.type.dart';
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

  /// Seconds for one glint set to fade in and back out.
  static const double shimmerPeriod = 1.2;

  /// Glint sets fainter than this are skipped for the frame.
  static const double _minGlintOpacity = 0.02;

  /// Tile offsets per glint set, so sets never line up with each other.
  static const int _glintSeedBase = 41;
  static const int _glintSeedStep = 59;

  /// Multipliers that turn a seed into a tile offset, in artwork units.
  static const int _tileShiftX = 53;
  static const int _tileShiftY = 29;

  @override
  BrushType get type => BrushType.glitter;

  @override
  DabTip get tip => glitterTip;

  @override
  bool get hasShimmer => true;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    final bounds = dabber.bounds!;
    canvas.saveLayer(bounds, ui.Paint());
    stampDabs(canvas, textures.tip, dabber);
    canvas.drawRect(bounds, _sparkles(dabber.seed));
    canvas.restore();
  }

  /// Paints twinkling glints over [bounds], kept only where [coverage]
  /// draws opaque pixels (the glitter visible on the page).
  @override
  void paintShimmer(
    ui.Canvas canvas, {
    required ui.Rect bounds,
    required double seconds,
    required void Function(ui.Canvas canvas) coverage,
  }) {
    canvas.saveLayer(bounds, ui.Paint());
    _drawGlints(canvas, bounds, seconds);
    _keepOnly(canvas, bounds, coverage);
    canvas.restore();
  }

  @override
  void dispose() => textures.dispose();

  void _drawGlints(ui.Canvas canvas, ui.Rect bounds, double seconds) {
    for (var set = 0; set < textures.glints.length; set++) {
      final opacity = _glintOpacity(set, seconds);
      if (!_isVisible(opacity)) continue;
      canvas.drawRect(bounds, _glintPaint(set, opacity));
    }
  }

  /// Erases everything outside [coverage].
  void _keepOnly(
    ui.Canvas canvas,
    ui.Rect bounds,
    void Function(ui.Canvas canvas) coverage,
  ) {
    canvas.saveLayer(bounds, ui.Paint()..blendMode = ui.BlendMode.dstIn);
    coverage(canvas);
    canvas.restore();
  }

  /// Each set fades in and out on a sine wave, offset from the other sets so
  /// they take turns.
  double _glintOpacity(int set, double seconds) {
    final phase = seconds / shimmerPeriod + set / textures.glints.length;
    final wave = math.sin(math.pi * phase);
    return wave * wave;
  }

  bool _isVisible(double opacity) => opacity >= _minGlintOpacity;

  ui.Paint _glintPaint(int set, double opacity) {
    final seed = _glintSeedBase + set * _glintSeedStep;
    return _tilePaint(textures.glints[set], seed)
      ..color = ui.Color.fromRGBO(255, 255, 255, opacity);
  }

  /// Flecks drawn only where paint already is (srcATop), shifted per stroke
  /// so overlapping strokes don't line up.
  ui.Paint _sparkles(int seed) {
    return _tilePaint(textures.sparkles, seed)
      ..blendMode = ui.BlendMode.srcATop;
  }

  /// Repeating texture tile fixed to the page, shifted by [seed].
  ui.Paint _tilePaint(ui.Image tile, int seed) {
    const size = GlitterTextures.sparkleTile;
    final shift = ui.Offset(
      (seed * _tileShiftX) % size,
      (seed * _tileShiftY) % size,
    );
    return tiledPaint(
      tile,
      shift: shift,
      pixelsPerUnit: GlitterTextures.sparklePixelsPerUnit,
      quality: ui.FilterQuality.none,
    );
  }
}
