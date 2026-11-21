import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The glitter category icon: an upright glue bottle full of gold glitter.
/// Fills tight constraints; otherwise takes its natural square size.
class GlitterBottleIcon extends StatelessWidget {
  const GlitterBottleIcon({super.key});

  static const double naturalSize = 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: naturalSize,
      child: CustomPaint(painter: _GlitterBottlePainter()),
    );
  }
}

const Color _capWhite = Color(0xFFF7F7FB);
const Color _capShade = Color(0xFFD5D6E4);

class _GlitterBottlePainter extends CustomPainter {
  static const List<Color> _gold = [Color(0xFFFFE27A), Color(0xFFF2A818)];

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    // Gold nozzle tip.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.45, s * 0.04, s * 0.55, s * 0.14),
        Radius.circular(s * 0.03),
      ),
      Paint()..color = _gold.last,
    );

    // White cone and collar.
    final capPaint = Paint()
      ..shader = const LinearGradient(colors: [_capWhite, _capShade])
          .createShader(Rect.fromLTWH(0, 0, s, s));
    canvas.drawPath(
      Path()
        ..moveTo(s * 0.44, s * 0.12)
        ..lineTo(s * 0.56, s * 0.12)
        ..lineTo(s * 0.66, s * 0.3)
        ..lineTo(s * 0.34, s * 0.3)
        ..close(),
      capPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(s * 0.3, s * 0.28, s * 0.7, s * 0.38),
        Radius.circular(s * 0.04),
      ),
      capPaint,
    );

    // Glitter body.
    final bodyRect = Rect.fromLTRB(s * 0.27, s * 0.36, s * 0.73, s * 0.96);
    final body = RRect.fromRectAndRadius(bodyRect, Radius.circular(s * 0.12));
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      bodyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gold,
        ).createShader(bodyRect),
    );
    _paintGlitter(canvas, bodyRect, 7);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlitterBottlePainter oldDelegate) => false;
}

/// Sprinkles twinkle stars and specks over [rect]. Same [seed], same look.
void _paintGlitter(Canvas canvas, Rect rect, int seed) {
  final random = math.Random(seed);
  final unit = math.min(rect.width, rect.height);
  final speck = Paint();
  final speckCount = (rect.width * rect.height / (unit * unit) * 14).round();
  for (var i = 0; i < speckCount; i++) {
    final light = random.nextDouble() < 0.7;
    speck.color = light
        ? Color.fromRGBO(255, 255, 255, 0.45 + random.nextDouble() * 0.5)
        : Color.fromRGBO(0, 0, 0, 0.12 + random.nextDouble() * 0.15);
    canvas.drawCircle(
      _randomPoint(random, rect),
      unit * (0.02 + random.nextDouble() * 0.03),
      speck,
    );
  }
  final star = Paint()..color = const Color(0xFFFFFFFF);
  final starCount = math.max(2, (rect.width / unit * 1.6).round());
  for (var i = 0; i < starCount; i++) {
    _drawTwinkle(
      canvas,
      _randomPoint(random, rect),
      unit * (0.12 + random.nextDouble() * 0.1),
      star,
    );
  }
}

Offset _randomPoint(math.Random random, Rect rect) => Offset(
  rect.left + random.nextDouble() * rect.width,
  rect.top + random.nextDouble() * rect.height,
);

/// Four-point twinkle star.
void _drawTwinkle(Canvas canvas, Offset center, double radius, Paint paint) {
  final inner = radius * 0.22;
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final r = i.isEven ? radius : inner;
    final angle = -math.pi / 2 + i * math.pi / 4;
    final point = center + Offset(math.cos(angle), math.sin(angle)) * r;
    i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
  }
  canvas.drawPath(path..close(), paint);
}
