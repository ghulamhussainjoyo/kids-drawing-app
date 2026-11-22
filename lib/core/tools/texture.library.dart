import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Image assets that tools paint with (pattern tiles, stickers), decoded once
/// and kept until [dispose]. Painting is synchronous, so callers [load] an
/// asset before any stroke needs it.
class TextureLibrary {
  final Map<String, ui.Image> _images = {};

  ui.Image? image(String? asset) {
    if (asset == null) return null;
    return _images[asset];
  }

  Future<void> load(String? asset) async {
    if (asset == null) return;
    if (_images.containsKey(asset)) return;
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    _images[asset] = frame.image;
  }

  void dispose() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
  }
}
