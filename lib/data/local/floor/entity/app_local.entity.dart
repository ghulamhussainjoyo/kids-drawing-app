import 'package:floor/floor.dart';

@Entity(tableName: 'app_locals', primaryKeys: ['key', 'languageCode'])
class AppLocalEntity {
  final String key;
  final String value;
  final String languageCode;
  final int remoteUpdatedAt;
  const AppLocalEntity({
    required this.key,
    required this.languageCode,
    required this.value,
    this.remoteUpdatedAt = 0,
  });
}
