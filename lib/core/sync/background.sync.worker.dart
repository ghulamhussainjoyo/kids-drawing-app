import 'package:kids_drawing_flutter/core/di/app.dependencies.dart';
import 'package:workmanager/workmanager.dart';

const _taskName = 'catalogSync';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName != _taskName) return true;

    try {
      final deps = await AppDependencies.createSyncDeps();
      final lang = await deps.settings.language();
      await deps.syncService.sync(language: lang);
      return true;
    } on Exception catch (_) {
      // Return false so WorkManager retries with backoff.
      return false;
    }
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
  } on Exception catch (_) {
    // Silently degrade — foreground sync covers the same purpose.
  }
}
