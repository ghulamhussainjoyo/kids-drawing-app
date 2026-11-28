import 'package:flutter/foundation.dart';
import 'package:kids_drawing_flutter/core/i18n/app_locals.defaults.dart';
import 'package:kids_drawing_flutter/core/i18n/language_code.dart';
import 'package:kids_drawing_flutter/data/local/floor/dao/app_local.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/entity/app_local.entity.dart';
import 'package:kids_drawing_flutter/data/repositories/locals/app_locals.repository.dart';

class FloorAppLocalsRepository implements AppLocalsRepository {
  FloorAppLocalsRepository(this._dao);

  final AppLocalDao _dao;

  Map<String, String> _forLanguage = {};
  Map<String, String> _forEnglish = {};

  @override
  Future<void> warmForLanguage(String languageCode) async {
    final lang = LanguageCode.base(languageCode);
    _forLanguage = await _loadMap(lang);
    debugPrint('[LOCALS] warm($languageCode→$lang): ${_forLanguage.length} rows');
    if (lang == LanguageCode.fallback) {
      _forEnglish = _forLanguage;
      return;
    }
    _forEnglish = await _loadMap(LanguageCode.fallback);
    debugPrint('[LOCALS] english fallback: ${_forEnglish.length} rows');
  }

  @override
  String resolve(String key, String languageCode) {
    final active = _forLanguage[key];
    if (active != null && active.isNotEmpty) return active;

    final english = _forEnglish[key];
    if (english != null && english.isNotEmpty) return english;

    final bundled = AppLocalsDefaults.get(key);
    if (bundled != null) return bundled;

    return key;
  }

  @override
  String resolveFormatted(
    String key,
    String languageCode,
    Map<String, String> tokens,
  ) {
    var text = resolve(key, languageCode);
    for (final entry in tokens.entries) {
      text = text.replaceAll('{${entry.key}}', entry.value);
    }
    return text;
  }

  Future<Map<String, String>> _loadMap(String languageCode) async {
    final rows = await _dao.allForLanguage(languageCode);
    final map = <String, String>{};
    for (final AppLocalEntity row in rows) {
      map[row.key] = row.value;
    }
    return map;
  }
}
