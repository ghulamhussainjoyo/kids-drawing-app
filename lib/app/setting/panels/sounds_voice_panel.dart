import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_toggle_row.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class SoundsVoicePanel extends StatelessWidget {
  const SoundsVoicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final (voice, sfx, vibration) =
        context.select<SettingViewModel, (bool, bool, bool)>(
      (s) => (s.voiceOn, s.sfxOn, s.vibrationOn),
    );
    final viewModel = context.read<SettingViewModel>();

    return SettingPanelScaffold(
      title: 'Sounds & Voice',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          SettingToggleRow(
            icon: Icon(
              CupertinoIcons.person_crop_circle_badge_checkmark,
              color: const Color(0xFFEC4899),
              size: context.rs(22),
            ),
            title: 'Voice',
            value: voice,
            onChanged: viewModel.setVoiceOn,
          ),
          SettingToggleRow(
            icon: Icon(
              CupertinoIcons.volume_up,
              color: const Color(0xFF3B82F6),
              size: context.rs(22),
            ),
            title: 'Sound Effects',
            value: sfx,
            onChanged: viewModel.setSfxOn,
          ),
          SettingToggleRow(
            icon: Icon(
              CupertinoIcons.waveform,
              color: const Color(0xFFF43F5E),
              size: context.rs(22),
            ),
            title: 'Vibrations',
            value: vibration,
            onChanged: viewModel.setVibrationOn,
          ),
        ],
      ),
    );
  }
}
