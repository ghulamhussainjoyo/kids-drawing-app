import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/model/setting_section.dart';
import 'package:kids_drawing_flutter/app/setting/panels/about_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/help_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/language_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/little_artist_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/music_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/sounds_voice_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/subscription_panel.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_glass_shell.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_nav_item.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/spiral_divider.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({super.key});

  @override
  State<SettingDialog> createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  SettingSection _active = SettingSection.littleArtist;

  Widget _buildDetail(SettingSection section) {
    switch (section) {
      case SettingSection.littleArtist:
        return const LittleArtistPanel();
      case SettingSection.music:
        return const MusicPanel();
      case SettingSection.soundsVoice:
        return const SoundsVoicePanel();
      case SettingSection.language:
        return const LanguagePanel();
      case SettingSection.subscription:
        return const SubscriptionPanel();
      case SettingSection.help:
        return const HelpPanel();
      case SettingSection.about:
        return const AboutPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final safe = MediaQuery.paddingOf(context);
    final availableWidth = screenSize.width - safe.left - safe.right;
    final availableHeight = screenSize.height - safe.top - safe.bottom;
    final dialogWidth = availableWidth * 0.90;
    final dialogHeight = availableHeight * 0.95;
    final leftNavWidth = dialogWidth * 0.28;

    return SafeArea(
      child: Center(
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: SettingGlassShell(
            onClose: () => Navigator.of(context).pop(),
            child: Row(
            children: [
              SizedBox(
                width: leftNavWidth,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 14,
                    bottom: 12,
                    left: 12,
                    right: 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 10, bottom: 8),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF221A30),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.person_fill,
                                  color: Color(0xFFF43F5E),
                                  size: 19,
                                ),
                                label: 'Little Artist',
                                isSelected:
                                    _active == SettingSection.littleArtist,
                                onTap: () => setState(
                                  () => _active = SettingSection.littleArtist,
                                ),
                              ),
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.music_note_2,
                                  color: Color(0xFF10B981),
                                  size: 19,
                                ),
                                label: 'Music',
                                isSelected: _active == SettingSection.music,
                                onTap: () => setState(
                                  () => _active = SettingSection.music,
                                ),
                              ),
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.volume_up,
                                  color: Color(0xFFF43F5E),
                                  size: 19,
                                ),
                                label: 'Sounds & Voice',
                                isSelected:
                                    _active == SettingSection.soundsVoice,
                                onTap: () => setState(
                                  () => _active = SettingSection.soundsVoice,
                                ),
                              ),
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.globe,
                                  color: Color(0xFF3B82F6),
                                  size: 19,
                                ),
                                label: 'Language',
                                isSelected: _active == SettingSection.language,
                                onTap: () => setState(
                                  () => _active = SettingSection.language,
                                ),
                              ),
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.ticket_fill,
                                  color: Color(0xFF3B82F6),
                                  size: 19,
                                ),
                                label: 'Subscription',
                                isSelected:
                                    _active == SettingSection.subscription,
                                onTap: () => setState(
                                  () => _active = SettingSection.subscription,
                                ),
                              ),
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.question_circle_fill,
                                  color: Color(0xFF7B35E0),
                                  size: 19,
                                ),
                                label: 'Help',
                                isSelected: _active == SettingSection.help,
                                onTap: () => setState(
                                  () => _active = SettingSection.help,
                                ),
                              ),
                              SettingNavItem(
                                icon: const Icon(
                                  CupertinoIcons.shield_fill,
                                  color: Color(0xFF6B7280),
                                  size: 19,
                                ),
                                label: 'About',
                                isSelected: _active == SettingSection.about,
                                onTap: () => setState(
                                  () => _active = SettingSection.about,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SpiralDivider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: KeyedSubtree(
                      key: ValueKey(_active),
                      child: _buildDetail(_active),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
