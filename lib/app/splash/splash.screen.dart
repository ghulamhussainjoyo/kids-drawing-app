import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/genre/screen/genre.screen.dart';
import 'package:kids_drawing_flutter/app/sync/connectivity.screen.dart';
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final syncService = context.read<CatalogSyncService>();
    final hasCatalog = await syncService.hasLocalCatalog();

    // Brief brand flash — at least 1 s so the splash is visible.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    if (hasCatalog) {
      _openGenres();
      _backgroundSyncIfStale(syncService);
    } else {
      _openConnectivity();
    }
  }

  void _openGenres() {
    final lang = context.read<SettingViewModel>().language;
    context.read<GenreViewModel>().loadGenres(lang);
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const GenreScreen()),
    );
  }

  void _openConnectivity() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (_) => ConnectivityScreen(
          syncService: context.read<CatalogSyncService>(),
          seeder: context.read<ArtworkCatalogSeeder>(),
          deviceId: context.read<String>(),
        ),
      ),
    );
  }

  void _backgroundSyncIfStale(CatalogSyncService syncService) {
    if (!syncService.isSyncStale()) return;
    final lang = context.read<SettingViewModel>().language;
    syncService.sync(language: lang).then((_) {
      if (!mounted) return;
      context.read<GenreViewModel>().loadGenres(lang);
      context.read<SettingViewModel>().refreshLanguages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Text(
          'Splash',
          style: AppTypography.boldStyle(color: const Color(0xFF000000)),
        ),
      ),
    );
  }
}
