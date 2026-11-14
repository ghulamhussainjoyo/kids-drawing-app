import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/types/coloring.artwork.dart';
import 'package:kids_drawing_flutter/types/drawing.stroke.dart';

abstract class CatalogRepository {
  Future<List<ArtworkEntity>> listByGenre(String genre);

  Future<ArtworkEntity?> getByKey(String artworkKey);

  ColoringArtwork loadTemplate(ArtworkEntity row);

  List<DrawingStroke> loadStrokes(ArtworkEntity row);

  Future<void> saveProgress({
    required ArtworkEntity row,
    required List<DrawingStroke> strokes,
    required double artworkSize,
    String? thumbnailPath,
  });
}
