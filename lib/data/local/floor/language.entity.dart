import 'package:floor/floor.dart';

@Entity(tableName: 'catalog_languages')
class LanguageEntity {
  @primaryKey
  final String code;

  final String englishName;
  final String nativeName;
  final String direction;
  final bool isActive;
  final int sortOrder;
  final int remoteUpdatedAt;

  const LanguageEntity({
    required this.code,
    required this.englishName,
    required this.nativeName,
    this.direction = 'ltr',
    this.isActive = false,
    this.sortOrder = 0,
    this.remoteUpdatedAt = 0,
  });

  LanguageEntity copyWith({
    String? code,
    String? englishName,
    String? nativeName,
    String? direction,
    bool? isActive,
    int? sortOrder,
    int? remoteUpdatedAt,
  }) {
    return LanguageEntity(
      code: code ?? this.code,
      englishName: englishName ?? this.englishName,
      nativeName: nativeName ?? this.nativeName,
      direction: direction ?? this.direction,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
    );
  }
}
