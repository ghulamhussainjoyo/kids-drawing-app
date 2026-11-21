import 'dart:math' as math;
import 'dart:ui';

/// Particle shapes. Each draws in a unit box centred on the origin.
enum BurstShape {
  star,
  flower,
  heart,
  butterfly,
  sparkle;

  void paint(Canvas canvas, Paint fill, Paint detail, double opacity) {
    switch (this) {
      case BurstShape.star:
        canvas.drawPath(_star, fill);
      case BurstShape.flower:
        canvas.drawPath(_petals, fill);
        detail.color = Color.fromRGBO(255, 240, 150, opacity);
        canvas.drawCircle(Offset.zero, 0.15, detail);
      case BurstShape.heart:
        canvas.drawPath(_heart, fill);
      case BurstShape.butterfly:
        canvas.drawPath(_wings, fill);
        detail.color = Color.fromRGBO(60, 40, 70, opacity);
        canvas.drawPath(_body, detail);
      case BurstShape.sparkle:
        canvas.drawPath(_sparkle, fill);
    }
  }
}

final Path _star = _radialPath(points: 5, outer: 0.5, inner: 0.22);
final Path _sparkle = _radialPath(points: 4, outer: 0.5, inner: 0.12);

final Path _heart = Path()
  ..moveTo(0, 0.42)
  ..cubicTo(-0.6, 0.02, -0.42, -0.5, 0, -0.2)
  ..cubicTo(0.42, -0.5, 0.6, 0.02, 0, 0.42)
  ..close();

final Path _petals = () {
  final path = Path();
  for (var i = 0; i < 5; i++) {
    final angle = i * math.pi * 2 / 5;
    path.addOval(
      Rect.fromCircle(
        center: Offset(math.cos(angle), math.sin(angle)) * 0.26,
        radius: 0.2,
      ),
    );
  }
  return path;
}();

final Path _wings = Path()
  ..addOval(
    Rect.fromCenter(
      center: const Offset(-0.22, -0.14),
      width: 0.42,
      height: 0.5,
    ),
  )
  ..addOval(
    Rect.fromCenter(
      center: const Offset(0.22, -0.14),
      width: 0.42,
      height: 0.5,
    ),
  )
  ..addOval(
    Rect.fromCenter(center: const Offset(-0.18, 0.2), width: 0.3, height: 0.34),
  )
  ..addOval(
    Rect.fromCenter(center: const Offset(0.18, 0.2), width: 0.3, height: 0.34),
  );

final Path _body = Path()
  ..addRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: 0.09, height: 0.62),
      const Radius.circular(0.05),
    ),
  );

Path _radialPath({
  required int points,
  required double outer,
  required double inner,
}) {
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outer : inner;
    final angle = -math.pi / 2 + i * math.pi / points;
    final point = Offset(math.cos(angle), math.sin(angle)) * radius;
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  return path..close();
}
