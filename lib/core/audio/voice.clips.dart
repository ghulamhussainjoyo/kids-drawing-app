import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';
class VoiceClips {
  final SoLoud _soloud;

  VoiceClips(this._soloud);

  /// Longest a slug may be before the hash is appended.
  static const _slugLimit = 48;

  String _language = 'en';
  final Map<String, Directory> _downloads = {};

  final Map<String, AudioSource> _sources = {};

  /// Names the bundle does not have. The bundle cannot change while the app
  /// runs, so this is safe to remember; a downloaded file is re-checked every
  /// time, because the sync may have just written it.
  final Set<String> _unbundled = {};

  SoundHandle? _handle;
  int _generation = 0;

  /// The filename a line's clip has, everywhere — in the bundle, on the
  /// device, and in the storage bucket the admin dashboard uploads to.
  ///
  /// Lowercase, non-letters collapsed to `_`, trimmed, plus a hash of the
  /// whole line so two long lines can never land on the same file.
  static String fileNameFor(String text) {
    final normalized = text.trim().toLowerCase();
    final slug = normalized
        .replaceAll(RegExp('[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final short = slug.length <= _slugLimit
        ? slug
        : slug.substring(0, _slugLimit).replaceAll(RegExp(r'_+$'), '');
    return '${short}_${_hash(normalized)}.mp3';
  }

  /// FNV-1a, so the dashboard can reproduce it in a dozen lines of any
  /// language.
  static String _hash(String text) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(text)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// `en_US` and `en-GB` both read the `en` clips.
  Future<void> setLanguage(String languageCode) async {
    final base = languageCode.toLowerCase().split(RegExp('[-_]')).first;
    if (base.isEmpty || base == _language) {
      return;
    }
    _language = base;
    _sources.clear();
    _unbundled.clear();
  }

  /// Plays [text] and completes when the clip ends. False means no clip
  /// exists for this line.
  Future<bool> speak(String text) async {
    final name = fileNameFor(text);
    debugPrint('[Voice] speak: $_language/$name');
    final source = await _source(text);
    if (source == null) {
      debugPrint('[Voice] not found: $_language/$name');
      return false;
    }
    await stop();
    final generation = ++_generation;
    try {
      _handle = _soloud.play(source);
    } on SoLoudException {
      _handle = null;
      return false;
    }
    await Future<void>.delayed(_soloud.getLength(source));
    if (generation == _generation) {
      _handle = null;
    }
    return true;
  }

  Future<void> stop() async {
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

  Future<AudioSource?> _source(String text) async {
    final name = fileNameFor(text);
    final loaded = _sources[name];
    if (loaded != null) {
      return loaded;
    }
    final source = await _fromBundle(name) ?? await _fromDownloads(name);
    if (source == null) {
      return null;
    }
    _sources[name] = source;
    return source;
  }

  Future<AudioSource?> _fromBundle(String name) async {
    if (_unbundled.contains(name)) {
      return null;
    }
    try {
      return await _soloud.loadAsset('assets/voice/$_language/$name');
    } catch (_) {
      _unbundled.add(name);
      return null;
    }
  }

  Future<AudioSource?> _fromDownloads(String name) async {
    final directory = await _downloadsDirectory(_language);
    if (directory == null) return null;
    final file = File('${directory.path}/$name');
    if (!file.existsSync()) {
      debugPrint('[Voice] not on disk: $name');
      return null;
    }
    try {
      return await _soloud.loadFile(file.path);
    } catch (_) {
      return null;
    }
  }

  /// Where the daily artwork sync puts the clips it downloads. One folder per
  /// language, because the same line in two languages has the same filename.
  Future<Directory?> _downloadsDirectory(String language) async {
    final known = _downloads[language];
    if (known != null) {
      return known;
    }
    try {
      final support = await getApplicationSupportDirectory();
      final directory = Directory('${support.path}/voice/$language');
      _downloads[language] = directory;
      return directory;
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    await stop();
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
