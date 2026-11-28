import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:floor/floor.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/core/audio/sound.route.observer.dart';
import 'package:kids_drawing_flutter/core/storage/local.storage.dart'
    as app_storage;
import 'package:kids_drawing_flutter/core/sync/background.sync.worker.dart';
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/data/local/device.id.store.dart';
import 'package:kids_drawing_flutter/data/local/floor/app.database.dart';
import 'package:kids_drawing_flutter/data/remote/sync.api.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.impl.dart';
import 'package:kids_drawing_flutter/data/repositories/genre/genre.repository.impl.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.impl.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/splash/splash.screen.dart';
import 'core/ui/theme/app.theme.dart';
import 'state/drawing/drawing.view-model.dart';

const dbName = 'kids_drawing.db';

/// v2 gave every artwork the line the voice reads when it is opened.
final _v1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE artworks ADD COLUMN voice TEXT');
});

/// v3 adds catalog sync tables + artwork sync columns.
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

final allMigrations = [_v1to2, _v2to3];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  final deviceId = await DeviceIdStore().getOrCreate();
  final database = await $FloorAppDatabase
      .databaseBuilder(dbName)
      .addMigrations(allMigrations)
      .build();

  final prefs = await SharedPreferences.getInstance();
  final localStorage = app_storage.LocalStorage(prefs);
  final settingsRepository = SettingsRepositoryImpl(localStorage);

  final syncApi = SyncApi();

  final syncService = CatalogSyncService(
    api: syncApi,
    deviceId: deviceId,
    storage: localStorage,
    genreDao: database.genreDao,
    artworkDao: database.artworkDao,
    languageDao: database.languageDao,
    translationDao: database.translationDao,
  );

  final seeder = ArtworkCatalogSeeder(
    artworkDao: database.artworkDao,
    genreDao: database.genreDao,
  );

  final catalogRepository = CatalogRepositoryImpl(
    deviceId: deviceId,
    artworkDao: database.artworkDao,
    translationDao: database.translationDao,
  );

  final genreRepository = FloorGenreRepository(
    genreDao: database.genreDao,
    translationDao: database.translationDao,
  );

  final sound = AppSound.create();

  await sound.load();

  try {
    await registerBackgroundSync();
  } catch (_) {
    // Background sync may fail on simulators — foreground sync still works.
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AppSound>.value(value: sound),
        Provider<SyncApi>.value(value: syncApi),
        Provider<String>.value(value: deviceId),
        Provider<ArtworkCatalogSeeder>.value(value: seeder),
        Provider<CatalogSyncService>.value(value: syncService),
        Provider<SettingsRepository>.value(value: settingsRepository),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => SettingViewModel(
            settingsRepository,
            sound,
            syncService: syncService,
            languageDao: database.languageDao,
          )..load(),
        ),
        Provider<CatalogRepository>.value(value: catalogRepository),
        ChangeNotifierProvider(
          create: (_) =>
              GenreViewModel(genreRepository: genreRepository, sound: sound),
        ),
        ChangeNotifierProvider(
          create: (context) => DrawingViewModel(
            catalogRepository: context.read<CatalogRepository>(),
            sound: sound,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => GalleryViewModel(
            catalogRepository: context.read<CatalogRepository>(),
            drawingViewModel: context.read<DrawingViewModel>(),
            sound: sound,
          ),
        ),
      ],
      child: AppWidget(routeObserver: SoundRouteObserver(sound)),
    ),
  );
}

class AppWidget extends StatelessWidget {
  final SoundRouteObserver routeObserver;

  const AppWidget({super.key, required this.routeObserver});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Kids Drawing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data(),
      navigatorObservers: [routeObserver],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
