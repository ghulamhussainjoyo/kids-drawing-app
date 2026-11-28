import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.colors.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/core/ui/button/circle.button.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

/// Fixed header (title + close) and scrollable or flex body for settings panels.
class SettingPanelScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  /// false → child gets Expanded (e.g. GridView).
  final bool scrollable;

  const SettingPanelScaffold({
    super.key,
    required this.title,
    required this.onClose,
    required this.child,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final headerPadding = EdgeInsets.symmetric(
      horizontal: context.rs(16),
      vertical: context.rs(8),
    );
    final bodyPadding = EdgeInsets.symmetric(
      horizontal: context.rs(16),
      vertical: context.rs(20),
    );

    final header = Padding(
      padding: headerPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.boldStyle(
                fontSize: context.rs(22),
                color: SettingColors.title,
              ),
            ),
          ),
          CircleButton(
            size: 20,
            responsive: false,
            onPressed: onClose,
            sound: PressSound.exit,
            color: AppColors.purple,
            image: const Icon(
              CupertinoIcons.xmark,
              color: Color(0xFFFFFFFF),
              size: 14,
            ),
          ),
        ],
      ),
    );

    Widget body;
    if (scrollable) {
      body = SingleChildScrollView(padding: bodyPadding, child: child);
    } else {
      body = Padding(padding: bodyPadding, child: child);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        Expanded(child: body),
      ],
    );
  }
}
