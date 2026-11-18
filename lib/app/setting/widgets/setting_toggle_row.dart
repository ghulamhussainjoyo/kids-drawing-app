import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.card.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

/// Option row with switch, using shared SettingCard chrome.
class SettingToggleRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingCard(
      child: Row(
        children: [
          SizedBox(
            width: context.rs(28),
            height: context.rs(28),
            child: Center(child: icon),
          ),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: Text(
              title,
              style: AppTypography.boldStyle(
                fontSize: context.rs(15),
                color: const Color(0xFF433C4F),
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.purple,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
