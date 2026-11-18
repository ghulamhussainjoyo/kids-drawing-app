class LanguageEntry {
  final String code;
  final String name;
  final String flagEmoji;

  const LanguageEntry({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });

  static const List<LanguageEntry> catalog = [
    LanguageEntry(code: 'ar', name: 'العربية', flagEmoji: '🇸🇦'),
    LanguageEntry(code: 'az', name: 'Azərbaycan', flagEmoji: '🇦🇿'),
    LanguageEntry(code: 'be', name: 'Беларуская', flagEmoji: '🇧🇾'),
    LanguageEntry(code: 'bg', name: 'Български', flagEmoji: '🇧🇬'),
    LanguageEntry(code: 'bs', name: 'Bosanski', flagEmoji: '🇧🇦'),
    LanguageEntry(code: 'ca', name: 'Català', flagEmoji: '🇪🇸'),
    LanguageEntry(code: 'cs', name: 'Čeština', flagEmoji: '🇨🇿'),
    LanguageEntry(code: 'da', name: 'Dansk', flagEmoji: '🇩🇰'),
    LanguageEntry(code: 'de', name: 'Deutsch', flagEmoji: '🇩🇪'),
    LanguageEntry(code: 'el', name: 'Ελληνικά', flagEmoji: '🇬🇷'),
    LanguageEntry(code: 'en_US', name: 'English (US)', flagEmoji: '🇺🇸'),
    LanguageEntry(code: 'en_AU', name: 'English (AU)', flagEmoji: '🇦🇺'),
    LanguageEntry(code: 'en_GB', name: 'English (UK)', flagEmoji: '🇬🇧'),
    LanguageEntry(code: 'es', name: 'Español', flagEmoji: '🇪🇸'),
    LanguageEntry(code: 'fr', name: 'Français', flagEmoji: '🇫🇷'),
    LanguageEntry(code: 'ur', name: 'اردو', flagEmoji: '🇵🇰'),
  ];
}
