import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/core/storage/local.storage.dart'
    as app_storage;
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/data/local/device.id.store.dart';
import 'package:kids_drawing_flutter/data/local/floor/app.database.dart';
import 'package:kids_drawing_flutter/data/local/floor/app.migrations.dart';
import 'package:kids_drawing_flutter/data/remote/sync.api.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.impl.dart';
import 'package:kids_drawing_flutter/data/repositories/genre/genre.repository.impl.dart';
import 'package:kids_drawing_flutter/data/repositories/locals/app_locals.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/locals/app_locals.repository.impl.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppDependencies {
  final AppDatabase database;
  final String deviceId;
  final app_storage.LocalStorage localStorage;
  final SettingsRepository settingsRepository;
  final SyncApi syncApi;
  final CatalogSyncService syncService;
  final ArtworkCatalogSeeder seeder;
  final CatalogRepositoryImpl catalogRepository;
  final FloorGenreRepository genreRepository;
  final AppSound sound;
  final AppLocalsRepository appLocalsRepository;

  AppDependencies({
    required this.database,
    required this.deviceId,
    required this.localStorage,
    required this.settingsRepository,
    required this.syncApi,
    required this.syncService,
    required this.seeder,
    required this.catalogRepository,
    required this.genreRepository,
    required this.sound,
    required this.appLocalsRepository,
  });

  static void _requireEnv(String key) {
    if (dotenv.env[key]?.isEmpty ?? true) {
      throw StateError('Missing required .env key: $key');
    }
  }

  static Future<
    ({
      AppDatabase database,
      app_storage.LocalStorage localStorage,
      String deviceId,
    })
  >
  _bootstrap() async {
    await dotenv.load(fileName: '.env');
    _requireEnv('SUPABASE_URL');
    _requireEnv('SUPABASE_PUBLISHABLE_KEY');

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
    );

    final database = await $FloorAppDatabase
        .databaseBuilder(dbName)
        .addMigrations(allMigrations)
        .build();

    final prefs = await SharedPreferences.getInstance();
    final localStorage = app_storage.LocalStorage(prefs);
    final deviceId = await DeviceIdStore().getOrCreate();

    return (database: database, localStorage: localStorage, deviceId: deviceId);
  }

  static CatalogSyncService _buildSyncService(
    ({
      AppDatabase database,
      app_storage.LocalStorage localStorage,
      String deviceId,
    })
    b,
    SyncApi api,
  ) {
    return CatalogSyncService(
      api: api,
      deviceId: b.deviceId,
      storage: b.localStorage,
      genreDao: b.database.genreDao,
      artworkDao: b.database.artworkDao,
      languageDao: b.database.languageDao,
      translationDao: b.database.translationDao,
      appLocalDao: b.database.appLocalDao,
    );
  }

  static Future<AppDependencies> create() async {
    final b = await _bootstrap();

    final settingsRepository = SettingsRepositoryImpl(b.localStorage);
    final syncApi = SyncApi();
    final syncService = _buildSyncService(b, syncApi);

    final appLocalsRepository = FloorAppLocalsRepository(
      b.database.appLocalDao,
    );

    final seeder = ArtworkCatalogSeeder(
      artworkDao: b.database.artworkDao,
      genreDao: b.database.genreDao,
    );

    final catalogRepository = CatalogRepositoryImpl(
      deviceId: b.deviceId,
      artworkDao: b.database.artworkDao,
      translationDao: b.database.translationDao,
    );

    final genreRepository = FloorGenreRepository(
      genreDao: b.database.genreDao,
      translationDao: b.database.translationDao,
    );

    final sound = AppSound.create();
    await sound.load();

    return AppDependencies(
      database: b.database,
      deviceId: b.deviceId,
      localStorage: b.localStorage,
      settingsRepository: settingsRepository,
      syncApi: syncApi,
      syncService: syncService,
      seeder: seeder,
      appLocalsRepository: appLocalsRepository,
      catalogRepository: catalogRepository,
      genreRepository: genreRepository,
      sound: sound,
    );
  }

  static Future<({CatalogSyncService syncService, SettingsRepository settings})>
  createSyncDeps() async {
    final b = await _bootstrap();
    return (
      syncService: _buildSyncService(b, SyncApi()),
      settings: SettingsRepositoryImpl(b.localStorage),
    );
  }
}
