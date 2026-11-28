import 'package:floor/floor.dart';
import 'package:kids_drawing_flutter/data/local/floor/translation.entity.dart';

@dao
abstract class TranslationDao {
  /// All translations for a genre in one language.
  @Query(
    'SELECT * FROM catalog_translations '
    'WHERE genreSlug = :genreSlug AND languageCode = :lang '
    'ORDER BY field ASC, position ASC',
  )
  Future<List<TranslationEntity>> forGenre(String genreSlug, String lang);

  /// All translations for an artwork in one language.
  @Query(
    'SELECT * FROM catalog_translations '
    'WHERE artworkSlug = :artworkSlug AND languageCode = :lang '
    'ORDER BY field ASC, position ASC',
  )
  Future<List<TranslationEntity>> forArtwork(String artworkSlug, String lang);

  /// Title text for a genre (field = 'title', position = 0).
  @Query(
    'SELECT * FROM catalog_translations '
    "WHERE genreSlug = :genreSlug AND languageCode = :lang AND field = 'title' AND position = 0 "
    'LIMIT 1',
  )
  Future<TranslationEntity?> genreTitle(String genreSlug, String lang);

  /// Title text for an artwork (field = 'title', position = 0).
  @Query(
    'SELECT * FROM catalog_translations '
    "WHERE artworkSlug = :artworkSlug AND languageCode = :lang AND field = 'title' AND position = 0 "
    'LIMIT 1',
  )
  Future<TranslationEntity?> artworkTitle(String artworkSlug, String lang);

  /// Voice lines for a genre — the pool one is picked from at random.
  @Query(
    'SELECT * FROM catalog_translations '
    "WHERE genreSlug = :genreSlug AND languageCode = :lang AND field = 'voice' "
    'ORDER BY position ASC',
  )
  Future<List<TranslationEntity>> genreVoicePool(String genreSlug, String lang);

  /// Voice lines for an artwork.
  @Query(
    'SELECT * FROM catalog_translations '
    "WHERE artworkSlug = :artworkSlug AND languageCode = :lang AND field = 'voice' "
    'ORDER BY position ASC',
  )
  Future<List<TranslationEntity>> artworkVoicePool(
    String artworkSlug,
    String lang,
  );

  @Query(
    'SELECT * FROM catalog_translations '
    "WHERE languageCode = :lang AND audioPath IS NOT NULL AND audioPath != ''",
  )
  Future<List<TranslationEntity>> withAudioInLanguage(String lang);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(TranslationEntity translation);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAll(List<TranslationEntity> translations);
}
