import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:kids_drawing_flutter/app/setting/model/setting_section.dart';
import 'package:kids_drawing_flutter/app/setting/panels/about_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/help_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/language_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/little_artist_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/music_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/sounds_voice_panel.dart';
import 'package:kids_drawing_flutter/app/setting/panels/subscription_panel.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.nav.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_glass_shell.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog({super.key});

  @override
  State<SettingDialog> createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog> {
  static const double _maxDialogWidth = 960;
  SettingSection _active = SettingSection.littleArtist;

  Widget _buildDetail(SettingSection section) => switch (section) {
    SettingSection.littleArtist => const LittleArtistPanel(),
    SettingSection.music => const MusicPanel(),
    SettingSection.soundsVoice => const SoundsVoicePanel(),
    SettingSection.language => const LanguagePanel(),
    SettingSection.subscription => const SubscriptionPanel(),
    SettingSection.help => const HelpPanel(),
    SettingSection.about => const AboutPanel(),
  };

  /// Size from SafeArea LayoutBuilder constraints (not full-screen MediaQuery).
  Size _dialogSize(BoxConstraints constraints) {
    final isAndroid = TargetPlatform.android;
    final factor = defaultTargetPlatform == isAndroid ? 0.85 : 0.90;
    return Size(
      math.min(constraints.maxWidth * factor, _maxDialogWidth),
      constraints.maxHeight * factor,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Expand so LayoutBuilder sees the full dialog overlay, then SafeArea.
    return SizedBox.expand(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = _dialogSize(constraints);
            final navWidth = (size.width * 0.36).clamp(
              context.rs(180),
              context.rs(300),
            );

            return Center(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: SettingGlassShell(
                  child: Row(
                    children: [
                      SizedBox(
                        width: navWidth.toDouble(),
                        child: SettingNav(
                          active: _active,
                          onSelect: (section) =>
                              setState(() => _active = section),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: context.rs(8)),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: SizedBox.expand(
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
            );
          },
        ),
      ),
    );
  }
}
