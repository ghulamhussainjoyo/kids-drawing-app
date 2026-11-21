import 'dart:math';
import 'dart:ui' as ui;

/// Tip and sparkle images for the glitter brush, built once in code.
class GlitterTextures {
  GlitterTextures()
    : tip = buildTip(),
      sparkles = buildSparkles(),
      glints = [for (var i = 0; i < glintSets; i++) buildGlints(i)];

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
    return _render(tipPixels, tipPixels, (canvas) {
      canvas.drawCircle(
        center,
        radius,
        ui.Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            const [
              ui.Color(0xFFFFFFFF),
              ui.Color(0xFFFFFFFF),
              ui.Color(0x00FFFFFF),
            ],
            const [0, 0.86, 1],
          ),
      );
    });
  }

  /// Transparent tile of fine glitter flecks covering about a third of it:
  /// bright sparkles, pale mid tones and dark grains. Tiles seamlessly.
  static ui.Image buildSparkles() {
    const pixels = sparkleTile * sparklePixelsPerUnit;
    final random = Random(23);
    return _render(pixels, pixels, (canvas) {
      final fleck = ui.Paint()..isAntiAlias = false;
      for (var i = 0; i < 4800; i++) {
        final kind = random.nextDouble();
        if (kind < 0.45) {
          fleck.color = ui.Color.fromRGBO(
            255,
            255,
            255,
            0.55 + random.nextDouble() * 0.45,
          );
        } else if (kind < 0.75) {
          fleck.color = ui.Color.fromRGBO(
            225,
            230,
            245,
            0.3 + random.nextDouble() * 0.3,
          );
        } else {
          fleck.color = ui.Color.fromRGBO(
            0,
            0,
            20,
            0.22 + random.nextDouble() * 0.25,
          );
        }
        final side = (0.7 + random.nextDouble() * 0.9) * sparklePixelsPerUnit;
        final x = random.nextDouble() * pixels;
        final y = random.nextDouble() * pixels;
        // Draw wrapped copies so flecks on the border tile seamlessly.
        for (final dx in const [-pixels, 0.0, pixels]) {
          for (final dy in const [-pixels, 0.0, pixels]) {
            canvas.drawRect(
              ui.Rect.fromLTWH(x + dx, y + dy, side, side),
              fleck,
            );
          }
        }
      }
    });
  }

  /// Transparent tile of sparse bright glints: small squares, some with a
  /// faint cross flare. Each [set] has its own random layout.
  static ui.Image buildGlints(int set) {
    const pixels = sparkleTile * sparklePixelsPerUnit;
    final random = Random(101 + set * 17);
    return _render(pixels, pixels, (canvas) {
      final glint = ui.Paint()..isAntiAlias = false;
      final flare = ui.Paint()
        ..strokeWidth = 0.5 * sparklePixelsPerUnit
        ..strokeCap = ui.StrokeCap.round;
      for (var i = 0; i < 700; i++) {
        final alpha = 0.7 + random.nextDouble() * 0.3;
        glint.color = ui.Color.fromRGBO(255, 255, 255, alpha);
        final side = (0.8 + random.nextDouble() * 1.2) * sparklePixelsPerUnit;
        final x = random.nextDouble() * pixels;
        final y = random.nextDouble() * pixels;
        final withFlare = random.nextDouble() < 0.12;
        flare.color = ui.Color.fromRGBO(255, 255, 255, alpha * 0.6);
        for (final dx in const [-pixels, 0.0, pixels]) {
          for (final dy in const [-pixels, 0.0, pixels]) {
            final center = ui.Offset(x + dx, y + dy);
            canvas.drawRect(
              ui.Rect.fromCenter(center: center, width: side, height: side),
              glint,
            );
            if (!withFlare) continue;
            final arm = side * 1.8;
            canvas
              ..drawLine(
                center - ui.Offset(arm, 0),
                center + ui.Offset(arm, 0),
                flare,
              )
              ..drawLine(
                center - ui.Offset(0, arm),
                center + ui.Offset(0, arm),
                flare,
              );
          }
        }
      }
    });
  }

  static ui.Image _render(
    double width,
    double height,
    void Function(ui.Canvas canvas) draw,
  ) {
    final recorder = ui.PictureRecorder();
    draw(ui.Canvas(recorder));
    final picture = recorder.endRecording();
    final image = picture.toImageSync(width.toInt(), height.toInt());
    picture.dispose();
    return image;
  }
}
