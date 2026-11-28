// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ArtworkDao? _artworkDaoInstance;

  LanguageDao? _languageDaoInstance;

  GenreDao? _genreDaoInstance;

  TranslationDao? _translationDaoInstance;

  AppLocalDao? _appLocalDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 4,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `artworks` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `deviceId` TEXT NOT NULL, `userId` TEXT, `artworkKey` TEXT NOT NULL, `genre` TEXT NOT NULL, `title` TEXT NOT NULL, `templateJson` TEXT NOT NULL, `voice` TEXT, `isPremium` INTEGER NOT NULL, `strokesJson` TEXT NOT NULL, `thumbnailPath` TEXT, `thumbnailUrl` TEXT, `revision` INTEGER NOT NULL, `dirty` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL, `sortOrder` INTEGER NOT NULL, `status` TEXT NOT NULL, `source` TEXT NOT NULL, `remoteUpdatedAt` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `catalog_languages` (`code` TEXT NOT NULL, `englishName` TEXT NOT NULL, `nativeName` TEXT NOT NULL, `direction` TEXT NOT NULL, `isActive` INTEGER NOT NULL, `sortOrder` INTEGER NOT NULL, `remoteUpdatedAt` INTEGER NOT NULL, PRIMARY KEY (`code`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `catalog_genres` (`slug` TEXT NOT NULL, `localImagePath` TEXT, `remoteImagePath` TEXT, `titleFillColors` TEXT NOT NULL, `titleOutlineColor` TEXT, `ambience` TEXT NOT NULL, `sortOrder` INTEGER NOT NULL, `status` TEXT NOT NULL, `source` TEXT NOT NULL, `remoteUpdatedAt` INTEGER NOT NULL, PRIMARY KEY (`slug`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `catalog_translations` (`id` TEXT NOT NULL, `genreSlug` TEXT, `artworkSlug` TEXT, `languageCode` TEXT NOT NULL, `field` TEXT NOT NULL, `position` INTEGER NOT NULL, `text` TEXT NOT NULL, `audioPath` TEXT, `audioSha256` TEXT, `remoteUpdatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `app_locals` (`key` TEXT NOT NULL, `value` TEXT NOT NULL, `languageCode` TEXT NOT NULL, `remoteUpdatedAt` INTEGER NOT NULL, PRIMARY KEY (`key`, `languageCode`))');
        await database.execute(
            'CREATE UNIQUE INDEX `index_artworks_deviceId_artworkKey` ON `artworks` (`deviceId`, `artworkKey`)');
        await database.execute(
            'CREATE INDEX `index_catalog_translations_genreSlug_languageCode_field_position` ON `catalog_translations` (`genreSlug`, `languageCode`, `field`, `position`)');
        await database.execute(
            'CREATE INDEX `index_catalog_translations_artworkSlug_languageCode_field_position` ON `catalog_translations` (`artworkSlug`, `languageCode`, `field`, `position`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArtworkDao get artworkDao {
    return _artworkDaoInstance ??= _$ArtworkDao(database, changeListener);
  }

  @override
  LanguageDao get languageDao {
    return _languageDaoInstance ??= _$LanguageDao(database, changeListener);
  }

  @override
  GenreDao get genreDao {
    return _genreDaoInstance ??= _$GenreDao(database, changeListener);
  }

  @override
  TranslationDao get translationDao {
    return _translationDaoInstance ??=
        _$TranslationDao(database, changeListener);
  }

  @override
  AppLocalDao get appLocalDao {
    return _appLocalDaoInstance ??= _$AppLocalDao(database, changeListener);
  }
}

class _$ArtworkDao extends ArtworkDao {
  _$ArtworkDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _artworkEntityInsertionAdapter = InsertionAdapter(
            database,
            'artworks',
            (ArtworkEntity item) => <String, Object?>{
                  'id': item.id,
                  'deviceId': item.deviceId,
                  'userId': item.userId,
                  'artworkKey': item.artworkKey,
                  'genre': item.genre,
                  'title': item.title,
                  'templateJson': item.templateJson,
                  'voice': item.voice,
                  'isPremium': item.isPremium ? 1 : 0,
                  'strokesJson': item.strokesJson,
                  'thumbnailPath': item.thumbnailPath,
                  'thumbnailUrl': item.thumbnailUrl,
                  'revision': item.revision,
                  'dirty': item.dirty ? 1 : 0,
                  'updatedAt': item.updatedAt,
                  'sortOrder': item.sortOrder,
                  'status': item.status,
                  'source': item.source,
                  'remoteUpdatedAt': item.remoteUpdatedAt
                }),
        _artworkEntityUpdateAdapter = UpdateAdapter(
            database,
            'artworks',
            ['id'],
            (ArtworkEntity item) => <String, Object?>{
                  'id': item.id,
                  'deviceId': item.deviceId,
                  'userId': item.userId,
                  'artworkKey': item.artworkKey,
                  'genre': item.genre,
                  'title': item.title,
                  'templateJson': item.templateJson,
                  'voice': item.voice,
                  'isPremium': item.isPremium ? 1 : 0,
                  'strokesJson': item.strokesJson,
                  'thumbnailPath': item.thumbnailPath,
                  'thumbnailUrl': item.thumbnailUrl,
                  'revision': item.revision,
                  'dirty': item.dirty ? 1 : 0,
                  'updatedAt': item.updatedAt,
                  'sortOrder': item.sortOrder,
                  'status': item.status,
                  'source': item.source,
                  'remoteUpdatedAt': item.remoteUpdatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ArtworkEntity> _artworkEntityInsertionAdapter;

  final UpdateAdapter<ArtworkEntity> _artworkEntityUpdateAdapter;

  @override
  Future<List<ArtworkEntity>> listByGenre(
    String deviceId,
    String genre,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM artworks WHERE deviceId = ?1 AND genre = ?2 AND status = \'published\' ORDER BY sortOrder ASC, title ASC',
        mapper: (Map<String, Object?> row) => ArtworkEntity(id: row['id'] as int?, deviceId: row['deviceId'] as String, userId: row['userId'] as String?, artworkKey: row['artworkKey'] as String, genre: row['genre'] as String, title: row['title'] as String, templateJson: row['templateJson'] as String, voice: row['voice'] as String?, isPremium: (row['isPremium'] as int) != 0, strokesJson: row['strokesJson'] as String, thumbnailPath: row['thumbnailPath'] as String?, thumbnailUrl: row['thumbnailUrl'] as String?, revision: row['revision'] as int, dirty: (row['dirty'] as int) != 0, updatedAt: row['updatedAt'] as int, sortOrder: row['sortOrder'] as int, status: row['status'] as String, source: row['source'] as String, remoteUpdatedAt: row['remoteUpdatedAt'] as int?),
        arguments: [deviceId, genre]);
  }

  @override
  Future<ArtworkEntity?> findByKey(
    String deviceId,
    String artworkKey,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM artworks WHERE deviceId = ?1 AND artworkKey = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => ArtworkEntity(id: row['id'] as int?, deviceId: row['deviceId'] as String, userId: row['userId'] as String?, artworkKey: row['artworkKey'] as String, genre: row['genre'] as String, title: row['title'] as String, templateJson: row['templateJson'] as String, voice: row['voice'] as String?, isPremium: (row['isPremium'] as int) != 0, strokesJson: row['strokesJson'] as String, thumbnailPath: row['thumbnailPath'] as String?, thumbnailUrl: row['thumbnailUrl'] as String?, revision: row['revision'] as int, dirty: (row['dirty'] as int) != 0, updatedAt: row['updatedAt'] as int, sortOrder: row['sortOrder'] as int, status: row['status'] as String, source: row['source'] as String, remoteUpdatedAt: row['remoteUpdatedAt'] as int?),
        arguments: [deviceId, artworkKey]);
  }

  @override
  Future<List<ArtworkEntity>> listForDevice(String deviceId) async {
    return _queryAdapter.queryList('SELECT * FROM artworks WHERE deviceId = ?1',
        mapper: (Map<String, Object?> row) => ArtworkEntity(
            id: row['id'] as int?,
            deviceId: row['deviceId'] as String,
            userId: row['userId'] as String?,
            artworkKey: row['artworkKey'] as String,
            genre: row['genre'] as String,
            title: row['title'] as String,
            templateJson: row['templateJson'] as String,
            voice: row['voice'] as String?,
            isPremium: (row['isPremium'] as int) != 0,
            strokesJson: row['strokesJson'] as String,
            thumbnailPath: row['thumbnailPath'] as String?,
            thumbnailUrl: row['thumbnailUrl'] as String?,
            revision: row['revision'] as int,
            dirty: (row['dirty'] as int) != 0,
            updatedAt: row['updatedAt'] as int,
            sortOrder: row['sortOrder'] as int,
            status: row['status'] as String,
            source: row['source'] as String,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int?),
        arguments: [deviceId]);
  }

  @override
  Future<int> insertArtwork(ArtworkEntity artwork) {
    return _artworkEntityInsertionAdapter.insertAndReturnId(
        artwork, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateArtwork(ArtworkEntity artwork) {
    return _artworkEntityUpdateAdapter.updateAndReturnChangedRows(
        artwork, OnConflictStrategy.abort);
  }
}

class _$LanguageDao extends LanguageDao {
  _$LanguageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _languageEntityInsertionAdapter = InsertionAdapter(
            database,
            'catalog_languages',
            (LanguageEntity item) => <String, Object?>{
                  'code': item.code,
                  'englishName': item.englishName,
                  'nativeName': item.nativeName,
                  'direction': item.direction,
                  'isActive': item.isActive ? 1 : 0,
                  'sortOrder': item.sortOrder,
                  'remoteUpdatedAt': item.remoteUpdatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LanguageEntity> _languageEntityInsertionAdapter;

  @override
  Future<List<LanguageEntity>> listActive() async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_languages WHERE isActive = 1 ORDER BY sortOrder ASC',
        mapper: (Map<String, Object?> row) => LanguageEntity(
            code: row['code'] as String,
            englishName: row['englishName'] as String,
            nativeName: row['nativeName'] as String,
            direction: row['direction'] as String,
            isActive: (row['isActive'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int));
  }

  @override
  Future<LanguageEntity?> findByCode(String code) async {
    return _queryAdapter.query(
        'SELECT * FROM catalog_languages WHERE code = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => LanguageEntity(
            code: row['code'] as String,
            englishName: row['englishName'] as String,
            nativeName: row['nativeName'] as String,
            direction: row['direction'] as String,
            isActive: (row['isActive'] as int) != 0,
            sortOrder: row['sortOrder'] as int,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [code]);
  }

  @override
  Future<int?> count() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM catalog_languages',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> upsert(LanguageEntity language) async {
    await _languageEntityInsertionAdapter.insert(
        language, OnConflictStrategy.replace);
  }

  @override
  Future<void> upsertAll(List<LanguageEntity> languages) async {
    await _languageEntityInsertionAdapter.insertList(
        languages, OnConflictStrategy.replace);
  }
}

class _$GenreDao extends GenreDao {
  _$GenreDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _genreEntityInsertionAdapter = InsertionAdapter(
            database,
            'catalog_genres',
            (GenreEntity item) => <String, Object?>{
                  'slug': item.slug,
                  'localImagePath': item.localImagePath,
                  'remoteImagePath': item.remoteImagePath,
                  'titleFillColors': item.titleFillColors,
                  'titleOutlineColor': item.titleOutlineColor,
                  'ambience': item.ambience,
                  'sortOrder': item.sortOrder,
                  'status': item.status,
                  'source': item.source,
                  'remoteUpdatedAt': item.remoteUpdatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<GenreEntity> _genreEntityInsertionAdapter;

  @override
  Future<List<GenreEntity>> listPublished() async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_genres WHERE status = \'published\' ORDER BY sortOrder ASC',
        mapper: (Map<String, Object?> row) => GenreEntity(
            slug: row['slug'] as String,
            localImagePath: row['localImagePath'] as String?,
            remoteImagePath: row['remoteImagePath'] as String?,
            titleFillColors: row['titleFillColors'] as String,
            titleOutlineColor: row['titleOutlineColor'] as String?,
            ambience: row['ambience'] as String,
            sortOrder: row['sortOrder'] as int,
            status: row['status'] as String,
            source: row['source'] as String,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int));
  }

  @override
  Future<GenreEntity?> findBySlug(String slug) async {
    return _queryAdapter.query(
        'SELECT * FROM catalog_genres WHERE slug = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => GenreEntity(
            slug: row['slug'] as String,
            localImagePath: row['localImagePath'] as String?,
            remoteImagePath: row['remoteImagePath'] as String?,
            titleFillColors: row['titleFillColors'] as String,
            titleOutlineColor: row['titleOutlineColor'] as String?,
            ambience: row['ambience'] as String,
            sortOrder: row['sortOrder'] as int,
            status: row['status'] as String,
            source: row['source'] as String,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [slug]);
  }

  @override
  Future<int?> count() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM catalog_genres',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> upsert(GenreEntity genre) async {
    await _genreEntityInsertionAdapter.insert(
        genre, OnConflictStrategy.replace);
  }

  @override
  Future<void> upsertAll(List<GenreEntity> genres) async {
    await _genreEntityInsertionAdapter.insertList(
        genres, OnConflictStrategy.replace);
  }
}

class _$TranslationDao extends TranslationDao {
  _$TranslationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _translationEntityInsertionAdapter = InsertionAdapter(
            database,
            'catalog_translations',
            (TranslationEntity item) => <String, Object?>{
                  'id': item.id,
                  'genreSlug': item.genreSlug,
                  'artworkSlug': item.artworkSlug,
                  'languageCode': item.languageCode,
                  'field': item.field,
                  'position': item.position,
                  'text': item.text,
                  'audioPath': item.audioPath,
                  'audioSha256': item.audioSha256,
                  'remoteUpdatedAt': item.remoteUpdatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<TranslationEntity> _translationEntityInsertionAdapter;

  @override
  Future<List<TranslationEntity>> forGenre(
    String genreSlug,
    String lang,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_translations WHERE genreSlug = ?1 AND languageCode = ?2 ORDER BY field ASC, position ASC',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [genreSlug, lang]);
  }

  @override
  Future<List<TranslationEntity>> forArtwork(
    String artworkSlug,
    String lang,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_translations WHERE artworkSlug = ?1 AND languageCode = ?2 ORDER BY field ASC, position ASC',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [artworkSlug, lang]);
  }

  @override
  Future<TranslationEntity?> genreTitle(
    String genreSlug,
    String lang,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM catalog_translations WHERE genreSlug = ?1 AND languageCode = ?2 AND field = \'title\' AND position = 0 LIMIT 1',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [genreSlug, lang]);
  }

  @override
  Future<TranslationEntity?> artworkTitle(
    String artworkSlug,
    String lang,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM catalog_translations WHERE artworkSlug = ?1 AND languageCode = ?2 AND field = \'title\' AND position = 0 LIMIT 1',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [artworkSlug, lang]);
  }

  @override
  Future<List<TranslationEntity>> genreVoicePool(
    String genreSlug,
    String lang,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_translations WHERE genreSlug = ?1 AND languageCode = ?2 AND field = \'voice\' ORDER BY position ASC',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [genreSlug, lang]);
  }

  @override
  Future<List<TranslationEntity>> artworkVoicePool(
    String artworkSlug,
    String lang,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_translations WHERE artworkSlug = ?1 AND languageCode = ?2 AND field = \'voice\' ORDER BY position ASC',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [artworkSlug, lang]);
  }

  @override
  Future<List<TranslationEntity>> withAudioInLanguage(String lang) async {
    return _queryAdapter.queryList(
        'SELECT * FROM catalog_translations WHERE languageCode = ?1 AND audioPath IS NOT NULL AND audioPath != \'\'',
        mapper: (Map<String, Object?> row) => TranslationEntity(id: row['id'] as String, genreSlug: row['genreSlug'] as String?, artworkSlug: row['artworkSlug'] as String?, languageCode: row['languageCode'] as String, field: row['field'] as String, position: row['position'] as int, text: row['text'] as String, audioPath: row['audioPath'] as String?, audioSha256: row['audioSha256'] as String?, remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [lang]);
  }

  @override
  Future<void> upsert(TranslationEntity translation) async {
    await _translationEntityInsertionAdapter.insert(
        translation, OnConflictStrategy.replace);
  }

  @override
  Future<void> upsertAll(List<TranslationEntity> translations) async {
    await _translationEntityInsertionAdapter.insertList(
        translations, OnConflictStrategy.replace);
  }
}

class _$AppLocalDao extends AppLocalDao {
  _$AppLocalDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _appLocalEntityInsertionAdapter = InsertionAdapter(
            database,
            'app_locals',
            (AppLocalEntity item) => <String, Object?>{
                  'key': item.key,
                  'value': item.value,
                  'languageCode': item.languageCode,
                  'remoteUpdatedAt': item.remoteUpdatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppLocalEntity> _appLocalEntityInsertionAdapter;

  @override
  Future<AppLocalEntity?> find(
    String key,
    String lang,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM app_locals WHERE key = ?1 AND languageCode = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => AppLocalEntity(
            key: row['key'] as String,
            languageCode: row['languageCode'] as String,
            value: row['value'] as String,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [key, lang]);
  }

  @override
  Future<List<AppLocalEntity>> allForLanguage(String lang) async {
    return _queryAdapter.queryList(
        'SELECT * FROM app_locals WHERE languageCode = ?1',
        mapper: (Map<String, Object?> row) => AppLocalEntity(
            key: row['key'] as String,
            languageCode: row['languageCode'] as String,
            value: row['value'] as String,
            remoteUpdatedAt: row['remoteUpdatedAt'] as int),
        arguments: [lang]);
  }

  @override
  Future<void> upsertAll(List<AppLocalEntity> rows) async {
    await _appLocalEntityInsertionAdapter.insertList(
        rows, OnConflictStrategy.replace);
  }
}
