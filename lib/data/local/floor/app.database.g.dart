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

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `artworks` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `deviceId` TEXT NOT NULL, `userId` TEXT, `artworkKey` TEXT NOT NULL, `genre` TEXT NOT NULL, `title` TEXT NOT NULL, `templateJson` TEXT NOT NULL, `isPremium` INTEGER NOT NULL, `strokesJson` TEXT NOT NULL, `thumbnailPath` TEXT, `thumbnailUrl` TEXT, `revision` INTEGER NOT NULL, `dirty` INTEGER NOT NULL, `updatedAt` INTEGER NOT NULL)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_artworks_deviceId_artworkKey` ON `artworks` (`deviceId`, `artworkKey`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ArtworkDao get artworkDao {
    return _artworkDaoInstance ??= _$ArtworkDao(database, changeListener);
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
                  'isPremium': item.isPremium ? 1 : 0,
                  'strokesJson': item.strokesJson,
                  'thumbnailPath': item.thumbnailPath,
                  'thumbnailUrl': item.thumbnailUrl,
                  'revision': item.revision,
                  'dirty': item.dirty ? 1 : 0,
                  'updatedAt': item.updatedAt
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
                  'isPremium': item.isPremium ? 1 : 0,
                  'strokesJson': item.strokesJson,
                  'thumbnailPath': item.thumbnailPath,
                  'thumbnailUrl': item.thumbnailUrl,
                  'revision': item.revision,
                  'dirty': item.dirty ? 1 : 0,
                  'updatedAt': item.updatedAt
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
        'SELECT * FROM artworks WHERE deviceId = ?1 AND genre = ?2 ORDER BY title ASC',
        mapper: (Map<String, Object?> row) => ArtworkEntity(id: row['id'] as int?, deviceId: row['deviceId'] as String, userId: row['userId'] as String?, artworkKey: row['artworkKey'] as String, genre: row['genre'] as String, title: row['title'] as String, templateJson: row['templateJson'] as String, isPremium: (row['isPremium'] as int) != 0, strokesJson: row['strokesJson'] as String, thumbnailPath: row['thumbnailPath'] as String?, thumbnailUrl: row['thumbnailUrl'] as String?, revision: row['revision'] as int, dirty: (row['dirty'] as int) != 0, updatedAt: row['updatedAt'] as int),
        arguments: [deviceId, genre]);
  }

  @override
  Future<ArtworkEntity?> findByKey(
    String deviceId,
    String artworkKey,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM artworks WHERE deviceId = ?1 AND artworkKey = ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => ArtworkEntity(id: row['id'] as int?, deviceId: row['deviceId'] as String, userId: row['userId'] as String?, artworkKey: row['artworkKey'] as String, genre: row['genre'] as String, title: row['title'] as String, templateJson: row['templateJson'] as String, isPremium: (row['isPremium'] as int) != 0, strokesJson: row['strokesJson'] as String, thumbnailPath: row['thumbnailPath'] as String?, thumbnailUrl: row['thumbnailUrl'] as String?, revision: row['revision'] as int, dirty: (row['dirty'] as int) != 0, updatedAt: row['updatedAt'] as int),
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
            isPremium: (row['isPremium'] as int) != 0,
            strokesJson: row['strokesJson'] as String,
            thumbnailPath: row['thumbnailPath'] as String?,
            thumbnailUrl: row['thumbnailUrl'] as String?,
            revision: row['revision'] as int,
            dirty: (row['dirty'] as int) != 0,
            updatedAt: row['updatedAt'] as int),
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
