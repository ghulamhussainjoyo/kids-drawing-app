import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.card.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class LittleArtistHubRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const LittleArtistHubRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SettingCard(
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(14),
          vertical: context.rs(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.boldStyle(
                      fontSize: context.rs(15),
                      color: const Color(0xFF433C4F),
                    ),
                  ),
                  SizedBox(height: context.rs(4)),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.semiBoldStyle(
                      fontSize: context.rs(13),
                      color: const Color(0xFF7B7288),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: context.rs(18),
              color: const Color(0xFF9B92A8),
            ),
          ],
        ),
      ),
    );
  }
}
