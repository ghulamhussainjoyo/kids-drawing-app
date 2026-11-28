import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/entity/app_local.entity.dart';

@dao
abstract class AppLocalDao {
  @Query(
    'SELECT * FROM app_locals WHERE key = :key AND languageCode = :lang LIMIT 1',
  )
  Future<AppLocalEntity?> find(String key, String lang);

  @Query('SELECT * FROM app_locals WHERE languageCode = :lang')
  Future<List<AppLocalEntity>> allForLanguage(String lang);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAll(List<AppLocalEntity> rows);
}
