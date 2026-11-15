import 'package:flutter/cupertino.dart';

/// Notebook binder rings between the settings nav and detail pages.
class SpiralDivider extends StatelessWidget {
  final double width;

  const SpiralDivider({super.key, this.width = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CustomPaint(
        painter: _SpiralPainter(),
        size: Size(width, double.infinity),
      ),
    );
  }
}

class _SpiralPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Soft page crease / gutter behind the rings.
    final creasePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: const [
          Color(0x14A88968),
          Color(0x28A88968),
          Color(0x14A88968),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, creasePaint);

    final spinePaint = Paint()
      ..color = const Color(0x33A88968)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width / 2, 10),
      Offset(size.width / 2, size.height - 10),
      spinePaint,
    );

    const ringCount = 8;
    const topPadding = 20.0;
    const bottomPadding = 20.0;
    const ringWidth = 16.0;
    const ringHeight = 10.0;
    final availableHeight = size.height - topPadding - bottomPadding;
    if (availableHeight <= 0) {
      return;
    }

    final step = availableHeight / (ringCount - 1);
    final fillPaint = Paint()
      ..color = const Color(0xFFE8E4DC)
      ..style = PaintingStyle.fill;
    final edgePaint = Paint()
      ..color = const Color(0x66B0A89C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    for (var i = 0; i < ringCount; i++) {
      final centerY = topPadding + (i * step);
      final rect = Rect.fromCenter(
        center: Offset(size.width / 2, centerY),
        width: ringWidth,
        height: ringHeight,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
      canvas.drawRRect(rrect.shift(const Offset(0, 1)), shadowPaint);
      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, edgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpiralPainter oldDelegate) => false;
}
