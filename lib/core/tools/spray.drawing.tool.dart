import 'dart:math';
import 'dart:ui' as ui;

import '../../types/brush.type.dart';
import '../engine/dab.tip.dart';
import '../engine/stroke.dabber.dart';
import 'drawing.tool.dart';
import 'texture.canvas.dart';

/// Spray can: a spatter of round dots of mixed sizes, densest along the
/// middle of the path, with no solid core.
class SprayTool extends DrawingTool {
  SprayTool() : _tips = _SprayTips.build();

  final ui.Image _tips;

  static const DabTip sprayTip = DabTip(
    pixels: _SprayTips.pixels,
    variants: _SprayTips.variants,
    spacing: 0.45,
    alpha: 1,
    tipScale: 1.5,
    tapDabs: 4,
    rotationJitter: pi * 2,
  );

  @override
  BrushType get type => BrushType.spray;

  @override
  DabTip get tip => sprayTip;

  @override
  void paint(ui.Canvas canvas, StrokeDabber dabber) {
    if (dabber.isEmpty) return;
    stampDabs(canvas, _tips, dabber);
  }

  @override
  void dispose() => _tips.dispose();
}

/// Clusters of dots whose distance from the center follows a bell curve.
class _SprayTips {
  static const int variants = 6;
  static const double pixels = 128;
  static const int _dots = 55;

  static ui.Image build() {
    final random = Random(71);
    return TextureCanvas.render(pixels * variants, pixels, (canvas) {
      final dot = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
      for (var variant = 0; variant < variants; variant++) {
        final center = ui.Offset(variant * pixels + pixels / 2, pixels / 2);
        for (var i = 0; i < _dots; i++) {
          final radius = pixels * (0.014 + random.nextDouble() * 0.05);
          canvas.drawCircle(_dotPosition(center, random), radius, dot);
        }
      }
    });
  }

  /// A point around [center], kept inside its tip cell.
  static ui.Offset _dotPosition(ui.Offset center, Random random) {
    final angle = random.nextDouble() * pi * 2;
    final spread = _bell(random).abs() * pixels * 0.24;
    final distance = min(spread, pixels * 0.44);
    return center + ui.Offset(cos(angle), sin(angle)) * distance;
  }

  /// Normally distributed value (Box-Muller).
  static double _bell(Random random) {
    final u = 1 - random.nextDouble();
    final v = random.nextDouble();
    return sqrt(-2 * log(u)) * cos(2 * pi * v);
  }
}
