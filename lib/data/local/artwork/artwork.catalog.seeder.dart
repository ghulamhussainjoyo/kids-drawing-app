import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/engine/layer.manager.dart';
import 'package:kids_drawing_flutter/core/engine/region.engine.dart';
import 'package:kids_drawing_flutter/core/tools/stationary.tools.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.thumbnail.baker.dart';
import 'package:kids_drawing_flutter/data/local/artwork/json.artwork.loader.dart';
import 'package:kids_drawing_flutter/data/local/artwork/strokes.json.codec.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.entity.dart';
import 'package:kids_drawing_flutter/data/seed/artwork.seed.catalog.dart';
import 'package:kids_drawing_flutter/data/seed/artwork.seed.entry.dart';

/// Seeds bundled artwork + genre rows when no remote catalog exists yet.
class ArtworkCatalogSeeder {
  final ArtworkDao artworkDao;
  final GenreDao genreDao;
  final ArtworkSeedCatalog catalog;
  final StrokesJsonCodec strokesCodec = StrokesJsonCodec();
  final JsonArtworkLoader artworkLoader = JsonArtworkLoader();
  final ArtworkThumbnailBaker thumbnailBaker = ArtworkThumbnailBaker();

  ArtworkCatalogSeeder({
    required this.artworkDao,
    required this.genreDao,
    this.catalog = const ArtworkSeedCatalog(),
  });

  /// Bakes outline thumbnails for any artwork that is missing one.
  Future<void> bakeMissingThumbnails(String deviceId) async {
    final all = await artworkDao.listForDevice(deviceId);
    for (final row in all) {
      if (row.thumbnailPath != null && row.thumbnailPath!.isNotEmpty) continue;
      if (row.templateJson.isEmpty || row.templateJson == '{}') continue;
      try {
        final path = await _bakeOutlineThumb(
          templateJson: row.templateJson,
          genre: row.genre,
          artworkKey: row.artworkKey,
        );
        await artworkDao.updateArtwork(row.copyWith(thumbnailPath: path));
      } catch (_) {
        debugPrint('Failed to bake thumbnail for ${row.title} — skipping.');
        // Template may have invalid path data — skip this artwork.
      }
    }
  }

  /// Seeds if Floor has no genres yet. Skips entirely when remote data exists.
  Future<void> seedIfEmpty(String deviceId) async {
    final count = await genreDao.count();
    if ((count ?? 0) > 0) return;

    await _seedGenres();
    await _seedArtworks(deviceId);
  }

  Future<void> _seedGenres() async {
    for (final genre in _bundledGenres) {
      await genreDao.upsert(genre);
    }
  }

  Future<void> _seedArtworks(String deviceId) async {
    final existing = await artworkDao.listForDevice(deviceId);
    final existingByKey = <String, ArtworkEntity>{};
    for (final row in existing) {
      existingByKey[row.artworkKey] = row;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final entry in catalog.entries) {
      final existingRow = existingByKey[entry.artworkKey];
      if (existingRow != null) {
        await _refreshExisting(existingRow, entry);
        continue;
      }
      final artwork = artworkLoader.load(entry.templateJson);
      final thumbnailPath = await _bakeOutlineThumb(
        templateJson: entry.templateJson,
        genre: entry.genre,
        artworkKey: entry.artworkKey,
      );

      await artworkDao.insertArtwork(
        ArtworkEntity(
          deviceId: deviceId,
          artworkKey: entry.artworkKey,
          genre: entry.genre,
          title: entry.title,
          templateJson: entry.templateJson,
          voice: entry.voice,
          isPremium: entry.isPremium,
          strokesJson: strokesCodec.emptyDocument(artwork.size),
          thumbnailPath: thumbnailPath,
          revision: 0,
          dirty: false,
          updatedAt: now,
          source: 'seed',
        ),
      );
    }
  }

  Future<void> _refreshExisting(
    ArtworkEntity row,
    ArtworkSeedEntry entry,
  ) async {
    final thumb = row.thumbnailPath;
    final needsThumb = thumb == null || thumb.isEmpty;
    final needsVoice = row.voice == null && entry.voice != null;
    if (!needsThumb && !needsVoice) return;

    var thumbnailPath = row.thumbnailPath;
    if (needsThumb) {
      thumbnailPath = await _bakeOutlineThumb(
        templateJson: row.templateJson,
        genre: row.genre,
        artworkKey: row.artworkKey,
      );
    }

    await artworkDao.updateArtwork(
      row.copyWith(
        thumbnailPath: thumbnailPath,
        voice: entry.voice,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<String> _bakeOutlineThumb({
    required String templateJson,
    required String genre,
    required String artworkKey,
  }) async {
    final artwork = artworkLoader.load(templateJson);
    final regionEngine = RegionEngine(artwork);
    final layerManager = LayerManager(regionEngine: regionEngine);
    final tools = StationaryTools();
    try {
      return await thumbnailBaker.bake(
        layerManager: layerManager,
        strokes: const [],
        revision: 0,
        toolFor: tools.toolFor,
        genre: genre,
        artworkKey: artworkKey,
      );
    } finally {
      layerManager.dispose();
      tools.dispose();
    }
  }

  static const _bundledGenres = [
    GenreEntity(
      slug: 'coloring-arts',
      titleFillColors: '["2EC4C6"]',
      titleOutlineColor: '0B3D3A',
      ambience: '["page_turn","chime","crayon_scribble"]',
      sortOrder: 0,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'school',
      titleFillColors: '["3B82F6"]',
      titleOutlineColor: '0F172A',
      ambience: '["school_bell","kids_chatter","pencil_write"]',
      sortOrder: 1,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'animals',
      titleFillColors: '["5FCF6B","4FC3F7"]',
      titleOutlineColor: '14352A',
      ambience: '["bird_chirp","dog_bark","cat_meow","cow_moo"]',
      sortOrder: 2,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'music',
      titleFillColors: '["FFD54F","7C3AED"]',
      titleOutlineColor: '2E1065',
      ambience: '["piano_note","guitar_strum","drum_tap","xylophone"]',
      sortOrder: 3,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'transport',
      titleFillColors: '["FFE566","F0A020"]',
      titleOutlineColor: '5C3A1E',
      ambience: '["car_horn","train_whistle","plane_pass","bicycle_bell"]',
      sortOrder: 4,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'seasons',
      titleFillColors: '["81D4FA","F8BBD0","81C784","EF5350"]',
      titleOutlineColor: '1A237E',
      ambience: '["bird_chirp","rain","wind","snow_crunch","leaves"]',
      sortOrder: 5,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'princes',
      titleFillColors: '["FF4D94"]',
      titleOutlineColor: '5B0E3D',
      ambience: '["harp","sparkle","castle_fanfare"]',
      sortOrder: 6,
      source: 'seed',
    ),
    GenreEntity(
      slug: 'fruit-garden',
      titleFillColors: '["FF8A3D","FFD23F","5FCF6B","4B8BFF","9B5DE5"]',
      titleOutlineColor: '1A1A2E',
      ambience: '["bee_buzz","water_drop","bird_chirp","crunch"]',
      sortOrder: 7,
      source: 'seed',
    ),
  ];
}
