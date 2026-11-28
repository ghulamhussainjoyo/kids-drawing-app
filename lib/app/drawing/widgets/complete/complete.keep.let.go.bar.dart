import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/button/pill.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

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
          Builder(
            builder: (context) {
              final vm = context.read<SettingViewModel>();
              return PillButton(
                label: vm.t('drawing.keep'),
                color: AppColors.done,
                onPressed: onKeep,
              );
            },
          ),
          const SizedBox(width: 16),
          Builder(
            builder: (context) {
              final vm = context.read<SettingViewModel>();
              return PillButton(
                label: vm.t('drawing.let_go'),
                color: AppColors.coral,
                sound: PressSound.exit,
                onPressed: onLetGo,
              );
            },
          ),
        ],
      ),
    );
  }
}
