import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/model/setting_section.dart';

extension SettingSectionX on SettingSection {
  String get labelKey => switch (this) {
    SettingSection.littleArtist => 'settings.little_artist',
    SettingSection.music => 'settings.music',
    SettingSection.soundsVoice => 'settings.sounds_voice',
    SettingSection.language => 'settings.language',
    SettingSection.subscription => 'settings.subscription',
    SettingSection.help => 'settings.help',
    SettingSection.about => 'settings.about',
  };

  IconData get icon => switch (this) {
    SettingSection.littleArtist => CupertinoIcons.person_fill,
    SettingSection.music => CupertinoIcons.music_note_2,
    SettingSection.soundsVoice => CupertinoIcons.volume_up,
    SettingSection.language => CupertinoIcons.globe,
    SettingSection.subscription => CupertinoIcons.ticket_fill,
    SettingSection.help => CupertinoIcons.question_circle_fill,
    SettingSection.about => CupertinoIcons.shield_fill,
  };

  Color get color => switch (this) {
    SettingSection.littleArtist => const Color(0xFFF43F5E),
    SettingSection.music => const Color(0xFF10B981),
    SettingSection.soundsVoice => const Color(0xFFF43F5E),
    SettingSection.language => const Color(0xFF3B82F6),
    SettingSection.subscription => const Color(0xFF3B82F6),
    SettingSection.help => const Color(0xFF7B35E0),
    SettingSection.about => const Color(0xFF6B7280),
  };
}
