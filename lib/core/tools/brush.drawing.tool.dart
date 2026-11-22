import 'dart:math';
import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'texture.canvas.dart';

/// Paint brush: opaque thick paint with darker bristle streaks running along
/// the stroke.
class BrushTool extends DrawingTool {
  BrushTool() : tips = _BrushTips.build();

  final ui.Image tips;

  static const DabTip brushTip = DabTip(
    pixels: _BrushTips.pixels,
    variants: _BrushTips.variants,
    spacing: 0.05,
    alpha: 1,
    tipScale: 1.05,
    tapDabs: 3,
    rotationJitter: 0,
  );

  @override
  BrushType get type => BrushType.paintbrush;

  @override
  DabTip get tip => brushTip;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    canvas.saveLayer(dabber.bounds!, ui.Paint());
    stampDabs(canvas, tips, dabber);
    canvas.restore();
  }

  @override
  void dispose() => tips.dispose();
}

/// Round tips crossed by soft lines along x. Dabs turn with the stroke, so
/// the lines run along it as bristle streaks. `modulate` multiplies the paint
/// color by the tip: the light grey base gives the paint itself, darker lines
/// give darker streaks and white lines lighter ones. Every variant shares the
/// same bristles, so streaks stay continuous along the stroke.
class _BrushTips {
  static const int variants = 3;
  static const double pixels = 96;
  static const int _bristles = 12;
  static const int _baseGrey = 238;

  static ui.Image build() {
    return TextureCanvas.render(pixels * variants, pixels, (canvas) {
      for (var variant = 0; variant < variants; variant++) {
        _drawTip(canvas, variant);
      }
    });
  }

  static void _drawTip(ui.Canvas canvas, int variant) {
    final bristles = Random(53);
    final center = ui.Offset(variant * pixels + pixels / 2, pixels / 2);
    final disc = ui.Path()
      ..addOval(ui.Rect.fromCircle(center: center, radius: pixels * 0.46));
    canvas.save();
    canvas.clipPath(disc);
    canvas.drawPath(disc, _greyPaint(_baseGrey));
    for (var i = 0; i < _bristles; i++) {
      final y = bristles.nextDouble() * pixels;
      final line = _greyPaint(_streakGrey(bristles))
        ..strokeWidth = 1 + bristles.nextDouble() * 2
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 0.8);
      final left = ui.Offset(variant * pixels, y);
      canvas.drawLine(left, left + const ui.Offset(pixels, 0), line);
    }
    canvas.restore();
  }

  /// Two in three streaks are darker than the base, the rest are lighter.
  static int _streakGrey(Random random) {
    if (random.nextInt(3) == 0) return 255;
    return 200 + random.nextInt(25);
  }

  static ui.Paint _greyPaint(int grey) {
    return ui.Paint()..color = ui.Color.fromARGB(255, grey, grey, grey);
  }
}
