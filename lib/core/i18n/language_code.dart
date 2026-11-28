abstract final class LanguageCode {
  static const fallback = 'en';
  static String base(String code) {
    final lower = code.toLowerCase();
    final parts = lower.split(RegExp('[-_]'));
    if (parts.isEmpty) return fallback;
    final head = parts.first;
    if (head.isEmpty) return fallback;
    return head;
  }
}
