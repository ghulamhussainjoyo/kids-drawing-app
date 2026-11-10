import 'package:flutter/material.dart';

import '../../../core/ui/theme/app.colors.dart';

/// The brush-size slider, shown at its default value. Its interaction is
/// specified later, so it does not respond to touch yet.
class SizeSliderDisplay extends StatelessWidget {
  const SizeSliderDisplay({super.key, required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Brush size',
      excludeSemantics: true,
      child: CustomPaint(
        size: Size(width, height),
        painter: const _SizeSliderPainter(handle: 0.45),
      ),
    );
  }
}

class _SizeSliderPainter extends CustomPainter {
  const _SizeSliderPainter({required this.handle});

  /// Handle position from the top, as a fraction of the height.
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
  bool shouldRepaint(_SizeSliderPainter oldDelegate) => oldDelegate.handle != handle;
}
