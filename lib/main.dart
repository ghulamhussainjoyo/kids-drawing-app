import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:kids_drawing_flutter/core/storage/local.storage.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.impl.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/data/local/device.id.store.dart';
import 'package:kids_drawing_flutter/data/local/floor/app.database.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.impl.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/splash/splash.screen.dart';
import 'core/ui/theme/app.theme.dart';
import 'state/drawing/drawing.view-model.dart';

final DB_NAME = 'kids_drawing.db';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

  final deviceId = await DeviceIdStore().getOrCreate();
  final database = await $FloorAppDatabase.databaseBuilder(DB_NAME).build();

  await ArtworkCatalogSeeder(artworkDao: database.artworkDao)
      .seedMissing(deviceId);

  final catalogRepository = CatalogRepositoryImpl(
    deviceId: deviceId,
    artworkDao: database.artworkDao,
  );

  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorage(prefs);
  final settingsRepository = SettingsRepositoryImpl(localStorage);

  runApp(
    MultiProvider(
      providers: [
        Provider<SettingsRepository>.value(value: settingsRepository),
        ChangeNotifierProvider(
          create: (_) => SettingViewModel(settingsRepository)..load(),
        ),
        Provider<CatalogRepository>.value(value: catalogRepository),
        ChangeNotifierProvider(create: (_) => GenreViewModel()),
        ChangeNotifierProvider(
          create: (context) => DrawingViewModel(
            catalogRepository: context.read<CatalogRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => GalleryViewModel(
            catalogRepository: context.read<CatalogRepository>(),
            drawingViewModel: context.read<DrawingViewModel>(),
          ),
        ),
      ],
      child: const AppWidget(),
    ),
  );
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Kids Drawing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.data(),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
