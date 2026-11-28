import 'package:floor/floor.dart';

@Entity(tableName: 'catalog_genres')
class GenreEntity {
  @primaryKey
  final String slug;

  /// Local file path after downloading; null until the image is fetched.
  final String? localImagePath;

  /// Remote storage path, e.g. 'genre-images/animals.webp'.
  final String? remoteImagePath;

  /// JSON-encoded list of hex colour strings for the title gradient.
  final String titleFillColors;

  final String? titleOutlineColor;

  /// JSON-encoded list of bundled ambience clip names.
  final String ambience;

  final int sortOrder;

  /// 'published' | 'archived' | 'draft'
  final String status;

  /// 'seed' (bundled fallback) or 'remote' (from Supabase).
  final String source;

  final int remoteUpdatedAt;

  const GenreEntity({
    required this.slug,
    this.localImagePath,
    this.remoteImagePath,
    this.titleFillColors = '[]',
    this.titleOutlineColor,
    this.ambience = '[]',
    this.sortOrder = 0,
    this.status = 'published',
    this.source = 'remote',
    this.remoteUpdatedAt = 0,
  });

  GenreEntity copyWith({
    String? slug,
    String? localImagePath,
    String? remoteImagePath,
    String? titleFillColors,
    String? titleOutlineColor,
    String? ambience,
    int? sortOrder,
    String? status,
    String? source,
    int? remoteUpdatedAt,
  }) {
    return GenreEntity(
      slug: slug ?? this.slug,
      localImagePath: localImagePath ?? this.localImagePath,
      remoteImagePath: remoteImagePath ?? this.remoteImagePath,
      titleFillColors: titleFillColors ?? this.titleFillColors,
      titleOutlineColor: titleOutlineColor ?? this.titleOutlineColor,
      ambience: ambience ?? this.ambience,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      source: source ?? this.source,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
    );
  }
}
