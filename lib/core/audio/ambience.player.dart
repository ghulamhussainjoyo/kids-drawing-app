import 'dart:async';
import 'dart:math';

import 'package:kids_drawing_flutter/core/audio/sfx.player.dart';
import 'package:kids_drawing_flutter/core/audio/sound.assets.dart';

/// The background of a genre: a few short clips (birds, rain, a school bell)
/// played one at a time with a quiet gap between them, instead of one long
/// looping track. Cheaper to ship and it never gets repetitive.
class AmbiencePlayer {
  final SfxPlayer _sfx;

  AmbiencePlayer(this._sfx);

  static const _leadIn = Duration(milliseconds: 1500);
  static const _leadInSpread = Duration(milliseconds: 1500);
  static const _minGap = Duration(seconds: 8);
  static const _maxGap = Duration(seconds: 20);

  /// Ambience sits a little under the music level.
  static const _volumeFactor = 0.9;

  final Random _random = Random();

  /// The clips of the genre we are in, kept while paused.
  List<String> _clips = const [];
  Timer? _timer;
  String? _lastClip;
  bool _enabled = true;
  double _volume = 0.45;

  /// True when we are not inside a genre, so the music may play instead.
  bool get isIdle => _clips.isEmpty;

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) {
      return;
    }
    _enabled = value;
    if (!value) {
      _cancel();
      return;
    }
    _scheduleNext(_leadIn);
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
  }

  /// Enters a genre. Replaces whatever pool was playing.
  void start(List<String> clips) {
    _cancel();
    _clips = clips;
    _lastClip = null;
    if (clips.isEmpty || !_enabled) {
      return;
    }
    _scheduleNext(_leadIn + _spread());
    _warmUp();
  }

  /// Leaves the genre: no clip may fire after this.
  void stop() {
    _cancel();
    _clips = const [];
    _lastClip = null;
  }

  /// App went to the background. The pool is remembered.
  void pause() {
    _cancel();
  }

  void resume() {
    if (_clips.isEmpty || !_enabled || _timer != null) {
      return;
    }
    _scheduleNext(_leadIn);
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
  }

  Duration _spread() {
    return Duration(
      milliseconds: _random.nextInt(_leadInSpread.inMilliseconds),
    );
  }

  void _scheduleNext(Duration delay) {
    _cancel();
    _timer = Timer(delay, _playNext);
  }

  Future<void> _playNext() async {
    _timer = null;
    if (_clips.isEmpty || !_enabled) {
      return;
    }
    final clip = _pickClip();
    _lastClip = clip;
    _scheduleNext(_randomGap());
    await _sfx.play(
      SoundAssets.ambiencePath(clip),
      volume: _volume * _volumeFactor,
    );
  }

  /// Never the same clip twice in a row, so the genre feels alive.
  String _pickClip() {
    if (_clips.length == 1) {
      return _clips.first;
    }
    final choices = <String>[];
    for (final clip in _clips) {
      if (clip != _lastClip) {
        choices.add(clip);
      }
    }
    return choices[_random.nextInt(choices.length)];
  }

  Duration _randomGap() {
    final span = _maxGap.inMilliseconds - _minGap.inMilliseconds;
    return Duration(
      milliseconds: _minGap.inMilliseconds + _random.nextInt(span),
    );
  }

  Future<void> _warmUp() async {
    for (final clip in _clips) {
      await _sfx.preload(SoundAssets.ambiencePath(clip));
    }
  }
}
