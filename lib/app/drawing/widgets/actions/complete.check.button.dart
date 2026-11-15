import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/circle.button.dart';

/// Green check that opens the complete screen when the page has paint.
class CompleteCheckButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const CompleteCheckButton({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(width: 52, height: 52);
    }
    return CircleButton(
      size: 48,
      color: AppColors.done,
      onPressed: onPressed,
      image: const Icon(CupertinoIcons.check_mark, color: Color(0xFFFFFFFF)),
    );
  }
}
