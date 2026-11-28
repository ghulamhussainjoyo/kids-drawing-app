import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/model/interest.option.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/interest.tile.dart';
import 'package:kids_drawing_flutter/core/ui/button/pill.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class LittleArtistInterestsScreen extends StatelessWidget {
  const LittleArtistInterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingViewModel>();
    final pronoun = settings.t('little_artist.pronoun_${settings.pronoun}');

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF5E8),
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          settings.tf('little_artist.what_loves', {'pronoun': pronoun}),
        ),
        backgroundColor: const Color(0xFFFFF5E8),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.rs(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.rs(16)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final option in InterestOption.catalog)
                      InterestTile(
                        id: option.id,
                        label: settings.t(option.labelKey),
                        svgPath: option.svgPath,
                        imagePath: option.imagePath,
                        isSelected: settings.interests.contains(option.id),
                        onTap: () => settings.toggleInterest(option.id),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: settings.t('little_artist.continue'),
                  color: AppColors.purple,
                  fontSize: context.rs(16),
                  radius: context.rs(28),
                  sound: PressSound.exit,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(height: context.rs(12)),
            ],
          ),
        ),
      ),
    );
  }
}
