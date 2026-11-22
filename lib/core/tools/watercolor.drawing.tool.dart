import 'dart:math';
import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'marker.textures.dart';
import 'texture.canvas.dart';

/// Watercolor, matched to the reference app: a light wash (about 37% in the
/// middle) with a feathered edge, a darker wet-edge band just inside it, and
/// fine mottled grain that never punches white holes. Strokes stack, so a
/// second coat is darker.
class WatercolorTool extends DrawingTool {
  WatercolorTool()
    : _tips = MarkerTextures.buildTips(softEdge: featherEdge),
      _grain = _WatercolorGrain.build();

  final ui.Image _tips;
  final ui.Image _grain;

  static const DabTip watercolorTip = DabTip(
    pixels: MarkerTextures.tipPixels,
    variants: MarkerTextures.tipVariants,
    spacing: 0.15,
    alpha: 1,
    tipScale: 1.15,
    tapDabs: 4,
  );

  /// Part of the tip radius that fades out, for a feathered edge.
  static const double featherEdge = 0.35;

  /// Opacity of the wet-edge band; the middle is lighter.
  static const double washOpacity = 0.68;

  /// How much paint the middle loses next to the wet edge.
  static const double rimContrast = 0.45;

  /// Width of the wet-edge band, as a fraction of the stroke width.
  static const double rimSoftness = 0.15;

  @override
  BrushType get type => BrushType.watercolor;

  @override
  DabTip get tip => watercolorTip;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    final bounds = dabber.bounds!;
    canvas.saveLayer(bounds, _washLayer());
    stampDabs(canvas, _tips, dabber);
    _thinMiddle(canvas, bounds, dabber);
    canvas.drawRect(bounds, _granulation(dabber.seed));
    canvas.restore();
  }

  @override
  void dispose() {
    _tips.dispose();
    _grain.dispose();
  }

  ui.Paint _washLayer() {
    return ui.Paint()
      ..color = const ui.Color(0xFF000000).withValues(alpha: washOpacity);
  }

  /// Removes some paint from the middle with a blurred copy of the stroke.
  /// The blur fades out at the edges, so they keep more paint: the wet edge.
  void _thinMiddle(ui.Canvas canvas, ui.Rect bounds, StrokeDabber dabber) {
    final sigma = dabber.width * rimSoftness;
    final cut = ui.Paint()
      ..blendMode = ui.BlendMode.dstOut
      ..color = const ui.Color(0xFF000000).withValues(alpha: rimContrast)
      ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
    canvas.saveLayer(bounds, cut);
    stampDabs(canvas, _tips, dabber);
    canvas.restore();
  }

  /// Fine mottled tone (dstIn), shifted per stroke so coats do not line up.
  ui.Paint _granulation(int seed) {
    const tile = _WatercolorGrain.tile;
    final shift = ui.Offset((seed * 29) % tile, (seed * 83) % tile);
    return tiledPaint(
      _grain,
      shift: shift,
      pixelsPerUnit: _WatercolorGrain.pixelsPerUnit,
      quality: ui.FilterQuality.low,
    )..blendMode = ui.BlendMode.dstIn;
  }
}

/// Opaque tile dusted with many faint 1 px dots. Each dot removes only a
/// little alpha, so the wash varies in tone but never shows white specks.
class _WatercolorGrain {
  static const double tile = 128;
  static const double pixelsPerUnit = 2;
  static const double _pixels = tile * pixelsPerUnit;
  static const int _dots = 40000;
  static const double _minFade = 0.04;
  static const double _fadeRange = 0.16;

  static ui.Image build() {
    final random = Random(61);
    return TextureCanvas.render(_pixels, _pixels, (canvas) {
      final rect = ui.Rect.fromLTWH(0, 0, _pixels, _pixels);
      canvas.saveLayer(rect, ui.Paint());
      canvas.drawRect(rect, ui.Paint());
      for (var i = 0; i < _dots; i++) {
        canvas.drawRect(_randomDot(random), _fadePaint(random));
      }
      canvas.restore();
    });
  }

  static ui.Rect _randomDot(Random random) {
    final x = random.nextInt(_pixels.toInt()).toDouble();
    final y = random.nextInt(_pixels.toInt()).toDouble();
    return ui.Rect.fromLTWH(x, y, 1, 1);
  }

  static ui.Paint _fadePaint(Random random) {
    final fade = _minFade + random.nextDouble() * _fadeRange;
    return ui.Paint()
      ..blendMode = ui.BlendMode.dstOut
      ..color = ui.Color.fromRGBO(0, 0, 0, fade);
  }
}
