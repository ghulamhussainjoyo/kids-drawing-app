import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/data/local/device.id.store.dart';
import 'package:kids_drawing_flutter/data/local/floor/app.database.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/catalog.repository.impl.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';

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

  final database = await $FloorAppDatabase.databaseBuilder(DB_NAME).build();
  final deviceId = await DeviceIdStore().getOrCreate();
  final seeder = ArtworkCatalogSeeder(artworkDao: database.artworkDao);
  await seeder.seedMissing(deviceId);
  final catalogRepository = CatalogRepositoryImpl(
    deviceId: deviceId,
    artworkDao: database.artworkDao,
  );

  runApp(
    MultiProvider(
      providers: [
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
      home: const SplashScreen(),
    );
  }
}
