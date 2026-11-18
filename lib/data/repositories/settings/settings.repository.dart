abstract class SettingsRepository {
  Future<String> gender();
  Future<void> setGender(String value);

  Future<String> ageRange();
  Future<void> setAgeRange(String value);

  Future<List<String>> interests();
  Future<void> setInterests(List<String> value);

  Future<double> volume();
  Future<void> setVolume(double value);

  Future<String> selectedTrack();
  Future<void> setTrack(String value);

  Future<bool> musicOn();
  Future<void> setMusicOn(bool value);

  Future<bool> voiceOn();
  Future<void> setVoiceOn(bool value);

  Future<bool> sfxOn();
  Future<void> setSfxOn(bool value);

  Future<bool> vibrationOn();
  Future<void> setVibrationOn(bool value);

  Future<String> language();
  Future<void> setLanguage(String value);
}
