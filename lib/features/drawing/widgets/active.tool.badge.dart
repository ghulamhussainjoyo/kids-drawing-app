import 'package:flutter/material.dart';

import '../../../core/ui/theme/app.colors.dart';
import '../../../data/models/brush.type.dart';
import 'tool.glyph.dart';

/// Shows the active tool in a lavender circle.
class ActiveToolBadge extends StatelessWidget {
  const ActiveToolBadge({super.key, required this.type, required this.size});

  final BrushType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Active tool: ${ToolGlyph.label(type)}',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.lavender,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: ToolGlyph(key: ValueKey(type), type: type, size: size * 0.62),
        ),
      ),
    );
  }
}
