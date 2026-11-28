import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/genre.entity.dart';

@dao
abstract class GenreDao {
  @Query(
    "SELECT * FROM catalog_genres WHERE status = 'published' ORDER BY sortOrder ASC",
  )
  Future<List<GenreEntity>> listPublished();

  @Query('SELECT * FROM catalog_genres WHERE slug = :slug LIMIT 1')
  Future<GenreEntity?> findBySlug(String slug);

  @Query('SELECT COUNT(*) FROM catalog_genres')
  Future<int?> count();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(GenreEntity genre);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAll(List<GenreEntity> genres);
}
