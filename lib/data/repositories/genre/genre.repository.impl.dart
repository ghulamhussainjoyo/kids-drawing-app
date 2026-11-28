import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:kids_drawing_flutter/core/i18n/language_code.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/translation.dao.dart';
import 'package:kids_drawing_flutter/data/repositories/genre/genre.repository.dart';
import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

class FloorGenreRepository implements GenreRepository {
  final GenreDao genreDao;
  final TranslationDao translationDao;

  FloorGenreRepository({required this.genreDao, required this.translationDao});

  @override
  Future<List<GenreModel>> getGenres(String language) async {
    final lang = LanguageCode.base(language);
    final entities = await genreDao.listPublished();
    final models = <GenreModel>[];
    for (final entity in entities) {
      models.add(await _assemble(entity, lang));
    }
    return models;
  }

  @override
  Future<GenreModel?> getBySlug(String slug, String language) async {
    final lang = LanguageCode.base(language);
    final entity = await genreDao.findBySlug(slug);
    if (entity == null) return null;
    return _assemble(entity, lang);
  }

  Future<GenreModel> _assemble(GenreEntity entity, String lang) async {
    final title = await _resolveTitle(entity.slug, lang);
    final voicePool = await _resolveVoicePool(entity.slug, lang);
    final fillColors = _parseColors(entity.titleFillColors);
    final outlineColor = _parseColor(entity.titleOutlineColor);
    final ambience = _parseStringList(entity.ambience);

    final imagePath = _resolveImage(entity);

    return GenreModel(
      id: entity.slug,
      name: title,
      assetImage: imagePath.assetImage,
      fileImage: imagePath.fileImage,
      titleFillColors: fillColors,
      titleOutlineColor: outlineColor,
      voice: voicePool,
      ambience: ambience,
    );
  }

  Future<String> _resolveTitle(String slug, String lang) async {
    final row = await translationDao.genreTitle(slug, lang);
    if (row != null) return row.text;

    if (lang != LanguageCode.fallback) {
      final fallback = await translationDao.genreTitle(
        slug,
        LanguageCode.fallback,
      );
      if (fallback != null) return fallback.text;
    }

    return _slugToTitle(slug);
  }

  Future<List<String>> _resolveVoicePool(String slug, String lang) async {
    final rows = await translationDao.genreVoicePool(slug, lang);
    debugPrint('[Voice] genre=$slug lang=$lang found=${rows.length}');
    if (rows.isNotEmpty) return rows.map((r) => r.text).toList();

    if (lang != LanguageCode.fallback) {
      final fallback = await translationDao.genreVoicePool(
        slug,
        LanguageCode.fallback,
      );
      debugPrint('[Voice] genre=$slug fallback=en found=${fallback.length}');
      if (fallback.isNotEmpty) return fallback.map((r) => r.text).toList();
    }

    return [];
  }

  _ImagePaths _resolveImage(GenreEntity entity) {
    if (entity.localImagePath != null &&
        File(entity.localImagePath!).existsSync()) {
      return _ImagePaths(fileImage: entity.localImagePath);
    }

    final fallbackAsset = _genreAssetFallback(entity.slug);
    return _ImagePaths(assetImage: fallbackAsset);
  }

  static String? _genreAssetFallback(String slug) {
    const knownSlugs = {
      'coloring-arts',
      'school',
      'animals',
      'music',
      'transport',
      'seasons',
      'princes',
      'fruit-garden',
    };
    if (knownSlugs.contains(slug)) {
      if (slug == 'fruit-garden') return 'assets/gallery/fruit- garden.png';
      return 'assets/gallery/$slug.png';
    }
    return null;
  }

  static List<Color> _parseColors(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.map((hex) => _parseColor(hex.toString())).toList();
    } catch (_) {
      return [const Color(0xFF888888)];
    }
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF000000);
    var str = hex.replaceAll('#', '');
    if (str.startsWith('0x') || str.startsWith('0X')) str = str.substring(2);
    if (str.length == 6) str = 'FF$str';
    return Color(int.parse(str, radix: 16));
  }

  static List<String> _parseStringList(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    } catch (_) {
      return [];
    }
  }

  static String _slugToTitle(String slug) {
    return slug
        .split('-')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _ImagePaths {
  final String? assetImage;
  final String? fileImage;

  const _ImagePaths({this.assetImage, this.fileImage});
}
