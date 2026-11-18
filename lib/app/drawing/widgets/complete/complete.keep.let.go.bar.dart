import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';

/// Compact Keep / Let go row that replaces the action icons.
class CompleteKeepLetGoBar extends StatelessWidget {
  final VoidCallback onKeep;
  final VoidCallback onLetGo;

  const CompleteKeepLetGoBar({
    super.key,
    required this.onKeep,
    required this.onLetGo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Pill(label: 'Keep', color: AppColors.done, onPressed: onKeep),
          const SizedBox(width: 16),
          _Pill(label: 'Let go', color: AppColors.coral, onPressed: onLetGo),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _Pill({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      color: color,
      borderRadius: BorderRadius.circular(24),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.boldStyle(
          color: CupertinoColors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
