import 'package:floor/floor.dart';

const dbName = 'kids_drawing.db';

final _v1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE artworks ADD COLUMN voice TEXT');
});

final _v2to3 = Migration(2, 3, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS catalog_languages (
      code TEXT PRIMARY KEY NOT NULL,
      englishName TEXT NOT NULL,
      nativeName TEXT NOT NULL,
      direction TEXT NOT NULL DEFAULT 'ltr',
      isActive INTEGER NOT NULL DEFAULT 0,
      sortOrder INTEGER NOT NULL DEFAULT 0,
      remoteUpdatedAt INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS catalog_genres (
      slug TEXT PRIMARY KEY NOT NULL,
      localImagePath TEXT,
      remoteImagePath TEXT,
      titleFillColors TEXT NOT NULL DEFAULT '[]',
      titleOutlineColor TEXT,
      ambience TEXT NOT NULL DEFAULT '[]',
      sortOrder INTEGER NOT NULL DEFAULT 0,
      status TEXT NOT NULL DEFAULT 'published',
      source TEXT NOT NULL DEFAULT 'seed',
      remoteUpdatedAt INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await database.execute('''
    CREATE TABLE IF NOT EXISTS catalog_translations (
      id TEXT PRIMARY KEY NOT NULL,
      genreSlug TEXT,
      artworkSlug TEXT,
      languageCode TEXT NOT NULL,
      field TEXT NOT NULL,
      position INTEGER NOT NULL DEFAULT 0,
      text TEXT NOT NULL,
      audioPath TEXT,
      audioSha256 TEXT,
      remoteUpdatedAt INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await database.execute(
    'CREATE INDEX IF NOT EXISTS index_catalog_translations_genreSlug_languageCode_field_position '
    'ON catalog_translations (genreSlug, languageCode, field, position)',
  );

  await database.execute(
    'CREATE INDEX IF NOT EXISTS index_catalog_translations_artworkSlug_languageCode_field_position '
    'ON catalog_translations (artworkSlug, languageCode, field, position)',
  );

  await database.execute(
    'ALTER TABLE artworks ADD COLUMN sortOrder INTEGER NOT NULL DEFAULT 0',
  );

  await database.execute(
    "ALTER TABLE artworks ADD COLUMN status TEXT NOT NULL DEFAULT 'published'",
  );

  await database.execute(
    "ALTER TABLE artworks ADD COLUMN source TEXT NOT NULL DEFAULT 'seed'",
  );

  await database.execute(
    'ALTER TABLE artworks ADD COLUMN remoteUpdatedAt INTEGER',
  );
});

final _v3to4 = Migration(3, 4, (database) async {
  await database.execute('''
    CREATE TABLE IF NOT EXISTS app_locals (
      key TEXT NOT NULL,
      languageCode TEXT NOT NULL,
      value TEXT NOT NULL,
      remoteUpdatedAt INTEGER NOT NULL DEFAULT 0,
      PRIMARY KEY (key, languageCode)
    )
  ''');
  await database.execute(
    'CREATE INDEX IF NOT EXISTS index_app_locals_languageCode '
    'ON app_locals (languageCode)',
  );
});

final allMigrations = [_v1to2, _v2to3, _v3to4];
