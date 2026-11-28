abstract class AppLocalsRepository {
  Future<void> warmForLanguage(String languageCode);
  String resolve(String key, String languageCode);

  String resolveFormatted(
    String key,
    String languageCode,
    Map<String, String> tokens,
  );
}
