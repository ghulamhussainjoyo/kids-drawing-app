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
    final shape = BurstShape.values[_burstCount++ % BurstShape.values.length];
    final count = 10 + _random.nextInt(4);
    final born = _seconds(now);
    for (var i = 0; i < count; i++) {
      final angle = (i + _random.nextDouble() * 0.6) / count * math.pi * 2;
      final speed = 80 + _random.nextDouble() * 90;
      _particles.add(
        _Particle(
          shape: shape,
          origin: origin + _unit(angle) * (4 + _random.nextDouble() * 8),
          velocity: _unit(angle) * speed,
          color: _colors[_random.nextInt(_colors.length)],
          size: 14 + _random.nextDouble() * 9,
          rotation: _random.nextDouble() * math.pi * 2,
          spin: (_random.nextDouble() - 0.5) * 4,
          born: born + _random.nextDouble() * 0.08,
        ),
      );
    }
  }

  void clear() => _particles.clear();

  /// Paints every live particle at [now] and forgets the expired ones.
  void paint(Canvas canvas, Duration now) {
    final time = _seconds(now);
    _particles.removeWhere((p) => time - p.born > lifetime);
    final fill = Paint();
    final detail = Paint();
    for (final particle in _particles) {
      final age = time - particle.born;
      if (age < 0) continue;
      _paintParticle(canvas, particle, age, fill, detail);
    }
  }

  void _paintParticle(
    Canvas canvas,
    _Particle p,
    double age,
    Paint fill,
    Paint detail,
  ) {
    // Ease-out travel: full speed at birth, at rest by the end of its life.
    final travel = age - age * age / (2 * lifetime);
    final position =
        p.origin + p.velocity * travel + Offset(0, _gravity * age * age / 2);
    final pop = Curves.easeOutBack.transform(math.min(1, age / _popIn));
    final opacity = ((lifetime - age) / _fadeOut).clamp(0.0, 1.0);
    fill.color = p.color.withValues(alpha: opacity);
    canvas
      ..save()
      ..translate(position.dx, position.dy)
      ..rotate(p.rotation + p.spin * age)
      ..scale(p.size * (0.3 + 0.7 * pop));
    p.shape.paint(canvas, fill, detail, opacity);
    canvas.restore();
  }

  static Offset _unit(double angle) => Offset(math.cos(angle), math.sin(angle));

  static double _seconds(Duration d) => d.inMicroseconds / 1e6;
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
