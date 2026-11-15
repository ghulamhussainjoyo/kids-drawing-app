import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/circle.button.dart';

/// Left (download/share) and right (delete/edit) action groups.
class CompleteActionBar extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CompleteActionBar({
    super.key,
    required this.onDownload,
    required this.onShare,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleButton(
                size: 48,
                color: AppColors.teal,
                onPressed: onDownload,
                image: const Icon(
                  CupertinoIcons.arrow_down_to_line,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 16),
              CircleButton(
                size: 48,
                color: AppColors.teal,
                onPressed: onShare,
                image: const Icon(
                  CupertinoIcons.share,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
          Row(
            children: [
              CircleButton(
                size: 48,
                color: AppColors.coral,
                onPressed: onDelete,
                image: const Icon(
                  CupertinoIcons.trash,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 16),
              CircleButton(
                size: 48,
                color: AppColors.done,
                onPressed: onEdit,
                image: const Icon(
                  CupertinoIcons.pencil,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
