import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class HelpPanel extends StatelessWidget {
  const HelpPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingPanelScaffold(
      title: 'Help',
      onClose: () => Navigator.of(context).pop(),
      child: Text(
        'Contact us / FAQ links (coming soon)',
        style: AppTypography.semiBoldStyle(
          fontSize: context.rs(14),
          color: const Color(0xFF5D5466),
        ),
      ),
    );
  }
}