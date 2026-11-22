import 'dart:math';
import 'dart:ui' as ui;

import 'texture.canvas.dart';

/// Tip, sparkle and glint images for the glitter brush, built once in code.
class GlitterTextures {
  GlitterTextures()
    : tip = buildTip(),
      sparkles = buildSparkles(),
      glints = [for (var set = 0; set < glintSets; set++) buildGlints(set)];

  final ui.Image tip;
  final ui.Image sparkles;

  /// Sets of bright glints that fade in and out in turn to make the glitter
  /// shimmer. Same tile size as [sparkles].
  final List<ui.Image> glints;

  static const int glintSets = 3;
  static const double tipPixels = 96;

  /// Side of the repeating sparkle tile, in artwork units.
  static const double sparkleTile = 128;
  static const double sparklePixelsPerUnit = 2;
  static const double _tilePixels = sparkleTile * sparklePixelsPerUnit;

  static const int _fleckCount = 4800;
  static const double _brightShare = 0.45;
  static const double _paleShare = 0.30;

  static const int _glintCount = 700;
  static const double _flareChance = 0.12;

  void dispose() {
    tip.dispose();
    sparkles.dispose();
    for (final image in glints) {
      image.dispose();
    }
  }

  /// Opaque round tip with a thin soft rim, so glitter lays down as solid
  /// paint that never darkens where it overlaps.
  static ui.Image buildTip() {
    const radius = tipPixels / 2;
    const center = ui.Offset(radius, radius);
    return TextureCanvas.render(tipPixels, tipPixels, (canvas) {
      canvas.drawCircle(center, radius, _softEdgePaint(center, radius));
    });
  }

  /// Transparent tile of fine glitter flecks covering about a third of it:
  /// bright sparkles, pale mid tones and dark grains. Tiles seamlessly.
  static ui.Image buildSparkles() {
    final random = Random(23);
    return TextureCanvas.render(_tilePixels, _tilePixels, (canvas) {
      final fleck = ui.Paint()..isAntiAlias = false;
      for (var i = 0; i < _fleckCount; i++) {
        fleck.color = _randomFleckColor(random);
        final side = _randomSide(random, min: 0.7, range: 0.9);
        _drawWrapped(_randomPoint(random), (corner) {
          final rect = ui.Rect.fromLTWH(corner.dx, corner.dy, side, side);
          canvas.drawRect(rect, fleck);
        });
      }
    });
  }

  /// Transparent tile of sparse bright glints: small squares, some with a
  /// faint cross flare. Each [set] has its own random layout.
  static ui.Image buildGlints(int set) {
    final random = Random(101 + set * 17);
    return TextureCanvas.render(_tilePixels, _tilePixels, (canvas) {
      for (var i = 0; i < _glintCount; i++) {
        final alpha = 0.7 + random.nextDouble() * 0.3;
        final side = _randomSide(random, min: 0.8, range: 1.2);
        final point = _randomPoint(random);
        final hasFlare = random.nextDouble() < _flareChance;
        final glint = _glintPaint(alpha);
        final flare = _flarePaint(alpha);
        _drawWrapped(point, (center) {
          _drawGlint(canvas, center, side, glint);
          if (hasFlare) _drawFlare(canvas, center, side, flare);
        });
      }
    });
  }

  static ui.Paint _softEdgePaint(ui.Offset center, double radius) {
    return ui.Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        const [
          ui.Color(0xFFFFFFFF),
          ui.Color(0xFFFFFFFF),
          ui.Color(0x00FFFFFF),
        ],
        const [0, 0.86, 1],
      );
  }

  static ui.Color _randomFleckColor(Random random) {
    final kind = random.nextDouble();
    if (kind < _brightShare) return _brightFleck(random);
    if (kind < _brightShare + _paleShare) return _paleFleck(random);
    return _darkFleck(random);
  }

  static ui.Color _brightFleck(Random random) {
    final alpha = 0.55 + random.nextDouble() * 0.45;
    return ui.Color.fromRGBO(255, 255, 255, alpha);
  }

  static ui.Color _paleFleck(Random random) {
    final alpha = 0.3 + random.nextDouble() * 0.3;
    return ui.Color.fromRGBO(225, 230, 245, alpha);
  }

  static ui.Color _darkFleck(Random random) {
    final alpha = 0.22 + random.nextDouble() * 0.25;
    return ui.Color.fromRGBO(0, 0, 20, alpha);
  }

  static ui.Paint _glintPaint(double alpha) {
    return ui.Paint()
      ..isAntiAlias = false
      ..color = ui.Color.fromRGBO(255, 255, 255, alpha);
  }

  static ui.Paint _flarePaint(double alpha) {
    return ui.Paint()
      ..strokeWidth = 0.5 * sparklePixelsPerUnit
      ..strokeCap = ui.StrokeCap.round
      ..color = ui.Color.fromRGBO(255, 255, 255, alpha * 0.6);
  }

  static void _drawGlint(
    ui.Canvas canvas,
    ui.Offset center,
    double side,
    ui.Paint paint,
  ) {
    final rect = ui.Rect.fromCenter(center: center, width: side, height: side);
    canvas.drawRect(rect, paint);
  }

  /// Thin cross through a glint, like light catching it.
  static void _drawFlare(
    ui.Canvas canvas,
    ui.Offset center,
    double side,
    ui.Paint paint,
  ) {
    final arm = side * 1.8;
    final horizontal = ui.Offset(arm, 0);
    final vertical = ui.Offset(0, arm);
    canvas.drawLine(center - horizontal, center + horizontal, paint);
    canvas.drawLine(center - vertical, center + vertical, paint);
  }

  /// Draws at [point] and at its copies one tile away in every direction, so
  /// shapes crossing an edge continue on the opposite side.
  static void _drawWrapped(ui.Offset point, void Function(ui.Offset) draw) {
    const shifts = [-_tilePixels, 0.0, _tilePixels];
    for (final dx in shifts) {
      for (final dy in shifts) {
        draw(point + ui.Offset(dx, dy));
      }
    }
  }

  static ui.Offset _randomPoint(Random random) {
    final x = random.nextDouble() * _tilePixels;
    final y = random.nextDouble() * _tilePixels;
    return ui.Offset(x, y);
  }

  /// Random side length, in tile pixels.
  static double _randomSide(
    Random random, {
    required double min,
    required double range,
  }) {
    return (min + random.nextDouble() * range) * sparklePixelsPerUnit;
  }
}
