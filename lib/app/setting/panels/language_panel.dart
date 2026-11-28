import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/language.learning.card.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.entity.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

/// Derives a flag emoji from a two-letter country code embedded in the
/// language code. Falls back to a globe for codes that don't map cleanly.
String _flagForCode(String code) {
  const codeToFlag = {
    'ar': '🇸🇦',
    'az': '🇦🇿',
    'be': '🇧🇾',
    'bg': '🇧🇬',
    'bs': '🇧🇦',
    'ca': '🇪🇸',
    'cs': '🇨🇿',
    'da': '🇩🇰',
    'de': '🇩🇪',
    'el': '🇬🇷',
    'en': '🇺🇸',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'hi': '🇮🇳',
    'id': '🇮🇩',
    'it': '🇮🇹',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
    'ms': '🇲🇾',
    'nl': '🇳🇱',
    'pl': '🇵🇱',
    'pt': '🇧🇷',
    'ro': '🇷🇴',
    'ru': '🇷🇺',
    'sv': '🇸🇪',
    'th': '🇹🇭',
    'tr': '🇹🇷',
    'uk': '🇺🇦',
    'ur': '🇵🇰',
    'vi': '🇻🇳',
    'zh': '🇨🇳',
  };
  final base = code.toLowerCase().split(RegExp('[-_]')).first;
  return codeToFlag[base] ?? '🌍';
}

class LanguagePanel extends StatelessWidget {
  const LanguagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingViewModel>();
    final selected = viewModel.language;
    final syncProgress = viewModel.languageSyncProgress;
    final syncLangName = viewModel.syncingLanguageName;
    final languages = viewModel.availableLanguages;

    final flagSize = context.rs(48);
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(context.rs(11)) * 2.0;

    return SettingPanelScaffold(
      title: viewModel.t('language.title'),
      onClose: () => Navigator.of(context).pop(),
      scrollable: false,
      child: syncProgress != null
          ? Center(
              child: LanguageLearningCard(
                languageName: syncLangName ?? '',
                progress: syncProgress,
                onDismiss: () => viewModel.dismissLanguageSync(),
              ),
            )
          : languages.isEmpty
          ? _buildFallbackGrid(
              context,
              selected,
              viewModel,
              flagSize,
              labelHeight,
            )
          : _buildGrid(
              context,
              languages,
              selected,
              viewModel,
              flagSize,
              labelHeight,
            ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<LanguageEntity> languages,
    String selected,
    SettingViewModel viewModel,
    double flagSize,
    double labelHeight,
  ) {
    return GridView.builder(
      padding: EdgeInsets.only(bottom: context.rs(24)),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: context.rs(110),
        crossAxisSpacing: context.rs(6),
        mainAxisSpacing: context.rs(8),
        mainAxisExtent: flagSize + context.rs(4) + labelHeight + context.rs(6),
      ),
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final lang = languages[index];
        final base = lang.code.toLowerCase().split(RegExp('[-_]')).first;
        final selectedBase = selected.toLowerCase().split(RegExp('[-_]')).first;
        return _LanguageTile(
          code: lang.code,
          name: lang.nativeName,
          flagEmoji: _flagForCode(lang.code),
          selected: base == selectedBase,
          flagSize: flagSize,
          onTap: () => viewModel.setLanguage(lang.code),
        );
      },
    );
  }

  /// Fallback when no languages have been synced yet — shows just English.
  Widget _buildFallbackGrid(
    BuildContext context,
    String selected,
    SettingViewModel viewModel,
    double flagSize,
    double labelHeight,
  ) {
    return Center(
      child: _LanguageTile(
        code: 'en',
        name: viewModel.t('language.english_fallback'),
        flagEmoji: '🇺🇸',
        selected: true,
        flagSize: flagSize,
        onTap: () {},
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String name;
  final String flagEmoji;
  final bool selected;
  final double flagSize;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.name,
    required this.flagEmoji,
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
      label: name,
      child: PressButton(
        onPressed: onTap,
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
                          flagEmoji,
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
              name,
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
