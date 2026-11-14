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
  final bool isPremium;
  final String strokesJson;
  final String? thumbnailPath;
  final String? thumbnailUrl;
  final int revision;
  final bool dirty;
  final int updatedAt;

  const ArtworkEntity({
    this.id,
    required this.deviceId,
    this.userId,
    required this.artworkKey,
    required this.genre,
    required this.title,
    required this.templateJson,
    required this.isPremium,
    required this.strokesJson,
    this.thumbnailPath,
    this.thumbnailUrl,
    required this.revision,
    required this.dirty,
    required this.updatedAt,
  });

  ArtworkEntity copyWith({
    int? id,
    String? deviceId,
    String? userId,
    String? artworkKey,
    String? genre,
    String? title,
    String? templateJson,
    bool? isPremium,
    String? strokesJson,
    String? thumbnailPath,
    String? thumbnailUrl,
    int? revision,
    bool? dirty,
    int? updatedAt,
  }) {
    return ArtworkEntity(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      artworkKey: artworkKey ?? this.artworkKey,
      genre: genre ?? this.genre,
      title: title ?? this.title,
      templateJson: templateJson ?? this.templateJson,
      isPremium: isPremium ?? this.isPremium,
      strokesJson: strokesJson ?? this.strokesJson,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      revision: revision ?? this.revision,
      dirty: dirty ?? this.dirty,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
