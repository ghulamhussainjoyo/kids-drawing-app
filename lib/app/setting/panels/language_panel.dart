import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/storage/settings.repository.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:provider/provider.dart';

class LanguageEntry {
  final String code;
  final String name;
  final String flagEmoji;
  final List<Color> colors;

  const LanguageEntry({
    required this.code,
    required this.name,
    required this.flagEmoji,
    required this.colors,
  });
}

class LanguagePanel extends StatelessWidget {
  const LanguagePanel({super.key});

  static const List<LanguageEntry> languages = [
    LanguageEntry(
      code: 'ar',
      name: 'العربية',
      flagEmoji: '🇸🇦',
      colors: [Color(0xFF007A3D), Color(0xFF00562B)],
    ),
    LanguageEntry(
      code: 'az',
      name: 'Azərbaycan',
      flagEmoji: '🇦🇿',
      colors: [Color(0xFF0092BC), Color(0xFFE03A3E), Color(0xFF00B050)],
    ),
    LanguageEntry(
      code: 'be',
      name: 'Беларуская',
      flagEmoji: '🇧🇾',
      colors: [Color(0xFFC8102E), Color(0xFF43B02A)],
    ),
    LanguageEntry(
      code: 'bg',
      name: 'Български',
      flagEmoji: '🇧🇬',
      colors: [Color(0xFFFFFFFF), Color(0xFF00966E), Color(0xFFD62612)],
    ),
    LanguageEntry(
      code: 'bs',
      name: 'Bosanski',
      flagEmoji: '🇧🇦',
      colors: [Color(0xFF002366), Color(0xFFFECB00)],
    ),
    LanguageEntry(
      code: 'ca',
      name: 'Català',
      flagEmoji: '🇪🇸',
      colors: [Color(0xFFF1BF00), Color(0xFFDA121A)],
    ),
    LanguageEntry(
      code: 'cs',
      name: 'Čeština',
      flagEmoji: '🇨🇿',
      colors: [Color(0xFF11457E), Color(0xFFD7141A)],
    ),
    LanguageEntry(
      code: 'da',
      name: 'Dansk',
      flagEmoji: '🇩🇰',
      colors: [Color(0xFFC8102E), Color(0xFFFFFFFF)],
    ),
    LanguageEntry(
      code: 'de',
      name: 'Deutsch',
      flagEmoji: '🇩🇪',
      colors: [Color(0xFF000000), Color(0xFFFF0000), Color(0xFFFFCC00)],
    ),
    LanguageEntry(
      code: 'el',
      name: 'Ελληνικά',
      flagEmoji: '🇬🇷',
      colors: [Color(0xFF0D5EAF), Color(0xFFFFFFFF)],
    ),
    LanguageEntry(
      code: 'en_US',
      name: 'English (US)',
      flagEmoji: '🇺🇸',
      colors: [Color(0xFFB22234), Color(0xFF3C3B6E)],
    ),
    LanguageEntry(
      code: 'en_AU',
      name: 'English (AU)',
      flagEmoji: '🇦🇺',
      colors: [Color(0xFF00008B), Color(0xFFFF0000)],
    ),
    LanguageEntry(
      code: 'en_GB',
      name: 'English (UK)',
      flagEmoji: '🇬🇧',
      colors: [Color(0xFF012169), Color(0xFFC8102E)],
    ),
    LanguageEntry(
      code: 'es',
      name: 'Español',
      flagEmoji: '🇪🇸',
      colors: [Color(0xFFAA151B), Color(0xFFF1BF00)],
    ),
    LanguageEntry(
      code: 'fr',
      name: 'Français',
      flagEmoji: '🇫🇷',
      colors: [Color(0xFF002395), Color(0xFFFFFFFF), Color(0xFFED2939)],
    ),
    LanguageEntry(
      code: 'ur',
      name: 'اردو',
      flagEmoji: '🇵🇰',
      colors: [Color(0xFF01411C), Color(0xFFFFFFFF)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsRepository>();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Language',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final item = languages[index];
                final isSelected = settings.language == item.code;

                return GestureDetector(
                  onTap: () => settings.setLanguage(item.code),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.purple
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: ColoredBox(
                                color: const Color(0xFFF0EDF5),
                                child: Center(
                                  child: Text(
                                    item.flagEmoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: AppColors.purple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.checkmark,
                                  size: 11,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.purple
                              : const Color(0xFF4C4556),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
