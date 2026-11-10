import 'dart:math' as math;
import 'dart:ui';

import 'dab.buffer.dart';
import 'dab.tip.dart';

/// Lays out brush dabs along a stroke as its points arrive.
///
/// Points are smoothed with quadratic curves through segment midpoints. Each
/// new point finishes one curve segment, and only that segment gets new dabs,
/// so per-move cost stays constant however long the stroke grows. The
/// unfinished end of the stroke is laid out separately into a temporary
/// [tail] that is rebuilt on every [updateTail].
///
/// Per-dab jitter comes from a hash of the seed and the dab index, so feeding
/// the same points always yields the same dabs.
class StrokeDabber {
  StrokeDabber({
    required this.tip,
    required this.width,
    required this.seed,
    required this.colorAt,
  }) : _spacing = math.max(width * tip.spacing, 0.5);

  final DabTip tip;
  final double width;
  final int seed;
  final Color Function(double distance) colorAt;

  final double _spacing;
  final DabBuffer dabs = DabBuffer();
  final DabBuffer tail = DabBuffer();

  final List<Offset> _points = [];
  _Cursor _cursor = _Cursor.start();
  bool _finished = false;
  Rect? _bounds;

  /// Area the dabs may cover, including the tail.
  Rect? get bounds => _bounds;

  int get pointCount => _points.length;

  void addPoint(Offset point) {
    assert(!_finished);
    _points.add(point);
    _grow(point);
    final n = _points.length;
    if (n == 1) {
      _cursor = _cursor.walkLine(point, point, this, dabs);
    } else if (n >= 3) {
      final start = n == 3 ? _points[0] : _mid(_points[n - 3], _points[n - 2]);
      _cursor = _cursor.walkQuad(
        start,
        _points[n - 2],
        _mid(_points[n - 2], _points[n - 1]),
        this,
        dabs,
      );
    }
  }

  /// Lays out the unfinished end of the stroke, through the last stored point
  /// to [live], which may be a sample too close to keep.
  void updateTail([Offset? live]) {
    tail.clear();
    if (_points.isEmpty || _finished) return;
    if (live != null) _grow(live);
    _layoutEnd(live, tail);
  }

  /// Lays out the end of the stroke for good. No points may follow.
  void finish() {
    if (_finished || _points.isEmpty) return;
    tail.clear();
    _layoutEnd(null, dabs);
    _finished = true;
  }

  void _layoutEnd(Offset? live, DabBuffer into) {
    final last = _points.last;
    final from = _points.length >= 3
        ? _mid(_points[_points.length - 2], last)
        : _points.first;
    var cursor = _cursor.walkLine(from, last, this, into);
    if (live != null) cursor = cursor.walkLine(last, live, this, into);
    if (cursor.distance < _spacing) {
      for (var i = 1; i < tip.tapDabs; i++) {
        _stamp(
          into,
          _points.first,
          _hash(cursor.index + i, 7) * math.pi * 2,
          0,
          cursor.index + i,
        );
      }
    }
  }

  void _grow(Offset point) {
    final r = Rect.fromCircle(center: point, radius: width * tip.tipScale * 0.6);
    _bounds = _bounds?.expandToInclude(r) ?? r;
  }

  void _stamp(
    DabBuffer into,
    Offset position,
    double angle,
    double distance,
    int index,
  ) {
    final scale = width * tip.tipScale / tip.pixels * (0.92 + _hash(index, 1) * 0.16);
    final rotation = angle + (_hash(index, 2) - 0.5) * 0.12;
    final x = position.dx + (_hash(index, 3) - 0.5) * width * 0.03;
    final y = position.dy + (_hash(index, 4) - 0.5) * width * 0.03;
    final variant = (_hash(index, 5) * tip.variants).floor().clamp(0, tip.variants - 1);
    final color = colorAt(distance).withValues(alpha: tip.alpha);
    into.add(
      scale: scale,
      rotation: rotation,
      anchor: tip.pixels / 2,
      x: x,
      y: y,
      left: variant * tip.pixels,
      size: tip.pixels,
      color: color.toARGB32(),
    );
  }

  /// Deterministic value in [0, 1) for dab [index] and jitter [channel].
  double _hash(int index, int channel) {
    var h = (seed * 0x27d4eb2d) ^ (index * 0x165667b1) ^ (channel * 0x9e3779b9);
    h = (h ^ (h >> 15)) * 0x2c1b3c6d & 0xffffffff;
    h = (h ^ (h >> 12)) * 0x297a2d39 & 0xffffffff;
    h ^= h >> 15;
    return (h & 0xffffff) / 0x1000000;
  }

  static Offset _mid(Offset a, Offset b) => Offset.lerp(a, b, 0.5)!;
}

/// Walk state along the stroke: distance travelled, where the next dab goes
/// and how many dabs came before.
class _Cursor {
  const _Cursor(this.distance, this.nextDab, this.index);

  factory _Cursor.start() => const _Cursor(0, 0, 0);

  final double distance;
  final double nextDab;
  final int index;

  _Cursor walkLine(Offset a, Offset b, StrokeDabber dabber, DabBuffer into) {
    final delta = b - a;
    final length = delta.distance;
    final angle = math.atan2(delta.dy, delta.dx);
    var next = nextDab;
    var i = index;
    final end = distance + length;
    while (next <= end) {
      final t = length == 0 ? 0.0 : (next - distance) / length;
      dabber._stamp(into, Offset.lerp(a, b, t)!, angle, next, i);
      i++;
      next += dabber._spacing;
    }
    return _Cursor(end, next, i);
  }

  _Cursor walkQuad(
    Offset a,
    Offset control,
    Offset b,
    StrokeDabber dabber,
    DabBuffer into,
  ) {
    final rough = (control - a).distance + (b - control).distance;
    final steps = math.max(1, (rough / 2).ceil());
    var cursor = this;
    var previous = a;
    for (var s = 1; s <= steps; s++) {
      final t = s / steps;
      final u = 1 - t;
      final point = a * (u * u) + control * (2 * u * t) + b * (t * t);
      if (point != previous) {
        cursor = cursor.walkLine(previous, point, dabber, into);
      }
      previous = point;
    }
    return cursor;
  }
}
