import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';

@dao
abstract class ArtworkDao {
  @Query(
    'SELECT * FROM artworks WHERE deviceId = :deviceId AND genre = :genre ORDER BY title ASC',
  )
  Future<List<ArtworkEntity>> listByGenre(String deviceId, String genre);

  @Query(
    'SELECT * FROM artworks WHERE deviceId = :deviceId AND artworkKey = :artworkKey LIMIT 1',
  )
  Future<ArtworkEntity?> findByKey(String deviceId, String artworkKey);

  @Query('SELECT * FROM artworks WHERE deviceId = :deviceId')
  Future<List<ArtworkEntity>> listForDevice(String deviceId);

  @insert
  Future<int> insertArtwork(ArtworkEntity artwork);

  @update
  Future<int> updateArtwork(ArtworkEntity artwork);
}
