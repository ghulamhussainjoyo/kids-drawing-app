import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_toggle_row.dart';
import 'package:kids_drawing_flutter/core/storage/settings.repository.dart';
import 'package:provider/provider.dart';

class SoundsVoicePanel extends StatelessWidget {
  const SoundsVoicePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsRepository>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sounds & Voice',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          const SizedBox(height: 18),

          SettingToggleRow(
            icon: const Icon(
              CupertinoIcons.person_crop_circle_badge_checkmark,
              color: Color(0xFFEC4899),
              size: 24,
            ),
            title: 'Voice',
            description: 'Enables friendly voice narration, word guidance, and cheerful encouragement.',
            value: settings.voiceOn,
            onChanged: (v) => settings.setVoiceOn(v),
          ),
          const ColoredBox(
            color: Color(0x20000000),
            child: SizedBox(height: 1, width: double.infinity),
          ),

          SettingToggleRow(
            icon: const Icon(
              CupertinoIcons.volume_up,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
            title: 'Sound Effects',
            description: 'Plays delightful interactive sounds while tapping, brushing, and coloring.',
            value: settings.sfxOn,
            onChanged: (v) => settings.setSfxOn(v),
          ),
          const ColoredBox(
            color: Color(0x20000000),
            child: SizedBox(height: 1, width: double.infinity),
          ),

          SettingToggleRow(
            icon: const Icon(
              CupertinoIcons.waveform,
              color: Color(0xFFF43F5E),
              size: 24,
            ),
            title: 'Vibrations',
            description: 'Provides gentle haptic feedback on compatible devices when drawing and tapping.',
            value: settings.vibrationOn,
            onChanged: (v) => settings.setVibrationOn(v),
          ),
        ],
      ),
    );
  }
}
