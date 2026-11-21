import 'package:flutter/foundation.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  SettingViewModel(this._repository);

  String _gender = 'girl';
  String _ageRange = '3–4';
  List<String> _interests = [];
  double _volume = 0.45;
  String _selectedTrack = 'confetti_party';
  bool _musicOn = true;
  bool _voiceOn = true;
  bool _sfxOn = true;
  bool _vibrationOn = true;
  bool _liveBackgroundOn = true;
  String _language = 'en_US';

  String get gender => _gender;
  String get ageRange => _ageRange;
  List<String> get interests => List.unmodifiable(_interests);
  double get volume => _volume;
  String get selectedTrack => _selectedTrack;
  bool get musicOn => _musicOn;
  bool get voiceOn => _voiceOn;
  bool get sfxOn => _sfxOn;
  bool get vibrationOn => _vibrationOn;
  bool get liveBackgroundOn => _liveBackgroundOn;
  String get language => _language;

  String get pronoun {
    if (_gender == 'girl') {
      return 'she';
    }
    if (_gender == 'boy') {
      return 'he';
    }
    return 'they';
  }

  Future<void> load() async {
    _gender = await _repository.gender();
    _ageRange = await _repository.ageRange();
    _interests = await _repository.interests();
    _volume = await _repository.volume();
    _selectedTrack = await _repository.selectedTrack();
    _musicOn = await _repository.musicOn();
    _voiceOn = await _repository.voiceOn();
    _sfxOn = await _repository.sfxOn();
    _vibrationOn = await _repository.vibrationOn();
    _liveBackgroundOn = await _repository.liveBackgroundOn();
    _language = await _repository.language();
    notifyListeners();
  }

  Future<void> setGender(String value) async {
    _gender = value;
    notifyListeners();
    await _repository.setGender(value);
  }

  Future<void> setAgeRange(String value) async {
    _ageRange = value;
    notifyListeners();
    await _repository.setAgeRange(value);
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
    await _repository.setInterests(updated);
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    notifyListeners();
    await _repository.setVolume(_volume);
  }

  Future<void> setTrack(String value) async {
    _selectedTrack = value;
    notifyListeners();
    await _repository.setTrack(value);
  }

  Future<void> setMusicOn(bool value) async {
    _musicOn = value;
    notifyListeners();
    await _repository.setMusicOn(value);
  }

  Future<void> setVoiceOn(bool value) async {
    _voiceOn = value;
    notifyListeners();
    await _repository.setVoiceOn(value);
  }

  Future<void> setSfxOn(bool value) async {
    _sfxOn = value;
    notifyListeners();
    await _repository.setSfxOn(value);
  }

  Future<void> setVibrationOn(bool value) async {
    _vibrationOn = value;
    notifyListeners();
    await _repository.setVibrationOn(value);
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    await _repository.setLanguage(value);
  }

  Future<void> setLiveBackgroundOn(bool value) async {
    _liveBackgroundOn = value;
    notifyListeners();
    await _repository.setLiveBackgroundOn(value);
  }
}
