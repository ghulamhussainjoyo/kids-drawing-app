import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kids_drawing_flutter/core/i18n/language_code.dart';
import 'package:kids_drawing_flutter/core/storage/local.storage.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/dao/app_local.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/entity/app_local.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/translation.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/translation.entity.dart';
import 'package:kids_drawing_flutter/data/remote/sync.api.dart';
import 'package:path_provider/path_provider.dart';

const _lastSyncKey = 'lastSyncAt';
const _langReadyPrefix = 'lastLangSyncAt:';
const _staleDuration = Duration(hours: 24);

class CatalogSyncService {
  final SyncApi api;
  final String deviceId;
  final GenreDao genreDao;
  final LocalStorage storage;
  final ArtworkDao artworkDao;
  final AppLocalDao appLocalDao;
  final LanguageDao languageDao;
  final TranslationDao translationDao;

  CatalogSyncService({
    required this.api,
    required this.languageDao,
    required this.genreDao,
    required this.artworkDao,
    required this.translationDao,
    required this.appLocalDao,
    required this.storage,
    required this.deviceId,
  });

  /// True when Floor already has at least one genre (remote or seed).
  Future<bool> hasLocalCatalog() async {
    final count = await genreDao.count();
    return (count ?? 0) > 0;
  }

  /// True when the last full sync was more than 24 h ago.
  bool isSyncStale() {
    final raw = storage.getString(_lastSyncKey);
    if (raw == null) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().toUtc().difference(last) > _staleDuration;
  }

  /// True when [code] is fully on the device (translations + voice clips),
  /// so switching to it needs no download. English is always ready.
  bool isLanguageReady(String code) {
    final base = LanguageCode.base(code);
    return base == 'en' || storage.getString('$_langReadyPrefix$base') != null;
  }

  Future<void> _markLanguageReady(String base) {
    return storage.setString(
      '$_langReadyPrefix$base',
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  // ── Full delta sync ──────────────────────────────────────────────────

  /// One RPC call + one languages query. Returns true on success.
  Future<bool> sync({required String language}) async {
    final langBase = LanguageCode.base(language);
    final langs = _uniqueLangs(langBase);

    final synced = await _syncLanguages();
    if (!synced) return false;

    // A language that never finished downloading needs everything, not just
    // what changed since the last sync; this also heals a failed switch.
    final ready = isLanguageReady(langBase);
    final since = ready ? _lastSyncTime() : DateTime.utc(2000);
    final delta = await api.fetchDelta(since, langs);
    if (delta == null) return false;
    debugPrint('[SYNC] delta keys: ${delta.keys.toList()}');

    await _upsertGenres(delta['genres']);
    await _upsertArtworks(delta['artworks']);
    await _upsertTranslations(delta['translations']);
    await _syncAppLocals(langs);
    await _downloadGenreImages();

    final clipsComplete = await _downloadVoiceClips(langBase);
    if (clipsComplete && !ready) {
      await _markLanguageReady(langBase);
    }

    final serverTime = delta['server_time'] as String?;
    if (serverTime != null) {
      await storage.setString(_lastSyncKey, serverTime);
    } else {
      await storage.setString(
        _lastSyncKey,
        DateTime.now().toUtc().toIso8601String(),
      );
    }
    return true;
  }

  // ── Language-only sync (for language switch) ─────────────────────────

  /// Fetches only translations + clips for a new language. Reports progress
  /// through [onProgress] (0.0 → 1.0).
  Future<bool> syncLanguage({
    required String language,
    void Function(double progress)? onProgress,
  }) async {
    final langBase = LanguageCode.base(language);
    onProgress?.call(0.0);

    final delta = await api.fetchDelta(DateTime.utc(2000), [langBase]);
    if (delta == null) return false;

    await _upsertTranslations(delta['translations']);
    await _syncAppLocals([langBase, LanguageCode.fallback]);
    onProgress?.call(0.3);

    final clipsComplete = await _downloadVoiceClips(
      langBase,
      onProgress: (p) {
        onProgress?.call(0.3 + p * 0.7);
      },
    );
    // A missing clip means the language is not ready: leave the marker unset
    // so the next switch (or the daily sync) tries again.
    if (!clipsComplete) return false;

    await _markLanguageReady(langBase);
    onProgress?.call(1.0);
    return true;
  }

  // ── Languages ────────────────────────────────────────────────────────

  Future<bool> _syncLanguages() async {
    final rows = await api.fetchLanguages();
    if (rows == null) return false;
    final entities = rows.map(_mapLanguage).toList();
    await languageDao.upsertAll(entities);
    return true;
  }

  LanguageEntity _mapLanguage(Map<String, dynamic> row) {
    return LanguageEntity(
      code: row['code'] as String,
      englishName: (row['english_name'] ?? row['code']) as String,
      nativeName: (row['native_name'] ?? row['code']) as String,
      direction: (row['direction'] ?? 'ltr') as String,
      isActive: row['is_active'] == true,
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
      remoteUpdatedAt: _epochMillis(row['updated_at']),
    );
  }

  // ── Genres ───────────────────────────────────────────────────────────

  Future<void> _upsertGenres(dynamic raw) async {
    if (raw is! List || raw.isEmpty) return;
    for (final row in raw) {
      final map = row as Map<String, dynamic>;
      final slug = map['slug'] as String;
      final existing = await genreDao.findBySlug(slug);

      final entity = GenreEntity(
        slug: slug,
        localImagePath: existing?.localImagePath,
        remoteImagePath: map['image_path'] as String?,
        titleFillColors: jsonEncode(map['title_fill_colors'] ?? []),
        titleOutlineColor: map['title_outline_color'] as String?,
        ambience: jsonEncode(map['ambience'] ?? []),
        sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
        status: (map['status'] ?? 'published') as String,
        source: 'remote',
        remoteUpdatedAt: _epochMillis(map['updated_at']),
      );
      await genreDao.upsert(entity);
    }
  }

  // ── Artworks ─────────────────────────────────────────────────────────

  Future<void> _upsertArtworks(dynamic raw) async {
    if (raw is! List || raw.isEmpty) return;
    for (final row in raw) {
      final map = row as Map<String, dynamic>;
      final artworkKey = map['slug'] as String;
      final existing = await artworkDao.findByKey(deviceId, artworkKey);
      final tpl = map['template_json'];
      final tplJson = tpl is String ? tpl : jsonEncode(tpl ?? {});

      if (existing != null) {
        await artworkDao.updateArtwork(
          existing.copyWith(
            genre: map['genre_slug'] as String?,
            title: (map['title'] ?? existing.title) as String,
            templateJson: tplJson.isEmpty ? existing.templateJson : tplJson,
            isPremium: map['is_premium'] as bool?,
            sortOrder: (map['sort_order'] as num?)?.toInt(),
            status: map['status'] as String?,
            source: 'remote',
            remoteUpdatedAt: _epochMillis(map['updated_at']),
          ),
        );
      } else {
        await artworkDao.insertArtwork(
          ArtworkEntity(
            deviceId: deviceId,
            artworkKey: artworkKey,
            genre: (map['genre_slug'] ?? '') as String,
            title: (map['title'] ?? artworkKey) as String,
            templateJson: tplJson.isEmpty ? '{}' : tplJson,
            isPremium: map['is_premium'] == true,
            strokesJson: '{}',
            revision: 0,
            dirty: false,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
            status: (map['status'] ?? 'published') as String,
            source: 'remote',
            remoteUpdatedAt: _epochMillis(map['updated_at']),
          ),
        );
      }
    }
  }

  // ── Translations ─────────────────────────────────────────────────────

  Future<void> _upsertTranslations(dynamic raw) async {
    if (raw is! List || raw.isEmpty) return;
    final entities = raw.map((row) {
      final map = row as Map<String, dynamic>;
      return TranslationEntity(
        id: map['id'] as String,
        genreSlug: map['genre_slug'] as String?,
        artworkSlug: map['artwork_slug'] as String?,
        languageCode: map['language_code'] as String,
        field: map['field'] as String,
        position: (map['position'] as num?)?.toInt() ?? 0,
        text: (map['text'] ?? '') as String,
        audioPath: map['audio_path'] as String?,
        audioSha256: map['audio_sha256'] as String?,
        remoteUpdatedAt: _epochMillis(map['updated_at']),
      );
    }).toList();
    await translationDao.upsertAll(entities);
  }

  // ── File downloads ───────────────────────────────────────────────────

  Future<void> _downloadGenreImages() async {
    final genres = await genreDao.listPublished();
    final dir = await _catalogDir('genre-images');

    for (final genre in genres) {
      final remote = genre.remoteImagePath;
      if (remote == null || remote.isEmpty) continue;
      if (genre.localImagePath != null &&
          File(genre.localImagePath!).existsSync()) {
        continue;
      }

      final bytes = await api.downloadFile('genre-images', remote);
      if (bytes == null) continue;

      final ext = remote.contains('.') ? remote.split('.').last : 'webp';
      final file = File('${dir.path}/${genre.slug}.$ext');
      await file.writeAsBytes(bytes);

      await genreDao.upsert(genre.copyWith(localImagePath: file.path));
    }
  }

  // ── App locals (settings chrome, not catalog voice) ───────────────────

  Future<void> _syncAppLocals(List<String> langs) async {
    final rows = await api.fetchAppLocals(langs);
    debugPrint(
      '[SYNC] fetchAppLocals(${langs.join(",")}) → ${rows?.length ?? "null"} rows',
    );
    if (rows == null) return;
    await _upsertAppLocals(rows);
  }

  Future<void> _upsertAppLocals(dynamic raw) async {
    if (raw is! List || raw.isEmpty) return;

    final entities = <AppLocalEntity>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) continue;
      final entity = _mapAppLocalRow(item);
      if (entity != null) entities.add(entity);
    }
    if (entities.isEmpty) return;

    await appLocalDao.upsertAll(entities);
  }

  AppLocalEntity? _mapAppLocalRow(Map<String, dynamic> row) {
    final key = row['key'];
    final languageCode = row['language_code'];
    final value = row['value'];
    if (key is! String || languageCode is! String || value is! String) {
      return null;
    }
    if (key.isEmpty || value.isEmpty) return null;

    return AppLocalEntity(
      key: key,
      languageCode: languageCode,
      value: value,
      remoteUpdatedAt: _epochMillis(row['updated_at']),
    );
  }

  /// Returns true when every clip of [language] is on the device.
  Future<bool> _downloadVoiceClips(
    String language, {
    void Function(double)? onProgress,
  }) async {
    final rows = await translationDao.withAudioInLanguage(language);
    debugPrint('[Sync] voice clips to download: ${rows.length} for $language');
    if (rows.isEmpty) {
      onProgress?.call(1.0);
      return true;
    }

    final voiceDir = await _voiceDir(language);
    var downloaded = 0;
    var complete = true;

    for (final row in rows) {
      final remotePath = row.audioPath;
      if (remotePath == null || remotePath.isEmpty) {
        downloaded++;
        continue;
      }

      final fileName = remotePath.split('/').last;
      final localFile = File('${voiceDir.path}/$fileName');

      if (localFile.existsSync()) {
        downloaded++;
        onProgress?.call(downloaded / rows.length);
        continue;
      }

      final bucketPath = _stripBucket('voice', remotePath);
      debugPrint('[Sync] downloading $bucketPath');
      final bytes = await api.downloadFile('voice', bucketPath);
      if (bytes == null) {
        debugPrint('[Sync] failed: $bucketPath');
        complete = false;
      } else {
        await _writeAtomically(localFile, bytes);
        debugPrint('[Sync] saved: $fileName');
      }

      downloaded++;
      onProgress?.call(downloaded / rows.length);
    }
    return complete;
  }

  /// Playback treats "file exists" as "file is good", so a half-written clip
  /// (app killed mid-download) must never appear under its final name.
  Future<void> _writeAtomically(File target, List<int> bytes) async {
    final partial = File('${target.path}.part');
    await partial.writeAsBytes(bytes, flush: true);
    await partial.rename(target.path);
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  DateTime _lastSyncTime() {
    final raw = storage.getString(_lastSyncKey);
    if (raw == null) return DateTime.utc(2000);
    return DateTime.tryParse(raw) ?? DateTime.utc(2000);
  }

  static List<String> _uniqueLangs(String base) {
    if (base == LanguageCode.fallback) return [LanguageCode.fallback];
    return [base, LanguageCode.fallback];
  }

  static String _stripBucket(String bucket, String storedPath) {
    final prefix = '$bucket/';
    return storedPath.startsWith(prefix)
        ? storedPath.substring(prefix.length)
        : storedPath;
  }

  static int _epochMillis(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) {
      return DateTime.tryParse(raw)?.millisecondsSinceEpoch ?? 0;
    }
    return 0;
  }

  Future<Directory> _catalogDir(String name) async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/catalog/$name');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _voiceDir(String language) async {
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/voice/$language');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
