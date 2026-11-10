import 'dart:math' as math;
import 'dart:typed_data';

/// Growable buffers in the layout `Canvas.drawRawAtlas` expects.
class DabBuffer {
  Float32List _transforms = Float32List(256);
  Float32List _rects = Float32List(256);
  Int32List _colors = Int32List(64);
  int _count = 0;

  int get count => _count;

  Float32List get transforms => Float32List.sublistView(_transforms, 0, _count * 4);
  Float32List get rects => Float32List.sublistView(_rects, 0, _count * 4);
  Int32List get colors => Int32List.sublistView(_colors, 0, _count);

  void clear() => _count = 0;

  void add({
    required double scale,
    required double rotation,
    required double anchor,
    required double x,
    required double y,
    required double left,
    required double size,
    required int color,
  }) {
    if (_count == _colors.length) _grow();
    final scos = math.cos(rotation) * scale;
    final ssin = math.sin(rotation) * scale;
    final i = _count * 4;
    _transforms
      ..[i] = scos
      ..[i + 1] = ssin
      ..[i + 2] = x - scos * anchor + ssin * anchor
      ..[i + 3] = y - ssin * anchor - scos * anchor;
    _rects
      ..[i] = left
      ..[i + 1] = 0
      ..[i + 2] = left + size
      ..[i + 3] = size;
    _colors[_count] = color;
    _count++;
  }

  void _grow() {
    _transforms = Float32List(_transforms.length * 2)..setAll(0, _transforms);
    _rects = Float32List(_rects.length * 2)..setAll(0, _rects);
    _colors = Int32List(_colors.length * 2)..setAll(0, _colors);
  }
}
