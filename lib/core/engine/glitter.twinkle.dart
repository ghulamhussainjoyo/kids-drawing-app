import 'dart:ui';

import 'package:flutter/foundation.dart' show debugPrint;

/// Loads the twinkle shader and builds the paint that draws a baked glitter
/// image with it. If the shader fails to load, [paintFor] returns null and the
/// caller draws the image statically instead.
class GlitterTwinkle {
  static const String asset = 'shaders/glitter.frag';

  /// Grain cell size, in pixels of the baked image.
  static const double grain = 3;

  FragmentShader? _shader;
  Future<void>? _load;

  bool get isReady => _shader != null;

  Future<void> ensureLoaded() => _load ??= _loadProgram();

  Future<void> _loadProgram() async {
    try {
      final program = await FragmentProgram.fromAsset(asset);
      _shader = program.fragmentShader();
    } catch (error) {
      debugPrint(
        'GlitterTwinkle: shader failed to load, using static glitter: $error',
      );
    }
  }

  /// Paint for drawing [image] over a square of side [size] with the twinkle.
  Paint? paintFor({
    required Image image,
    required double seconds,
    required double width,
    required double height,
    double? imagePixels,
  }) {
    final shader = _shader;
    if (shader == null) return null;
    final pixels = imagePixels ?? image.width.toDouble();
    shader
      ..setFloat(0, width)
      ..setFloat(1, height)
      ..setFloat(2, seconds % 600)
      ..setFloat(3, grain)
      ..setFloat(4, pixels)
      ..setImageSampler(0, image);
    return Paint()..shader = shader;
  }

  void dispose() {
    _shader?.dispose();
    _shader = null;
  }
}
