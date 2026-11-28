import 'package:floor/floor.dart';

@Entity(
  tableName: 'artworks',
  indices: [
    Index(value: ['deviceId', 'artworkKey'], unique: true),
  ],
)
class ArtworkEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String deviceId;
  final String? userId;
  final String artworkKey;
  final String genre;
  final String title;
  final String templateJson;

  /// Short line the voice reads when this artwork is opened.
  final String? voice;
  final bool isPremium;
  final String strokesJson;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final int revision;
  final bool dirty;
  final int updatedAt;

  // ---- sync columns (v3) ----
  final int sortOrder;

  /// 'published' | 'archived' | 'draft'.
  final String status;

  /// 'seed' (bundled fallback) or 'remote' (from Supabase).
  final String source;

  /// Epoch millis of the server's `updated_at`.
  final int? remoteUpdatedAt;

  const ArtworkEntity({
    this.id,
    required this.deviceId,
    this.userId,
    required this.artworkKey,
    required this.genre,
    required this.title,
    required this.templateJson,
    this.voice,
    required this.isPremium,
    required this.strokesJson,
    this.thumbnailPath,
    this.thumbnailUrl,
    required this.revision,
    required this.dirty,
    required this.updatedAt,
    this.sortOrder = 0,
    this.status = 'published',
    this.source = 'seed',
    this.remoteUpdatedAt,
  });

  ArtworkEntity copyWith({
    int? id,
    String? deviceId,
    String? userId,
    String? artworkKey,
    String? genre,
    String? title,
    String? templateJson,
    String? voice,
    bool? isPremium,
    String? strokesJson,
    String? thumbnailPath,
    String? thumbnailUrl,
    int? revision,
    bool? dirty,
    int? updatedAt,
    int? sortOrder,
    String? status,
    String? source,
    int? remoteUpdatedAt,
  }) {
    return ArtworkEntity(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      artworkKey: artworkKey ?? this.artworkKey,
      genre: genre ?? this.genre,
      title: title ?? this.title,
      templateJson: templateJson ?? this.templateJson,
      voice: voice ?? this.voice,
      isPremium: isPremium ?? this.isPremium,
      strokesJson: strokesJson ?? this.strokesJson,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      source: source ?? this.source,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
    );
  }
}
