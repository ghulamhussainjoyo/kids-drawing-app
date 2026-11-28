import 'package:flutter/foundation.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/core/sync/catalog.sync.service.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.dao.dart';
import 'package:kids_drawing_flutter/data/local/floor/language.entity.dart';
import 'package:kids_drawing_flutter/data/repositories/settings/settings.repository.dart';

class SettingViewModel extends ChangeNotifier {
  final SettingsRepository _repository;
  final AppSound _sound;
  final CatalogSyncService? _syncService;
  final LanguageDao? _languageDao;

  SettingViewModel(
    this._repository,
    this._sound, {
    LanguageDao? languageDao,
    CatalogSyncService? syncService,
  }) : _syncService = syncService,
       _languageDao = languageDao;

  String _gender = 'girl';
  String _ageRange = '3–4';
  List<String> _interests = [];
  double _volume = 0.45;
  String _selectedTrack = 'puppy_playtime';
  bool _musicOn = true;
  bool _voiceOn = true;
  bool _sfxOn = true;
  bool _vibrationOn = true;
  bool _liveBackgroundOn = true;
  String _language = 'en_US';

  /// Null means no language sync in progress. 0.0–1.0 while downloading.
  double? _languageSyncProgress;

  /// The name of the language being synced (for the UI card heading).
  String? _syncingLanguageName;

  /// Available languages loaded from Floor.
  List<LanguageEntity> _availableLanguages = [];

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
  double? get languageSyncProgress => _languageSyncProgress;
  String? get syncingLanguageName => _syncingLanguageName;
  List<LanguageEntity> get availableLanguages =>
      List.unmodifiable(_availableLanguages);

  String get pronoun {
    if (_gender == 'girl') return 'she';
    if (_gender == 'boy') return 'he';
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
    await _loadLanguages();
    notifyListeners();
    await _applySound();
  }

  Future<void> _loadLanguages() async {
    if (_languageDao == null) return;
    _availableLanguages = await _languageDao.listActive();
  }

  Future<void> refreshLanguages() async {
    await _loadLanguages();
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
    await _applySound();
  }

  Future<void> setTrack(String value) async {
    _selectedTrack = value;
    notifyListeners();
    await _repository.setTrack(value);
    await _applySound();
  }

  Future<void> setMusicOn(bool value) async {
    _musicOn = value;
    notifyListeners();
    await _repository.setMusicOn(value);
    await _applySound();
  }

  Future<void> setVoiceOn(bool value) async {
    _voiceOn = value;
    notifyListeners();
    await _repository.setVoiceOn(value);
    await _applySound();
  }

  Future<void> setSfxOn(bool value) async {
    _sfxOn = value;
    notifyListeners();
    await _repository.setSfxOn(value);
    await _applySound();
  }

  Future<void> setVibrationOn(bool value) async {
    _vibrationOn = value;
    notifyListeners();
    await _repository.setVibrationOn(value);
    await _applySound();
  }

  Future<void> setLanguage(String value) async {
    final previousLang = _language;
    _language = value;
    notifyListeners();
    await _repository.setLanguage(value);
    await _applySound();

    final syncService = _syncService;
    if (syncService == null || value == previousLang) return;

    // Already on the device: it plays offline right now, no card. The daily
    // sync keeps it fresh.
    if (syncService.isLanguageReady(value)) {
      dismissLanguageSync();
      return;
    }
    _downloadLanguage(syncService, value);
  }

  /// Bumped on every switch so a slow download for an earlier choice cannot
  /// clear or update the card of the language picked after it.
  int _syncToken = 0;

  Future<void> _downloadLanguage(
    CatalogSyncService syncService,
    String code,
  ) async {
    final token = ++_syncToken;
    final entity = _availableLanguages.where((l) => l.code == code).firstOrNull;
    _syncingLanguageName = entity?.englishName ?? code;
    _languageSyncProgress = 0.0;
    notifyListeners();

    try {
      await syncService.syncLanguage(
        language: code,
        onProgress: (progress) {
          if (token != _syncToken) return;
          _languageSyncProgress = progress;
          notifyListeners();
        },
      );
    } catch (_) {
      // Offline or server error: the language is not marked ready, so the
      // next switch or the daily sync retries. The card must still close.
    }

    if (token != _syncToken) return;
    _languageSyncProgress = null;
    _syncingLanguageName = null;
    notifyListeners();
  }

  void dismissLanguageSync() {
    _syncToken++;
    _languageSyncProgress = null;
    _syncingLanguageName = null;
    notifyListeners();
  }

  Future<void> _applySound() async {
    await _sound.applyPreferences(
      musicOn: _musicOn,
      voiceOn: _voiceOn,
      sfxOn: _sfxOn,
      vibrationOn: _vibrationOn,
      volume: _volume,
      trackId: _selectedTrack,
      language: _language,
    );
  }

  Future<void> setLiveBackgroundOn(bool value) async {
    _liveBackgroundOn = value;
    notifyListeners();
    await _repository.setLiveBackgroundOn(value);
  }
}
