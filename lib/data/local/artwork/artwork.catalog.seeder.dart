import 'package:kids_drawing_flutter/core/engine/layer.manager.dart';
import 'package:kids_drawing_flutter/core/engine/region.engine.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.drawing.tool.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.thumbnail.baker.dart';
import 'package:kids_drawing_flutter/data/local/artwork/json.artwork.loader.dart';
import 'package:kids_drawing_flutter/data/local/artwork/strokes.json.codec.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/data/seed/artwork.seed.catalog.dart';

/// Inserts missing seed rows for [deviceId] without wiping strokes.
class ArtworkCatalogSeeder {
  final ArtworkDao artworkDao;
  final ArtworkSeedCatalog catalog;
  final StrokesJsonCodec strokesCodec = StrokesJsonCodec();
  final JsonArtworkLoader artworkLoader = JsonArtworkLoader();
  final ArtworkThumbnailBaker thumbnailBaker = ArtworkThumbnailBaker();

  ArtworkCatalogSeeder({
    required this.artworkDao,
    StrokesJsonCodec? strokesCodec,
    JsonArtworkLoader? artworkLoader,
    ArtworkThumbnailBaker? thumbnailBaker,
    this.catalog = const ArtworkSeedCatalog(),
  });

  Future<void> seedMissing(String deviceId) async {
    final existing = await artworkDao.listForDevice(deviceId);
    final existingByKey = <String, ArtworkEntity>{};
    for (final row in existing) {
      existingByKey[row.artworkKey] = row;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final entry in catalog.entries) {
      final existingRow = existingByKey[entry.artworkKey];
      if (existingRow != null) {
        await _ensureOutlineThumb(existingRow);
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
          isPremium: entry.isPremium,
          strokesJson: strokesCodec.emptyDocument(artwork.size),
          thumbnailPath: thumbnailPath,
          revision: 0,
          dirty: false,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> _ensureOutlineThumb(ArtworkEntity row) async {
    final path = row.thumbnailPath;
    if (path != null && path.isNotEmpty) {
      return;
    }
    final thumbnailPath = await _bakeOutlineThumb(
      templateJson: row.templateJson,
      genre: row.genre,
      artworkKey: row.artworkKey,
    );
    await artworkDao.updateArtwork(
      row.copyWith(
        thumbnailPath: thumbnailPath,
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
    final tool = PencilTool();
    try {
      return await thumbnailBaker.bake(
        layerManager: layerManager,
        strokes: const [],
        revision: 0,
        tool: tool,
        genre: genre,
        artworkKey: artworkKey,
      );
    } finally {
      layerManager.dispose();
      tool.dispose();
    }
  }
}
