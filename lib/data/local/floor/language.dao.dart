import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.entity.dart';

@dao
abstract class LanguageDao {
  @Query(
    'SELECT * FROM catalog_languages WHERE isActive = 1 ORDER BY sortOrder ASC',
  )
  Future<List<LanguageEntity>> listActive();

  @Query('SELECT * FROM catalog_languages WHERE code = :code LIMIT 1')
  Future<LanguageEntity?> findByCode(String code);

  @Query('SELECT COUNT(*) FROM catalog_languages')
  Future<int?> count();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(LanguageEntity language);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAll(List<LanguageEntity> languages);
}
