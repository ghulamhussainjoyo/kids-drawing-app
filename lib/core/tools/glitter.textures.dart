import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_svg/svg.dart' as svg;

/// Neutral glitter grain for [GlitterTool] (tinted per stroke via modulate).
class GlitterTextures {
  static const String grainAsset = 'assets/brushes/glitter-texture.svg';
  static const double stampCell = 80;
  static const int rasterPixels = 256;

  /// White RGB; alpha from luma so a flat color field drops out after threshold.
  static const ui.ColorFilter _speckFromLuma = ui.ColorFilter.matrix([
    0,
    0,
    0,
    0,
    255,
    0,
    0,
    0,
    0,
    255,
    0,
    0,
    0,
    0,
    255,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
  ]);

  ui.Image? _grain;
  Future<void>? _loadFuture;

  static const int variantCount = 1;

  int get variants => variantCount;

  ui.Image? get grain => _grain;

  Future<void> ensureLoaded() {
    _loadFuture ??= _loadGrain();
    return _loadFuture!;
  }

  Future<void> _loadGrain() async {
    ui.Image? candidate;
    try {
      candidate = await _rasterSvgGrain();
      if (await _isTooSolid(candidate)) {
        candidate.dispose();
        candidate = null;
      }
    } catch (_) {
      candidate?.dispose();
      candidate = null;
    }
    _grain = candidate ?? _buildSpeckFallback(rasterPixels);
  }

  Future<ui.Image> _rasterSvgGrain() async {
    final pictureInfo = await svg.vg.loadPicture(
      const svg.SvgAssetLoader(grainAsset),
      null,
    );
    final srcSize = pictureInfo.size;
    final side = rasterPixels;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final scale = side / srcSize.width;
    final layer = ui.Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble());
    canvas.saveLayer(
      layer,
      ui.Paint()..colorFilter = _speckFromLuma,
    );
    canvas.scale(scale, scale);
    canvas.drawPicture(pictureInfo.picture);
    canvas.restore();
    pictureInfo.picture.dispose();
    final picture = recorder.endRecording();
    final image = await picture.toImage(side, side);
    picture.dispose();
    return _keepBrightSpecks(image);
  }

  /// Drops low-alpha and mid-tone fill; keeps bright glitter specks only.
  Future<ui.Image> _keepBrightSpecks(ui.Image image) async {
    final w = image.width;
    final h = image.height;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return image;
    final bytes = Uint8List.fromList(data.buffer.asUint8List());
    final pixels = bytes.length ~/ 4;
    for (var i = 0; i < pixels; i++) {
      final o = i * 4;
      final r = bytes[o];
      final g = bytes[o + 1];
      final b = bytes[o + 2];
      final a = bytes[o + 3];
      final luma = (r + g + b) / 3;
      if (a < 24 || luma < 200) {
        bytes[o + 3] = 0;
      } else {
        bytes[o] = 255;
        bytes[o + 1] = 255;
        bytes[o + 2] = 255;
      }
    }
    image.dispose();
    return _imageFromRgba(bytes, w, h);
  }

  Future<ui.Image> _imageFromRgba(Uint8List bytes, int w, int h) {
    final done = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      bytes,
      w,
      h,
      ui.PixelFormat.rgba8888,
      done.complete,
    );
    return done.future;
  }

  static Future<bool> _isTooSolid(ui.Image image) async {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) return true;
    final bytes = data.buffer.asUint8List();
    final pixels = bytes.length ~/ 4;
    var visible = 0;
    for (var i = 0; i < pixels; i++) {
      if (bytes[i * 4 + 3] > 20) visible++;
    }
    return visible / pixels > 0.22;
  }

  static ui.Image _buildSpeckFallback(int side) {
    final random = Random(41);
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final count = side * 18;
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * side;
      final y = random.nextDouble() * side;
      final s = 0.6 + random.nextDouble() * 2.2;
      final a = 0.35 + random.nextDouble() * 0.65;
      canvas.drawRect(
        ui.Rect.fromLTWH(x, y, s, s),
        ui.Paint()..color = ui.Color.fromRGBO(255, 255, 255, a),
      );
    }
    final picture = recorder.endRecording();
    final image = picture.toImageSync(side, side);
    picture.dispose();
    return image;
  }

  void dispose() {
    _grain?.dispose();
    _grain = null;
    _loadFuture = null;
  }
}