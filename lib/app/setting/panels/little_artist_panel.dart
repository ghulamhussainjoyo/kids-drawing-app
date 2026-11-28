import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/screen/little.artist.age.screen.dart';
import 'package:kids_drawing_flutter/app/setting/screen/little.artist.gender.screen.dart';
import 'package:kids_drawing_flutter/app/setting/screen/little.artist.interests.screen.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/little.artist.hub.row.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

class LittleArtistPanel extends StatelessWidget {
  const LittleArtistPanel({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(CupertinoPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingViewModel>();
    final pronoun = vm.t('little_artist.pronoun_${vm.pronoun}');
    final interestCount = vm.interests.length;

    String genderLabel(String g) => switch (g) {
      'girl' => vm.t('little_artist.girl'),
      'boy' => vm.t('little_artist.boy'),
      _ => vm.t('little_artist.siblings'),
    };

    return SettingPanelScaffold(
      title: vm.t('little_artist.title'),
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          LittleArtistHubRow(
            title: vm.t('little_artist.who'),
            subtitle: genderLabel(vm.gender),
            onTap: () => _open(context, const LittleArtistGenderScreen()),
          ),
          LittleArtistHubRow(
            title: vm.tf('little_artist.how_old', {'pronoun': pronoun}),
            subtitle: vm.ageRange,
            onTap: () => _open(context, const LittleArtistAgeScreen()),
          ),
          LittleArtistHubRow(
            title: vm.tf('little_artist.what_loves', {'pronoun': pronoun}),
            subtitle: interestCount == 0
                ? vm.t('little_artist.tap_to_choose')
                : vm.tf('little_artist.selected_count', {
                    'count': '$interestCount',
                  }),
            onTap: () => _open(context, const LittleArtistInterestsScreen()),
          ),
        ],
      ),
    );
  }
}
