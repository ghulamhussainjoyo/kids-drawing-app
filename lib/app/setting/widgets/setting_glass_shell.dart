import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/paw_print_icon.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/circle.button.dart';

/// Frosted-glass notebook chrome around settings content.
class SettingGlassShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  static const Color creamTint = Color(0xB8F7F0E4);
  static const Color borderWarm = Color(0x66B8956C);
  static const Color stitchWarm = Color(0x55A88968);
  static const Color foldWarm = Color(0x33C4A882);
  static const Color pawWarm = Color(0xFF8B7355);

  const SettingGlassShell({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: creamTint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderWarm, width: 1.5),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _FoldPainter())),
              const Positioned.fill(
                child: CustomPaint(painter: _DashedStitchPainter()),
              ),
              Positioned(
                bottom: 14,
                left: 28,
                child: Opacity(
                  opacity: 0.16,
                  child: Transform.rotate(
                    angle: -0.25,
                    child: const PawPrintIcon(size: 30, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: 22,
                left: 88,
                child: Opacity(
                  opacity: 0.14,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: const PawPrintIcon(size: 24, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 150,
                child: Opacity(
                  opacity: 0.12,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: const PawPrintIcon(size: 22, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: 18,
                right: 120,
                child: Opacity(
                  opacity: 0.14,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: const PawPrintIcon(size: 26, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 52,
                child: Opacity(
                  opacity: 0.18,
                  child: Transform.rotate(
                    angle: -0.18,
                    child: const PawPrintIcon(size: 28, color: pawWarm),
                  ),
                ),
              ),
              Positioned.fill(child: child),
              Positioned(
                top: 12,
                right: 12,
                child: CircleButton(
                  size: 32,
                  responsive: false,
                  color: AppColors.purple,
                  onPressed: onClose,
                  image: const Icon(
                    CupertinoIcons.xmark,
                    color: Color(0xFFFFFFFF),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedStitchPainter extends CustomPainter {
  const _DashedStitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 10.0;
    const radius = 14.0;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(radius));
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = SettingGlassShell.stitchWarm
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedStitchPainter oldDelegate) => false;
}

class _FoldPainter extends CustomPainter {
  const _FoldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SettingGlassShell.foldWarm
      ..style = PaintingStyle.fill;

    // Top-center fold straddling the spine.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, 0),
        width: 90,
        height: 56,
      ),
      0,
      math.pi,
      true,
      paint,
    );

    // Bottom-left fold.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(0, size.height),
        width: 70,
        height: 70,
      ),
      -math.pi / 2,
      math.pi / 2,
      true,
      paint,
    );

    // Bottom-right fold.
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width, size.height),
        width: 70,
        height: 70,
      ),
      math.pi,
      math.pi / 2,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FoldPainter oldDelegate) => false;
}
