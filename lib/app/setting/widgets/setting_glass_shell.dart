import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/paw_print_icon.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

/// Frosted-glass notebook chrome around settings content.
class SettingGlassShell extends StatelessWidget {
  final Widget child;

  static const Color creamTint = Color(0xB8F7F0E4);
  static const Color borderWarm = Color(0x66B8956C);
  static const Color foldWarm = Color(0x33C4A882);
  static const Color pawWarm = Color(0xFF8B7355);

  const SettingGlassShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final pawSmall = context.rs(28);
    final pawMid = context.rs(36);
    final pawLarge = context.rs(48);
    final puppySize = context.rs(118);

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
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _FoldPainter()),
              ),
              // Large faint background paws (right cream pane feel).
              Positioned(
                top: context.rs(72),
                right: context.rs(40),
                child: Opacity(
                  opacity: 0.18,
                  child: Transform.rotate(
                    angle: -0.35,
                    child: PawPrintIcon(size: pawLarge, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                top: context.rs(160),
                right: context.rs(130),
                child: Opacity(
                  opacity: 0.14,
                  child: Transform.rotate(
                    angle: 0.4,
                    child: PawPrintIcon(size: pawMid, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: context.rs(100),
                right: context.rs(200),
                child: Opacity(
                  opacity: 0.16,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: PawPrintIcon(size: pawLarge * 0.9, color: pawWarm),
                  ),
                ),
              ),
              // Bottom trail near spine / cream band.
              Positioned(
                bottom: context.rs(16),
                left: context.rs(28),
                child: Opacity(
                  opacity: 0.28,
                  child: Transform.rotate(
                    angle: -0.25,
                    child: PawPrintIcon(size: pawMid, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: context.rs(24),
                left: context.rs(88),
                child: Opacity(
                  opacity: 0.24,
                  child: Transform.rotate(
                    angle: 0.3,
                    child: PawPrintIcon(size: pawSmall, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: context.rs(14),
                left: context.rs(150),
                child: Opacity(
                  opacity: 0.22,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: PawPrintIcon(size: pawSmall * 0.9, color: pawWarm),
                  ),
                ),
              ),
              Positioned(
                bottom: context.rs(20),
                right: context.rs(150),
                child: Opacity(
                  opacity: 0.26,
                  child: Transform.rotate(
                    angle: 0.2,
                    child: PawPrintIcon(size: pawMid * 0.85, color: pawWarm),
                  ),
                ),
              ),
              // Puppy behind section options — below child in the stack.
              Positioned(
                right: context.rs(-6),
                bottom: context.rs(-4),
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/png/pupply-hand-raised-flipped.png',
                    width: puppySize,
                    height: puppySize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned.fill(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoldPainter extends CustomPainter {
  const _FoldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SettingGlassShell.foldWarm
      ..style = PaintingStyle.fill;

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

    canvas.drawArc(
      Rect.fromCenter(center: Offset(0, size.height), width: 70, height: 70),
      -math.pi / 2,
      math.pi / 2,
      true,
      paint,
    );

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
