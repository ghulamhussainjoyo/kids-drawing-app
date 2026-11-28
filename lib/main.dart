import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'package:flutter/services.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/core/audio/sound.route.observer.dart';
import 'package:kids_drawing_flutter/core/di/app.dependencies.dart';
import 'package:kids_drawing_flutter/core/i18n/language_code.dart';
import 'package:kids_drawing_flutter/core/sync/background.sync.worker.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/data/remote/sync.api.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

import 'app/splash/splash.screen.dart';
import 'core/ui/theme/app.theme.dart';
import 'state/drawing/drawing.view-model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );

  final deps = await AppDependencies.create();

  await registerBackgroundSync();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppSound>.value(value: deps.sound),
        Provider<SyncApi>.value(value: deps.syncApi),
        Provider<String>.value(value: deps.deviceId),
        Provider<ArtworkCatalogSeeder>.value(value: deps.seeder),
        Provider<CatalogSyncService>.value(value: deps.syncService),
        Provider<SettingsRepository>.value(value: deps.settingsRepository),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => SettingViewModel(
            deps.settingsRepository,
            deps.sound,
            deps.appLocalsRepository,
            syncService: deps.syncService,
            languageDao: deps.database.languageDao,
          )..load(),
        ),
        Provider<CatalogRepository>.value(value: deps.catalogRepository),
        ChangeNotifierProvider(
          create: (_) => GenreViewModel(
            genreRepository: deps.genreRepository,
            sound: deps.sound,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DrawingViewModel(
            catalogRepository: context.read<CatalogRepository>(),
            sound: deps.sound,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => GalleryViewModel(
            catalogRepository: context.read<CatalogRepository>(),
            drawingViewModel: context.read<DrawingViewModel>(),
            sound: deps.sound,
          ),
        ),
      ],
      child: AppWidget(routeObserver: SoundRouteObserver(deps.sound)),
    ),
  );
}

class AppWidget extends StatelessWidget {
  final SoundRouteObserver routeObserver;

  const AppWidget({super.key, required this.routeObserver});

  @override
  Widget build(BuildContext context) {
    return Selector<SettingViewModel, ({String lang, String dir})>(
      selector: (_, vm) => (lang: vm.language, dir: vm.languageDirection),
      builder: (_, s, _) => CupertinoApp(
        title: 'Kids Drawing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.data(),
        locale: Locale(LanguageCode.base(s.lang)),
        navigatorObservers: [routeObserver],
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        builder: (context, child) => Directionality(
          textDirection: s.dir == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
