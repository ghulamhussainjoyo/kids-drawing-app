import 'package:flutter/material.dart';

import '../../../core/ui/theme/app.colors.dart';

/// Circular action button. Disabled buttons turn grey and ignore taps.
class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.size,
    this.onPressed,
    this.color = AppColors.purple,
  });

  final IconData icon;
  final String label;
  final double size;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fill = enabled ? color : AppColors.disabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color.lerp(fill, Colors.black, 0.28)!,
                offset: Offset(0, size * 0.05),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}
