import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository extends ChangeNotifier {
  static const _kGender = 'setting_gender';
  static const _kAgeRange = 'setting_age_range';
  static const _kInterests = 'setting_interests';
  static const _kVolume = 'setting_music_volume';
  static const _kTrack = 'setting_music_track';
  static const _kVoiceOn = 'setting_voice_on';
  static const _kSfxOn = 'setting_sfx_on';
  static const _kVibrationOn = 'setting_vibration_on';
  static const _kLanguage = 'setting_language';

  String _gender = 'girl';
  String _ageRange = '3–4';
  List<String> _interests = [];
  double _volume = 0.45;
  String _selectedTrack = 'confetti_party';
  bool _voiceOn = true;
  bool _sfxOn = true;
  bool _vibrationOn = true;
  String _language = 'en_US';

  String get gender => _gender;
  String get ageRange => _ageRange;
  List<String> get interests => List.unmodifiable(_interests);
  double get volume => _volume;
  String get selectedTrack => _selectedTrack;
  bool get voiceOn => _voiceOn;
  bool get sfxOn => _sfxOn;
  bool get vibrationOn => _vibrationOn;
  String get language => _language;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _gender = prefs.getString(_kGender) ?? _gender;
    _ageRange = prefs.getString(_kAgeRange) ?? _ageRange;
    _interests = prefs.getStringList(_kInterests) ?? _interests;
    _volume = prefs.getDouble(_kVolume) ?? _volume;
    _selectedTrack = prefs.getString(_kTrack) ?? _selectedTrack;
    _voiceOn = prefs.getBool(_kVoiceOn) ?? _voiceOn;
    _sfxOn = prefs.getBool(_kSfxOn) ?? _sfxOn;
    _vibrationOn = prefs.getBool(_kVibrationOn) ?? _vibrationOn;
    _language = prefs.getString(_kLanguage) ?? _language;
    notifyListeners();
  }

  Future<void> setGender(String value) async {
    _gender = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGender, value);
  }

  Future<void> setAgeRange(String value) async {
    _ageRange = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAgeRange, value);
  }

  Future<void> toggleInterest(String genreId) async {
    final updated = List<String>.from(_interests);
    if (updated.contains(genreId)) {
      updated.remove(genreId);
    } else {
      updated.add(genreId);
    }
    _interests = updated;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kInterests, updated);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kVolume, _volume);
  }

  Future<void> setTrack(String value) async {
    _selectedTrack = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTrack, value);
  }

  Future<void> setVoiceOn(bool value) async {
    _voiceOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVoiceOn, value);
  }

  Future<void> setSfxOn(bool value) async {
    _sfxOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSfxOn, value);
  }

  Future<void> setVibrationOn(bool value) async {
    _vibrationOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVibrationOn, value);
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, value);
  }
}
