import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';

class SizeSliderDisplay extends StatelessWidget {
  const SizeSliderDisplay({
    super.key,
    required this.width,
    required this.height,
    required this.value,
    this.onChanged,
  });

  final double width;
  final double height;

  /// 0 = bottom (thin), 1 = top (thick).
  final double value;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    final handle = (1.0 - value).clamp(0.08, 0.88);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final onChanged = this.onChanged;
        if (onChanged == null) {
          return;
        }
        final next = value - details.delta.dy / height;
        onChanged(next.clamp(0.0, 1.0));
      },
      child: Semantics(
        label: 'Brush size',
        excludeSemantics: true,
        child: CustomPaint(
          size: Size(width, height),
          painter: _SizeSliderPainter(handle: handle),
        ),
      ),
    );
  }
}

class _SizeSliderPainter extends CustomPainter {
  const _SizeSliderPainter({required this.handle});

  final double handle;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final handleY = h * handle;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(w * 0.2, 0, w * 0.8, handleY + h * 0.02),
        topLeft: Radius.circular(w * 0.3),
        topRight: Radius.circular(w * 0.3),
      ),
      Paint()..color = AppColors.lavender,
    );

    final taper = Path()
      ..moveTo(w * 0.2, handleY)
      ..lineTo(w * 0.8, handleY)
      ..lineTo(w * 0.6, h * 0.95)
      ..quadraticBezierTo(w * 0.5, h, w * 0.4, h * 0.95)
      ..close();
    canvas.drawPath(taper, Paint()..color = AppColors.purple);

    final bar = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.06, handleY - h * 0.03, w * 0.94, handleY + h * 0.03),
      Radius.circular(h * 0.03),
    );
    canvas.drawRRect(bar, Paint()..color = const Color(0xFFB991F5));
    canvas.drawRRect(
      bar.deflate(h * 0.012),
      Paint()..color = const Color(0xFF6A28CF),
    );
  }

  @override
  bool shouldRepaint(_SizeSliderPainter oldDelegate) =>
      oldDelegate.handle != handle;
}
