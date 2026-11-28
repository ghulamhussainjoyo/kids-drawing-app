import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/button/pill.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class LittleArtistGenderScreen extends StatelessWidget {
  const LittleArtistGenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingViewModel>();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFF5E8),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Who\'s the little artist?'),
        backgroundColor: Color(0xFFFFF5E8),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.rs(24)),
          child: Column(
            children: [
              SizedBox(height: context.rs(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _GenderChoice(
                    label: 'Girl',
                    isSelected: settings.gender == 'girl',
                    icon: CupertinoIcons.person_solid,
                    accentColor: const Color(0xFFF59E0B),
                    onTap: () => settings.setGender('girl'),
                  ),
                  _GenderChoice(
                    label: 'Boy',
                    isSelected: settings.gender == 'boy',
                    icon: CupertinoIcons.person_solid,
                    accentColor: const Color(0xFF3B82F6),
                    onTap: () => settings.setGender('boy'),
                  ),
                  _GenderChoice(
                    label: 'Siblings',
                    isSelected: settings.gender == 'siblings',
                    icon: CupertinoIcons.person_2_fill,
                    accentColor: const Color(0xFF10B981),
                    onTap: () => settings.setGender('siblings'),
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

class _GenderChoice extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _GenderChoice({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = context.rs(88);
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFFFFF),
        border: Border.all(
          color: isSelected ? accentColor : const Color(0xFFDCD5E4),
          width: isSelected ? 3.5 : 1.5,
        ),
      ),
      child: Icon(icon, size: context.rs(40), color: accentColor),
    );
    if (!isSelected) {
      avatar = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: avatar,
      );
    }

    return PressButton(
      onPressed: onTap,
      child: Column(
        children: [
          avatar,
          SizedBox(height: context.rs(8)),
          Text(
            label,
            style: isSelected
                ? AppTypography.boldStyle(
                    fontSize: context.rs(14),
                    color: const Color(0xFF221A30),
                  )
                : AppTypography.semiBoldStyle(
                    fontSize: context.rs(14),
                    color: const Color(0xFF746C7E),
                  ),
          ),
        ],
      ),
    );
  }
}
