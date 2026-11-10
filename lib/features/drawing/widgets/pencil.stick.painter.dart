import 'package:flutter/material.dart';

import '../../../data/models/paint.color.dart';

/// A colored pencil lying horizontally with its tip on the left.
class PencilStickPainter extends CustomPainter {
  const PencilStickPainter(this.paintColor);

  final PaintColor paintColor;

  static const Color _wood = Color(0xFFEFC59A);
  static const Color _woodShade = Color(0xFFD9A774);

  static const List<Color> _rainbow = [
    Color(0xFFFF4D4D),
    Color(0xFFFFA23A),
    Color(0xFFFFE14D),
    Color(0xFF4CD964),
    Color(0xFF3A9BFF),
    Color(0xFF9B59FF),
    Color(0xFFFF5FC8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final coneEnd = h * 1.6;
    final tipEnd = coneEnd * 0.32;
    final body = Rect.fromLTWH(coneEnd, 0, w - coneEnd, h);
    final base = paintColor.color;

    final bodyPaint = Paint();
    if (paintColor.isRainbow) {
      bodyPaint.shader = const LinearGradient(colors: _rainbow).createShader(body);
    } else {
      bodyPaint.color = base;
    }
    canvas.drawRect(body, bodyPaint);
    if (!paintColor.isRainbow) {
      canvas.drawRect(
        Rect.fromLTWH(body.left, 0, body.width, h * 0.3),
        Paint()..color = Color.lerp(base, Colors.white, 0.35)!,
      );
      canvas.drawRect(
        Rect.fromLTWH(body.left, h * 0.7, body.width, h * 0.3),
        Paint()..color = Color.lerp(base, Colors.black, 0.22)!,
      );
    }

    final cone = Path()
      ..moveTo(tipEnd * 0.2, h / 2)
      ..lineTo(coneEnd, 0)
      ..lineTo(coneEnd, h)
      ..close();
    canvas.drawPath(cone, Paint()..color = _wood);
    canvas.drawPath(
      Path()
        ..moveTo(tipEnd * 0.2, h / 2)
        ..lineTo(coneEnd, h * 0.62)
        ..lineTo(coneEnd, h)
        ..close(),
      Paint()..color = _woodShade,
    );

    final leadPaint = Paint();
    final leadRect = Rect.fromLTWH(0, 0, tipEnd, h);
    if (paintColor.isRainbow) {
      leadPaint.shader =
          const LinearGradient(colors: [Color(0xFFFF4D4D), Color(0xFF9B59FF)])
              .createShader(leadRect);
    } else {
      leadPaint.color = base;
    }
    final lead = Path()
      ..moveTo(0, h / 2)
      ..lineTo(tipEnd, h / 2 - h * 0.5 * (tipEnd / coneEnd))
      ..lineTo(tipEnd, h / 2 + h * 0.5 * (tipEnd / coneEnd))
      ..close();
    canvas.drawPath(lead, leadPaint);
  }

  @override
  bool shouldRepaint(PencilStickPainter oldDelegate) =>
      oldDelegate.paintColor.id != paintColor.id;
}
