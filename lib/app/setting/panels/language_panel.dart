import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/model/language.entry.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class LanguagePanel extends StatelessWidget {
  const LanguagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final selected =
        context.select<SettingViewModel, String>((s) => s.language);
    final viewModel = context.read<SettingViewModel>();

    final flagSize = context.rs(48);
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(context.rs(11)) * 1.4;

    return SettingPanelScaffold(
      title: 'Language',
      onClose: () => Navigator.of(context).pop(),
      scrollable: false,
      child: GridView.builder(
        padding: EdgeInsets.only(bottom: context.rs(24)),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: context.rs(110),
          crossAxisSpacing: context.rs(6),
          mainAxisSpacing: context.rs(8),
          mainAxisExtent:
              flagSize + context.rs(4) + labelHeight + context.rs(6),
        ),
        itemCount: LanguageEntry.catalog.length,
        itemBuilder: (context, index) {
          final entry = LanguageEntry.catalog[index];
          return _LanguageTile(
            entry: entry,
            selected: entry.code == selected,
            flagSize: flagSize,
            onTap: () => viewModel.setLanguage(entry.code),
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageEntry entry;
  final bool selected;
  final double flagSize;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.entry,
    required this.selected,
    required this.flagSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badge = context.rs(16);

    return Semantics(
      button: true,
      selected: selected,
      label: entry.name,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: flagSize,
                  height: flagSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.purple
                          : const Color(0x00000000),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: ColoredBox(
                      color: const Color(0xFFF0EDF5),
                      child: Center(
                        child: Text(
                          entry.flagEmoji,
                          style: TextStyle(fontSize: context.rs(28)),
                        ),
                      ),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: badge,
                      height: badge,
                      decoration: const BoxDecoration(
                        color: AppColors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.checkmark,
                        size: context.rs(10),
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.rs(4)),
            Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: selected
                  ? AppTypography.boldStyle(
                      fontSize: context.rs(11),
                      color: AppColors.purple,
                    )
                  : AppTypography.semiBoldStyle(
                      fontSize: context.rs(11),
                      color: const Color(0xFF4C4556),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
