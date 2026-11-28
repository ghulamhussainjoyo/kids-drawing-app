import 'package:flutter_soloud/flutter_soloud.dart';

/// Short sounds: taps, selects, the stroke loop. Loads each clip once and
/// keeps it in memory, because a click that waits for a decoder feels broken.
///
/// A clip that fails to load is remembered as missing and silently skipped,
/// so the app still works while the audio files are being authored.
///
/// This class plays what it is told to. Which settings toggle governs a
/// sound is decided in [AppSound], because ambience follows Music while
/// taps follow Sound Effects.
class SfxPlayer {
  final SoLoud _soloud;

  SfxPlayer(this._soloud);

  final Map<String, AudioSource> _sources = {};
  final Map<String, Future<AudioSource?>> _loading = {};
  final Set<String> _missing = {};

  SoundHandle? _loopHandle;
  int _loopGeneration = 0;

  /// Decodes the clips the app taps most, before anyone taps them.
  Future<void> warmUp(List<String> paths) async {
    for (final path in paths) {
      await _source(path);
    }
  }

  Future<void> preload(String path) async {
    await _source(path);
  }

  Future<void> play(String path, {double volume = 1}) async {
    final source = await _source(path);
    if (source == null) {
      return;
    }
    try {
      _soloud.play(source, volume: volume);
    } on SoLoudException {
      return;
    }
  }

  /// Starts the one looping sound (a stroke in progress). A second call
  /// replaces the first.
  Future<void> startLoop(String path, {double volume = 1}) async {
    await stopLoop();
    final generation = _loopGeneration;
    final source = await _source(path);
    if (source == null) {
      return;
    }
    // The finger may have lifted while the clip was still loading.
    if (generation != _loopGeneration) {
      return;
    }
    try {
      _loopHandle = _soloud.play(source, volume: volume, looping: true);
    } on SoLoudException {
      _loopHandle = null;
    }
  }

  Future<void> stopLoop() async {
    _loopGeneration++;
    final handle = _loopHandle;
    _loopHandle = null;
    if (handle == null) {
      return;
    }
    try {
      await _soloud.stop(handle);
    } on SoLoudException {
      return;
    }
  }

  Future<AudioSource?> _source(String path) async {
    final loaded = _sources[path];
    if (loaded != null) {
      return loaded;
    }
    if (_missing.contains(path)) {
      return null;
    }
    final pending = _loading[path];
    if (pending != null) {
      return pending;
    }
    final load = _load(path);
    _loading[path] = load;
    final source = await load;
    _loading.remove(path);
    return source;
  }

  Future<AudioSource?> _load(String path) async {
    try {
      final source = await _soloud.loadAsset(path);
      _sources[path] = source;
      return source;
    } catch (_) {
      // Missing file, unsupported format, or no audio engine: stay quiet.
      _missing.add(path);
      return null;
    }
  }

  Future<void> dispose() async {
    await stopLoop();
    for (final source in _sources.values) {
      try {
        await _soloud.disposeSource(source);
      } catch (_) {
        continue;
      }
    }
    _sources.clear();
  }
}
