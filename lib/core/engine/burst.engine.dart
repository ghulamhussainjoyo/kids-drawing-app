import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart' show Curves;

import 'burst.shapes.dart';

/// Celebration particles that pop out where a finger lifts.
///
/// Purely visual: nothing is saved or undoable. Positions are in screen
/// space, so particles keep their size at any zoom. Particles are immutable;
/// where one is at any moment is worked out from its age.
class BurstEngine {
  BurstEngine({math.Random? random}) : _random = random ?? math.Random();

  /// Seconds a particle lives.
  static const double lifetime = 1.0;
  static const double _popIn = 0.15;
  static const double _fadeOut = 0.4;
  static const double _gravity = 60;

  /// Smallest size a particle pops in from, as a share of its full size.
  static const double _startScale = 0.3;

  static const int _minCount = 10;
  static const int _extraCount = 4;
  static const double _minSpeed = 80;
  static const double _speedRange = 90;
  static const double _minSize = 14;
  static const double _sizeRange = 9;
  static const double _minStartOffset = 4;
  static const double _startOffsetRange = 8;
  static const double _maxSpin = 2;
  static const double _maxDelay = 0.08;

  /// How unevenly particles are spread around the circle (0 = evenly).
  static const double _angleJitter = 0.6;

  static const List<Color> _colors = [
    Color(0xFFFF4D6D),
    Color(0xFFFF9F1C),
    Color(0xFFFFD60A),
    Color(0xFF2EC4B6),
    Color(0xFF3A86FF),
    Color(0xFF8338EC),
    Color(0xFFFF66C4),
    Color(0xFF52B788),
  ];

  final math.Random _random;
  final List<_Particle> _particles = [];
  int _burstCount = 0;

  bool get isActive => _particles.isNotEmpty;

  /// Pops one burst at [origin]. Each burst uses the next shape in turn.
  void spawn(Offset origin, Duration now) {
    final shape = _nextShape();
    final born = _seconds(now);
    final count = _minCount + _random.nextInt(_extraCount);
    for (var i = 0; i < count; i++) {
      _particles.add(_createParticle(origin, i, count, shape, born));
    }
  }

  /// Paints every live particle at [now].
  void paint(Canvas canvas, Duration now) {
    final time = _seconds(now);
    _dropExpired(time);
    final fill = Paint();
    final detail = Paint();
    for (final particle in _particles) {
      final age = time - particle.born;
      if (age < 0) continue;
      _paintParticle(canvas, particle, age, fill, detail);
    }
  }

  BurstShape _nextShape() {
    final shape = BurstShape.values[_burstCount % BurstShape.values.length];
    _burstCount++;
    return shape;
  }

  /// Particle [index] of [count], flying out from [origin] in its own slice
  /// of the circle.
  _Particle _createParticle(
    Offset origin,
    int index,
    int count,
    BurstShape shape,
    double born,
  ) {
    final direction = _unit(_angleFor(index, count));
    return _Particle(
      shape: shape,
      origin:
          origin + direction * _randomIn(_minStartOffset, _startOffsetRange),
      velocity: direction * _randomIn(_minSpeed, _speedRange),
      color: _colors[_random.nextInt(_colors.length)],
      size: _randomIn(_minSize, _sizeRange),
      rotation: _random.nextDouble() * math.pi * 2,
      spin: _randomIn(-_maxSpin, _maxSpin * 2),
      born: born + _random.nextDouble() * _maxDelay,
    );
  }

  double _angleFor(int index, int count) {
    final slice = index + _random.nextDouble() * _angleJitter;
    return slice / count * math.pi * 2;
  }

  double _randomIn(double min, double range) {
    return min + _random.nextDouble() * range;
  }

  void _dropExpired(double time) {
    _particles.removeWhere((particle) => time - particle.born > lifetime);
  }

  void _paintParticle(
    Canvas canvas,
    _Particle particle,
    double age,
    Paint fill,
    Paint detail,
  ) {
    final position = _positionAt(particle, age);
    final opacity = _opacityAt(age);
    fill.color = particle.color.withValues(alpha: opacity);
    canvas
      ..save()
      ..translate(position.dx, position.dy)
      ..rotate(particle.rotation + particle.spin * age)
      ..scale(particle.size * _scaleAt(age));
    particle.shape.paint(canvas, fill, detail, opacity);
    canvas.restore();
  }

  /// Ease-out travel (full speed at birth, at rest by the end of its life)
  /// plus a little gravity.
  Offset _positionAt(_Particle particle, double age) {
    final travel = age - age * age / (2 * lifetime);
    final fall = Offset(0, _gravity * age * age / 2);
    return particle.origin + particle.velocity * travel + fall;
  }

  /// Pops in with a small overshoot, then holds its full size.
  double _scaleAt(double age) {
    final progress = math.min(1.0, age / _popIn);
    final pop = Curves.easeOutBack.transform(progress);
    return _startScale + (1 - _startScale) * pop;
  }

  /// Fully visible until the last [_fadeOut] seconds, then fades away.
  double _opacityAt(double age) {
    final remaining = lifetime - age;
    return (remaining / _fadeOut).clamp(0.0, 1.0);
  }

  static Offset _unit(double angle) => Offset(math.cos(angle), math.sin(angle));

  static double _seconds(Duration duration) {
    return duration.inMicroseconds / Duration.microsecondsPerSecond;
  }
}

class _Particle {
  const _Particle({
    required this.shape,
    required this.origin,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.born,
  });

  final BurstShape shape;
  final Offset origin;
  final Offset velocity;
  final Color color;
  final double size;
  final double rotation;
  final double spin;

  /// Engine time, in seconds, when the particle appears.
  final double born;
}
