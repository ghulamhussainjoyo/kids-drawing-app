import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class HelpPanel extends StatelessWidget {
  const HelpPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingViewModel>();
    return SettingPanelScaffold(
      title: vm.t('help.title'),
      onClose: () => Navigator.of(context).pop(),
      child: Text(
        vm.t('help.placeholder'),
        style: AppTypography.semiBoldStyle(
          fontSize: context.rs(14),
          color: const Color(0xFF5D5466),
        ),
      ),
    );
  }
}
