import 'dart:math';
import 'dart:ui' as ui;

/// Tip atlas and paper grain images for the pencil.
class PencilTextures {
  PencilTextures()
      : tips = buildTips(),
        paper = buildPaper();

  final ui.Image tips;
  final ui.Image paper;

  void dispose() {
    tips.dispose();
    paper.dispose();
  }

  static const int tipVariants = 4;
  static const double tipPixels = 96;
  static const double paperTile = 128;
  static const double paperPixelsPerUnit = 2;

  /// Soft round tips with streaks along the stroke direction, as atlas variants.
  static ui.Image buildTips() {
    final random = Random(11);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const size = tipPixels;
    const radius = size / 2;
    final lanes = _sharedLanes(random, size);

    for (var variant = 0; variant < tipVariants; variant++) {
      final originX = variant * size;
      final center = ui.Offset(originX + radius, radius);
      final cell = ui.Rect.fromLTWH(originX, 0, size, size);
      canvas.save();
      canvas.clipRect(cell);
      canvas.saveLayer(cell, ui.Paint());
      _drawTipBase(canvas, center, radius);
      _drawLaneStreaks(canvas, lanes, center, originX, size, random);
      _drawExtraStreaks(canvas, center, size, random);
      _drawPits(canvas, originX, size, random);
      canvas.restore();
      canvas.restore();
    }

    final picture = recorder.endRecording();
    final image = picture.toImageSync((size * tipVariants).toInt(), size.toInt());
    picture.dispose();
    return image;
  }

  /// Opaque paper with fine pits. Fixed in artwork space so grain stays put.
  static ui.Image buildPaper() {
    final random = Random(7);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    const pixels = paperTile * paperPixelsPerUnit;
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, pixels, pixels),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final pit = ui.Paint()..blendMode = ui.BlendMode.dstOut;
    for (var i = 0; i < 5200; i++) {
      pit.color = ui.Color.fromRGBO(0, 0, 0, 0.12 + random.nextDouble() * 0.38);
      final center = ui.Offset(
        random.nextDouble() * pixels,
        random.nextDouble() * pixels,
      );
      canvas.drawOval(
        ui.Rect.fromCenter(
          center: center,
          width: 0.8 + random.nextDouble() * 2.2,
          height: 0.8 + random.nextDouble() * 2.2,
        ),
        pit,
      );
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(pixels.toInt(), pixels.toInt());
    picture.dispose();
    return image;
  }

  static void _drawTipBase(ui.Canvas canvas, ui.Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      ui.Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          const [
            ui.Color(0xFFFFFFFF),
            ui.Color(0xF2FFFFFF),
            ui.Color(0x00FFFFFF),
          ],
          const [0, 0.68, 1],
        ),
    );
  }

  /// Streaks share lanes across variants so they line up along the stroke
  /// instead of averaging out.
  static List<_TipLane> _sharedLanes(Random random, double size) {
    final lanes = <_TipLane>[];
    for (var i = 0; i < 16; i++) {
      lanes.add(
        _TipLane(
          y: (random.nextDouble() - 0.5) * size * 0.9,
          width: 1 + random.nextDouble() * 2.2,
          alpha: 0.15 + random.nextDouble() * 0.3,
        ),
      );
    }
    return lanes;
  }

  static void _drawLaneStreaks(
    ui.Canvas canvas,
    List<_TipLane> lanes,
    ui.Offset center,
    double originX,
    double size,
    Random random,
  ) {
    final streak = ui.Paint()
      ..blendMode = ui.BlendMode.dstOut
      ..strokeCap = ui.StrokeCap.round;
    for (final lane in lanes) {
      streak.strokeWidth = lane.width;
      streak.color = ui.Color.fromRGBO(0, 0, 0, lane.alpha);
      final jitter = (random.nextDouble() - 0.5) * 1.2;
      final y = center.dy + lane.y + jitter;
      final left = ui.Offset(originX, y);
      final right = ui.Offset(originX + size, y);
      canvas.drawLine(left, right, streak);
    }
  }

  static void _drawExtraStreaks(
    ui.Canvas canvas,
    ui.Offset center,
    double size,
    Random random,
  ) {
    final streak = ui.Paint()
      ..blendMode = ui.BlendMode.dstOut
      ..strokeCap = ui.StrokeCap.round;
    for (var i = 0; i < 24; i++) {
      streak.strokeWidth = 0.8 + random.nextDouble() * 1.4;
      streak.color = ui.Color.fromRGBO(0, 0, 0, 0.2 + random.nextDouble() * 0.4);
      final y = center.dy + (random.nextDouble() - 0.5) * size * 0.9;
      final x = center.dx + (random.nextDouble() - 0.5) * size * 0.8;
      final length = 8 + random.nextDouble() * 30;
      final start = ui.Offset(x - length / 2, y);
      final end = ui.Offset(x + length / 2, y);
      canvas.drawLine(start, end, streak);
    }
  }

  static void _drawPits(
    ui.Canvas canvas,
    double originX,
    double size,
    Random random,
  ) {
    final pit = ui.Paint()..blendMode = ui.BlendMode.dstOut;
    for (var i = 0; i < 260; i++) {
      pit.color = ui.Color.fromRGBO(0, 0, 0, 0.35 + random.nextDouble() * 0.6);
      final position = ui.Offset(
        originX + random.nextDouble() * size,
        random.nextDouble() * size,
      );
      canvas.drawCircle(position, 0.5 + random.nextDouble() * 1.1, pit);
    }
  }
}

class _TipLane {
  const _TipLane({
    required this.y,
    required this.width,
    required this.alpha,
  });

  final double y;
  final double width;
  final double alpha;
}
