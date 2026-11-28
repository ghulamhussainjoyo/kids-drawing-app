import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/button/pill.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/core/ui/button/circle.button.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class LittleArtistAgeScreen extends StatelessWidget {
  const LittleArtistAgeScreen({super.key});

  static const ages = ['0–2', '3–4', '5–6', '7–8', '9–11', '12+'];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF5E8),
      navigationBar: CupertinoNavigationBar(
        middle: Text('How old is ${settings.pronoun}?'),
        backgroundColor: const Color(0xFFFFF5E8),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.rs(24)),
          child: Column(
            children: [
              SizedBox(height: context.rs(32)),
              Wrap(
                spacing: context.rs(12),
                runSpacing: context.rs(12),
                alignment: WrapAlignment.center,
                children: [
                  for (final age in ages)
                    CircleButton(
                      size: context.rs(56),
                      responsive: false,
                      color: settings.ageRange == age
                          ? AppColors.purple
                          : const Color(0xFFFFFFFF),
                      onPressed: () => settings.setAgeRange(age),
                      image: Text(
                        age,
                        style: AppTypography.numericStyle(
                          fontSize: context.rs(13),
                          color: settings.ageRange == age
                              ? const Color(0xFFFFFFFF)
                              : const Color(0xFF6B6275),
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: PillButton(
                  label: 'CONTINUE',
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
