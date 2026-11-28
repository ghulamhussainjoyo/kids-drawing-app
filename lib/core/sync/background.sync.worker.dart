import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kids_drawing_flutter/core/storage/local.storage.dart'
    as app_storage;
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/data/local/device.id.store.dart';
import 'package:kids_drawing_flutter/data/local/floor/app.database.dart';
import 'package:kids_drawing_flutter/data/remote/sync.api.dart';
import 'package:kids_drawing_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = 'catalogSync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _taskName) return true;

    await dotenv.load(fileName: '.env');
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

    final syncService = CatalogSyncService(
      api: SyncApi(),
      languageDao: database.languageDao,
      genreDao: database.genreDao,
      artworkDao: database.artworkDao,
      translationDao: database.translationDao,
      storage: localStorage,
      deviceId: deviceId,
    );

    final lang = prefs.getString('language') ?? 'en';
    await syncService.sync(language: lang);
    return true;
  });
}

Future<void> registerBackgroundSync() async {
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  } catch (_) {
    // Silently degrade — foreground sync covers the same purpose.
  }
}
