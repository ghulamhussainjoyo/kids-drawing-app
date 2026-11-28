import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:kids_drawing_flutter/core/audio/sound.assets.dart';

/// The looping background track. Decoded into memory so the loop has no
/// gap at the seam, which streaming an MP3 from disk cannot promise.
///
/// A track id with no file behind it simply plays nothing.
class MusicPlayer {
  final SoLoud _soloud;

  MusicPlayer(this._soloud);

  /// How loud the music sits under a spoken line.
  static const _duckFactor = 0.35;

  /// What a track with no file of its own plays instead, so every row in the
  /// music panel makes a sound until its real file is dropped in.
  static const _fallbackTrackId = 'puppy_playtime';

  final Map<String, AudioSource> _tracks = {};
  final Set<String> _missing = {};

  bool _enabled = true;
  double _volume = 0.45;
  bool _ducked = false;

  /// The track that should be playing, even while it is stopped or paused.
  String? _wantedTrack;
  SoundHandle? _handle;
  int _generation = 0;

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    if (!value) {
      await _stopPlayback();
      return;
    }
    await _startWanted();
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _applyVolume();
  }

  /// Pulls the music down while a voice line plays.
  void duck() {
    if (_ducked) {
      return;
    }
    _ducked = true;
    _applyVolume();
  }

  void unduck() {
    if (!_ducked) {
      return;
    }
    _ducked = false;
    _applyVolume();
  }

  Future<void> playTrack(String trackId) async {
    if (_wantedTrack == trackId && _handle != null) {
      return;
    }
    await _stopPlayback();
    _wantedTrack = trackId;
    await _startWanted();
  }

  Future<void> stop() async {
    _wantedTrack = null;
    await _stopPlayback();
  }

  /// App went to the background: keep the position, stop the sound.
  void pause() {
    _setPaused(true);
  }

  void resume() {
    final handle = _handle;
    if (handle == null) {
      _startWanted();
      return;
    }
    _setPaused(false);
  }

  Future<void> _startWanted() async {
    final trackId = _wantedTrack;
    if (trackId == null || !_enabled) {
      return;
    }
    final generation = _generation;
    final track = await _track(trackId);
    if (track == null) {
      return;
    }
    // Stopped or switched while the track was decoding.
    if (generation != _generation || _wantedTrack != trackId) {
      return;
    }
    try {
      _handle = _soloud.play(track, volume: _currentVolume(), looping: true);
    } on SoLoudException {
      _handle = null;
    }
  }

  Future<void> _stopPlayback() async {
    _generation++;
    final handle = _handle;
    _handle = null;
    if (handle == null) {
      return;
    }
    try {
      await _soloud.stop(handle);
    } on SoLoudException {
      return;
    }
  }

  void _setPaused(bool paused) {
    final handle = _handle;
    if (handle == null) {
      return;
    }
    try {
      _soloud.setPause(handle, paused);
    } on SoLoudException {
      return;
    }
  }

  double _currentVolume() {
    if (_ducked) {
      return _volume * _duckFactor;
    }
    return _volume;
  }

  void _applyVolume() {
    final handle = _handle;
    if (handle == null) {
      return;
    }
    try {
      _soloud.setVolume(handle, _currentVolume());
    } on SoLoudException {
      return;
    }
  }

  Future<AudioSource?> _track(String trackId) async {
    final loaded = _tracks[trackId];
    if (loaded != null) {
      return loaded;
    }
    if (_missing.contains(trackId)) {
      return null;
    }
    final track = await _load(trackId) ?? await _load(_fallbackTrackId);
    if (track == null) {
      _missing.add(trackId);
      return null;
    }
    // Kept under the id that was asked for, so the day `sunshine_skip.mp3`
    // lands it is picked up without anything else changing.
    _tracks[trackId] = track;
    return track;
  }

  Future<AudioSource?> _load(String trackId) async {
    try {
      return await _soloud.loadAsset(SoundAssets.musicPath(trackId));
    } catch (_) {
      return null;
    }
  }
}
