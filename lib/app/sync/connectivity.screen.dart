import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/genre/screen/genre.screen.dart';
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/data/local/artwork/artwork.catalog.seeder.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

class ConnectivityScreen extends StatefulWidget {
  final CatalogSyncService syncService;
  final ArtworkCatalogSeeder seeder;
  final String deviceId;

  const ConnectivityScreen({
    super.key,
    required this.syncService,
    required this.seeder,
    required this.deviceId,
  });

  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  bool _syncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _listenForConnection();
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online && !_syncing) _startSync();
  }

  void _listenForConnection() {
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_syncing) {
        _startSync();
      }
    });
  }

  Future<void> _startSync() async {
    setState(() => _syncing = true);
    final lang = context.read<SettingViewModel>().language;
    final success = await widget.syncService.sync(language: lang);

    if (!success) {
      await widget.seeder.seedIfEmpty(widget.deviceId);
    }

    if (!mounted) return;
    context.read<SettingViewModel>().refreshLanguages();
    _navigateToGenres();
  }

  Future<void> _playOffline() async {
    setState(() => _syncing = true);
    await widget.seeder.seedIfEmpty(widget.deviceId);
    if (!mounted) return;
    _navigateToGenres();
  }

  void _navigateToGenres() {
    final lang = context.read<SettingViewModel>().language;
    context.read<GenreViewModel>().loadGenres(lang);
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (_) => const GenreScreen()),
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _syncing ? _buildSyncing() : _buildPrompt(),
        ),
      ),
    );
  }

  Widget _buildPrompt() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎨', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 24),
        Text(
          'Connect to load artworks!',
          textAlign: TextAlign.center,
          style: AppTypography.boldStyle(fontSize: 22),
        ),
        const SizedBox(height: 12),
        Text(
          'Turn on WiFi so we can download\nyour coloring pages.',
          textAlign: TextAlign.center,
          style: AppTypography.semiBoldStyle(
            fontSize: 15,
            color: const Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 200,
          height: 48,
          child: PressButton(
            onPressed: _startSync,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                "Let's Connect!",
                style: AppTypography.boldStyle(
                  fontSize: 16,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _playOffline,
          child: Text(
            'Play without internet',
            style: AppTypography.semiBoldStyle(
              fontSize: 14,
              color: const Color(0xFF999999),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyncing() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CupertinoActivityIndicator(radius: 16),
        const SizedBox(height: 16),
        Text(
          'Loading artworks...',
          style: AppTypography.semiBoldStyle(fontSize: 16),
        ),
      ],
    );
  }
}
