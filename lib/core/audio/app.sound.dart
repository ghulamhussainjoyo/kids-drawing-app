import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:kids_drawing_flutter/core/audio/ambience.player.dart';
import 'package:kids_drawing_flutter/core/audio/music.player.dart';
import 'package:kids_drawing_flutter/core/audio/sfx.player.dart';
import 'package:kids_drawing_flutter/core/audio/sound.assets.dart';
import 'package:kids_drawing_flutter/core/audio/touch.haptics.dart';
import 'package:kids_drawing_flutter/core/audio/voice.clips.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';
import 'package:kids_drawing_flutter/types/genre/genre.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

class AppSound with WidgetsBindingObserver {
  final SfxPlayer sfx;
  final MusicPlayer music;
  final AmbiencePlayer ambience;
  final VoiceClips clips;
  final TouchHaptics haptics;

  AppSound({
    required this.sfx,
    required this.music,
    required this.ambience,
    required this.clips,
    required this.haptics,
  });

  factory AppSound.create() {
    final soloud = SoLoud.instance;
    final sfx = SfxPlayer(soloud);
    return AppSound(
      sfx: sfx,
      music: MusicPlayer(soloud),
      ambience: AmbiencePlayer(sfx),
      clips: VoiceClips(soloud),
      haptics: TouchHaptics(),
    );
  }

  static const _sfxVolume = 0.8;
  static const _repeatWindow = Duration(milliseconds: 150);

  final Map<String, DateTime> _playedAt = {};

  bool _musicOn = true;
  bool _voiceOn = true;
  bool _sfxOn = true;
  bool _muted = true;
  String _trackId = 'puppy_playtime';
  String _language = 'en';
  int _speechGeneration = 0;

  String get language => _language;

  final Random _random = Random();
  final Map<String, int> _lastPick = {};

  Future<void> load() async {
    try {
      await SoLoud.instance.init();
    } catch (_) {}
    await sfx.warmUp(SoundAssets.uiSounds);
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> applyPreferences({
    required bool musicOn,
    required bool voiceOn,
    required bool sfxOn,
    required bool vibrationOn,
    required double volume,
    required String trackId,
    required String language,
  }) async {
    final sfxJustTurnedOn = sfxOn && !_sfxOn;
    _voiceOn = voiceOn;
    _sfxOn = sfxOn;
    _musicOn = musicOn;
    _trackId = trackId;

    haptics.setEnabled(vibrationOn);
    music.setVolume(volume);
    ambience.setVolume(volume);

    if (!sfxOn) await sfx.stopLoop();
    if (!voiceOn) {
      await clips.stop();
      music.unduck();
    }

    if (_language != language) {
      _language = language;
      await clips.setLanguage(language);
    }

    await ambience.setEnabled(musicOn);
    await music.setEnabled(musicOn);
    await _retrackMusic();

    if (sfxJustTurnedOn) {
      await sfx.play(SoundAssets.tapIn, volume: _sfxVolume);
    }
  }

  // ------------------------------------------------------------------ buttons

  void pressIn() => _playPress(SoundAssets.tapIn);
  void pressOut() => _playPress(SoundAssets.tapOut);

  void _playPress(String path) {
    if (_repeated(path)) return;
    haptics.tap();
    if (_sfxOn) sfx.play(path, volume: _sfxVolume);
  }

  bool _repeated(String path) {
    final now = DateTime.now();
    final last = _playedAt[path];
    _playedAt[path] = now;
    return last != null && now.difference(last) < _repeatWindow;
  }

  // --------------------------------------------------------------- background

  Future<void> playAppMusic() async {
    ambience.stop();
    await music.playTrack(_trackId);
  }

  Future<void> genreOpened(GenreModel genre) async {
    haptics.select();
    if (_sfxOn) sfx.play(SoundAssets.selectBell, volume: _sfxVolume);
    _speakFromPool('genre.${genre.id}', genre.voice);
    await music.stop();
    ambience.start(genre.ambience);
  }

  Future<void> canvasOpened() async {
    ambience.pause();
    await music.stop();
  }

  void genreResumed() => ambience.resume();

  // --------------------------------------------------------------- selections

  void artworkOpened({required String key, required String text}) {
    _playVoice(text);
  }

  void categorySelected(CategoryModel category) {
    _speakFromPool('category.${category.name}', category.voice);
  }

  void toolSelected(CategoryModel category, StationaryModel tool) {
    haptics.select();
    if (_sfxOn) sfx.play(SoundAssets.toolSelect, volume: _sfxVolume);
    _playVoice(tool.spokenName);
    sfx.preload(SoundAssets.drawPath(category.drawSound));
  }

  // ------------------------------------------------------------------- stroke

  void strokeBegan(CategoryModel category, Offset point) {
    haptics.strokeBegan(point);
    if (!_sfxOn) return;
    final path = SoundAssets.drawPath(category.drawSound);
    if (category.loopSound) {
      sfx.startLoop(path, volume: _sfxVolume);
    } else {
      sfx.play(path, volume: _sfxVolume);
    }
  }

  void strokeMoved(Offset point) => haptics.strokeMoved(point);

  void strokeEnded({required bool committed}) {
    haptics.strokeEnded();
    sfx.stopLoop();
    if (committed && _sfxOn) sfx.play(SoundAssets.burstPop, volume: _sfxVolume);
  }

  void strokeCancelled() {
    haptics.strokeEnded();
    sfx.stopLoop();
  }

  // ------------------------------------------------------------------- voice

  Future<void> _speakFromPool(String key, List<String> pool) async {
    if (pool.isEmpty || !_voiceOn) return;
    final text = pool[_pick(key, pool.length)];
    await _playVoice(text);
  }

  Future<void> _playVoice(String text) async {
    if (!_voiceOn || text.isEmpty) return;
    final generation = ++_speechGeneration;
    music.duck();
    await clips.speak(text);
    if (generation == _speechGeneration) music.unduck();
  }

  int _pick(String key, int count) {
    if (count < 2) return 0;
    final last = _lastPick[key];
    var index = _random.nextInt(count);
    if (index == last) index = (index + 1) % count;
    _lastPick[key] = index;
    return index;
  }

  // ------------------------------------------------------------------- music

  Future<void> _retrackMusic() async {
    if (_muted || !_musicOn || !ambience.isIdle) return;
    await music.playTrack(_trackId);
  }

  Future<void> unmute() async {
    _muted = false;
    await _retrackMusic();
  }

  // ---------------------------------------------------------------- lifecycle

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final leaving =
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden;
    if (leaving) {
      music.pause();
      ambience.pause();
      clips.stop();
      sfx.stopLoop();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      music.resume();
      ambience.resume();
    }
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    ambience.stop();
    await music.stop();
    await clips.dispose();
    await sfx.dispose();
  }
}
