import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/circle.button.dart';

/// Purple toggle: section clip on vs free paint.
class ClipModeButton extends StatelessWidget {
  final bool clipToRegions;
  final VoidCallback onPressed;

  const ClipModeButton({
    super.key,
    required this.clipToRegions,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    if (clipToRegions) {
      icon = CupertinoIcons.square_on_square;
    } else {
      icon = CupertinoIcons.pencil_outline;
    }
    return CircleButton(
      size: 48,
      color: AppColors.purple,
      onPressed: onPressed,
      image: Icon(icon, color: const Color(0xFFFFFFFF)),
    );
  }
}
