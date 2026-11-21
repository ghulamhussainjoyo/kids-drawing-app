import 'dart:math';
import 'dart:ui' as ui;

/// Soft round marker tips — no streaks, no paper grain.
class MarkerTextures {
  MarkerTextures() : tips = buildTips();

  final ui.Image tips;

  void dispose() {
    tips.dispose();
  }

  static const int tipVariants = 3;
  static const double tipPixels = 64;

  static ui.Image buildTips() {
    final random = Random(23);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const size = tipPixels;
    const radius = size / 2;

    for (var variant = 0; variant < tipVariants; variant++) {
      final originX = variant * size;
      final center = ui.Offset(originX + radius, radius);
      final cell = ui.Rect.fromLTWH(originX, 0, size, size);
      canvas.save();
      canvas.clipRect(cell);
      final edge = 0.88 + random.nextDouble() * 0.08;
      canvas.drawCircle(
        center,
        radius,
        ui.Paint()
          ..shader = ui.Gradient.radial(
            center,
            radius,
            [
              const ui.Color(0xFFFFFFFF),
              ui.Color.fromRGBO(255, 255, 255, edge),
              const ui.Color(0x00FFFFFF),
            ],
            const [0, 0.72, 1],
          ),
      );
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final image = picture.toImageSync((size * tipVariants).toInt(), size.toInt());
    picture.dispose();
    return image;
  }
}