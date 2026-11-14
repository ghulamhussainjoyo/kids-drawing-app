import 'package:shared_preferences/shared_preferences.dart';

/// Stable per-install device id for Stage 1 catalog rows.
class DeviceIdStore {
  static const _key = 'device_id';

  Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final created = 'dev-${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_key, created);
    return created;
  }
}
