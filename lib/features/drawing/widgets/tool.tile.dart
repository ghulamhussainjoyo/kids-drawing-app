import 'package:flutter/material.dart';

import '../../../data/models/brush.type.dart';
import 'tool.glyph.dart';

/// Colored rounded tile with the tool's icon.
class ToolTile extends StatelessWidget {
  const ToolTile({super.key, required this.type, required this.size});

  final BrushType type;
  final double size;

  static Color tileColor(BrushType type) => switch (type) {
        BrushType.bucket => const Color(0xFF4A7BF7),
        BrushType.crayon => const Color(0xFFFFD43B),
        BrushType.paintbrush => const Color(0xFF2EC4B6),
        BrushType.wand => const Color(0xFFE84FD1),
        BrushType.pencil => const Color(0xFF9B4DFF),
        BrushType.marker => const Color(0xFF35C45A),
        BrushType.eraser => const Color(0xFF8EC9FF),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tileColor(type),
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: [
          BoxShadow(
            color: Color.lerp(tileColor(type), Colors.black, 0.3)!,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ToolGlyph(type: type, size: size * 0.66),
    );
  }
}
