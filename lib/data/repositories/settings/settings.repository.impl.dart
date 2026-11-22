import 'package:kids_drawing_flutter/core/storage/local.storage.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _kGender = 'setting_gender';
  static const _kAgeRange = 'setting_age_range';
  static const _kInterests = 'setting_interests';
  static const _kVolume = 'setting_music_volume';
  static const _kTrack = 'setting_music_track';
  static const _kMusicOn = 'setting_music_on';
  static const _kVoiceOn = 'setting_voice_on';
  static const _kSfxOn = 'setting_sfx_on';
  static const _kVibrationOn = 'setting_vibration_on';
  static const _kLanguage = 'setting_language';
  static const _kLiveBackgroundOn = 'setting_live_background_on';

  final LocalStorage _localStorage;

  SettingsRepositoryImpl(this._localStorage);

  @override
  Future<String> gender() async {
    return _localStorage.getString(_kGender) ?? 'girl';
  }

  @override
  Future<void> setGender(String value) async {
    await _localStorage.setString(_kGender, value);
  }

  @override
  Future<String> ageRange() async {
    return _localStorage.getString(_kAgeRange) ?? '3–4';
  }

  @override
  Future<void> setAgeRange(String value) async {
    await _localStorage.setString(_kAgeRange, value);
  }

  @override
  Future<List<String>> interests() async {
    return _localStorage.getStringList(_kInterests) ?? [];
  }

  @override
  Future<void> setInterests(List<String> value) async {
    await _localStorage.setStringList(_kInterests, value);
  }

  @override
  Future<double> volume() async {
    return _localStorage.getDouble(_kVolume) ?? 0.45;
  }

  @override
  Future<void> setVolume(double value) async {
    await _localStorage.setDouble(_kVolume, value.clamp(0.0, 1.0));
  }

  @override
  Future<String> selectedTrack() async {
    return _localStorage.getString(_kTrack) ?? 'confetti_party';
  }

  @override
  Future<void> setTrack(String value) async {
    await _localStorage.setString(_kTrack, value);
  }

  @override
  Future<bool> musicOn() async {
    return _localStorage.getBool(_kMusicOn) ?? true;
  }

  @override
  Future<void> setMusicOn(bool value) async {
    await _localStorage.setBool(_kMusicOn, value);
  }

  @override
  Future<bool> voiceOn() async {
    return _localStorage.getBool(_kVoiceOn) ?? true;
  }

  @override
  Future<void> setVoiceOn(bool value) async {
    await _localStorage.setBool(_kVoiceOn, value);
  }

  @override
  Future<bool> sfxOn() async {
    return _localStorage.getBool(_kSfxOn) ?? true;
  }

  @override
  Future<void> setSfxOn(bool value) async {
    await _localStorage.setBool(_kSfxOn, value);
  }

  @override
  Future<bool> vibrationOn() async {
    return _localStorage.getBool(_kVibrationOn) ?? true;
  }

  @override
  Future<void> setVibrationOn(bool value) async {
    await _localStorage.setBool(_kVibrationOn, value);
  }

  @override
  Future<String> language() async {
    return _localStorage.getString(_kLanguage) ?? 'en_US';
  }

  @override
  Future<void> setLanguage(String value) async {
    await _localStorage.setString(_kLanguage, value);
  }

  @override
  Future<bool> liveBackgroundOn() async {
    return _localStorage.getBool(_kLiveBackgroundOn) ?? true;
  }

  @override
  Future<void> setLiveBackgroundOn(bool value) async {
    await _localStorage.setBool(_kLiveBackgroundOn, value);
  }
}
