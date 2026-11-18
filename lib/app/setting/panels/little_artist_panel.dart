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

  static const _genderLabels = {'girl': 'Girl', 'boy': 'Boy'};

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (gender, ageRange, pronoun, interestCount) =
        context.select<SettingViewModel, (String, String, String, int)>(
      (s) => (s.gender, s.ageRange, s.pronoun, s.interests.length),
    );

    return SettingPanelScaffold(
      title: 'Little Artist',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          LittleArtistHubRow(
            title: "Who's the little artist?",
            subtitle: _genderLabels[gender] ?? 'Siblings',
            onTap: () => _open(context, const LittleArtistGenderScreen()),
          ),
          LittleArtistHubRow(
            title: 'How old is $pronoun?',
            subtitle: ageRange,
            onTap: () => _open(context, const LittleArtistAgeScreen()),
          ),
          LittleArtistHubRow(
            title: 'What does $pronoun love?',
            subtitle: interestCount == 0
                ? 'Tap to choose'
                : '$interestCount selected',
            onTap: () => _open(context, const LittleArtistInterestsScreen()),
          ),
        ],
      ),
    );
  }
}
