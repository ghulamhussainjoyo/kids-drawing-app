import 'package:kids_drawing_flutter/data/local/artwork/json.artwork.loader.dart';
import 'package:kids_drawing_flutter/data/local/artwork/strokes.json.codec.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.dart';
import 'package:kids_drawing_flutter/types/coloring.artwork.dart';
import 'package:kids_drawing_flutter/types/drawing.stroke.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final String deviceId;
  final ArtworkDao artworkDao;
  final JsonArtworkLoader artworkLoader = JsonArtworkLoader();
  final StrokesJsonCodec strokesCodec = StrokesJsonCodec();

  CatalogRepositoryImpl({required this.artworkDao, required this.deviceId});

  @override
  Future<List<ArtworkEntity>> listByGenre(String genre) {
    return artworkDao.listByGenre(deviceId, genre);
  }

  @override
  Future<ArtworkEntity?> getByKey(String artworkKey) {
    return artworkDao.findByKey(deviceId, artworkKey);
  }

  @override
  ColoringArtwork loadTemplate(ArtworkEntity row) {
    return artworkLoader.load(row.templateJson);
  }

  @override
  List<DrawingStroke> loadStrokes(ArtworkEntity row) {
    return strokesCodec.decode(row.strokesJson);
  }

  @override
  Future<void> saveProgress({
    required ArtworkEntity row,
    required List<DrawingStroke> strokes,
    required double artworkSize,
    String? thumbnailPath,
  }) async {
    final updated = row.copyWith(
      strokesJson: strokesCodec.encode(
        artworkSize: artworkSize,
        strokes: strokes,
      ),
      thumbnailPath: thumbnailPath ?? row.thumbnailPath,
      revision: row.revision + 1,
      dirty: true,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
    await artworkDao.updateArtwork(updated);
  }
}
