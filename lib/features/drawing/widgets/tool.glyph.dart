import 'package:flutter/material.dart';

import '../../../data/models/brush.type.dart';

/// The tool's drawing on its own, used in tiles and the active-tool badge.
class ToolGlyph extends StatelessWidget {
  const ToolGlyph({super.key, required this.type, required this.size});

  final BrushType type;
  final double size;

  static String label(BrushType type) => switch (type) {
        BrushType.bucket => 'Bucket',
        BrushType.crayon => 'Crayon',
        BrushType.paintbrush => 'Brush',
        BrushType.wand => 'Wand',
        BrushType.pencil => 'Pencil',
        BrushType.marker => 'Marker',
        BrushType.eraser => 'Eraser',
      };

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      BrushType.bucket => Icons.format_color_fill_rounded,
      BrushType.crayon => Icons.create_rounded,
      BrushType.paintbrush => Icons.brush_rounded,
      BrushType.wand => Icons.auto_fix_high_rounded,
      BrushType.marker => Icons.border_color_rounded,
      BrushType.pencil || BrushType.eraser => null,
    };
    if (icon != null) {
      return Icon(icon, size: size, color: Colors.white);
    }
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: type == BrushType.pencil
            ? const _UprightPencilPainter()
            : const _EraserPainter(),
      ),
    );
  }
}

class _UprightPencilPainter extends CustomPainter {
  const _UprightPencilPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final left = w * 0.3;
    final right = w * 0.7;
    final coneBase = h * 0.38;
    canvas.drawPath(
      Path()
        ..moveTo(w / 2, 0)
        ..lineTo(right, coneBase)
        ..lineTo(left, coneBase)
        ..close(),
      Paint()..color = const Color(0xFFEFC59A),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w / 2, 0)
        ..lineTo(w / 2 + (right - left) * 0.14, h * 0.12)
        ..lineTo(w / 2 - (right - left) * 0.14, h * 0.12)
        ..close(),
      Paint()..color = const Color(0xFF2FA84F),
    );
    final body = Rect.fromLTRB(left, coneBase, right, h);
    canvas.drawRect(body, Paint()..color = const Color(0xFF3DC45A));
    canvas.drawRect(
      Rect.fromLTRB(left, coneBase, left + body.width / 3, h),
      Paint()..color = const Color(0xFF7BE08F),
    );
    canvas.drawRect(
      Rect.fromLTRB(right - body.width / 3, coneBase, right, h),
      Paint()..color = const Color(0xFF2A9A45),
    );
  }

  @override
  bool shouldRepaint(_UprightPencilPainter oldDelegate) => false;
}

class _EraserPainter extends CustomPainter {
  const _EraserPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.08,
      size.width * 0.6,
      size.height * 0.84,
    );
    final radius = Radius.circular(size.width * 0.14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(body, radius),
      Paint()..color = const Color(0xFF9B5CF6),
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(body.left, body.top, body.width, body.height * 0.5),
        topLeft: radius,
        topRight: radius,
      ),
      Paint()..color = const Color(0xFFFFB3C1),
    );
  }

  @override
  bool shouldRepaint(_EraserPainter oldDelegate) => false;
}
