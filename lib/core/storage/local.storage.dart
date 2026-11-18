import 'package:shared_preferences/shared_preferences.dart';

/// Thin prefs API. No domain key names here.
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  List<String>? getStringList(String key) => _prefs.getStringList(key);

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }
}
