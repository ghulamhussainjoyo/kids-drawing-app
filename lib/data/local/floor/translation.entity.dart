import 'package:floor/floor.dart';

@Entity(
  tableName: 'catalog_translations',
  indices: [
    Index(value: ['genreSlug', 'languageCode', 'field', 'position']),
    Index(value: ['artworkSlug', 'languageCode', 'field', 'position']),
  ],
)
class TranslationEntity {
  @primaryKey
  final String id;

  final String? genreSlug;
  final String? artworkSlug;
  final String languageCode;

  /// 'title' or 'voice'.
  final String field;

  final int position;
  final String text;

  /// Storage path, e.g. 'voice/en/yellow_05bf6449.mp3'.
  final String? audioPath;

  /// Hex SHA-256 of the MP3 — used to skip re-downloading unchanged clips.
  final String? audioSha256;

  final int remoteUpdatedAt;

  const TranslationEntity({
    required this.id,
    this.genreSlug,
    this.artworkSlug,
    required this.languageCode,
    required this.field,
    this.position = 0,
    required this.text,
    this.audioPath,
    this.audioSha256,
    this.remoteUpdatedAt = 0,
  });
}
