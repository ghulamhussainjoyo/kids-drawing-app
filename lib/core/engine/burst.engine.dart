import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/animation.dart' show Curves;

import 'burst.shape.dart';

/// A single particle emitted by a burst.
class _Particle {
  _Particle({
    required this.shape,
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
    required this.spin,
    required this.delay,
  });

  final BurstShape shape;
  final Color color;
  final double size;
  final double spin;

  /// Seconds after the burst starts before this particle appears.
  final double delay;

  Offset position;
  Offset velocity;
  double rotation;
}

/// A group of particles emitted at the same time.
class _Burst {
  _Burst(this.startedAt, this.particles);

  final Duration startedAt;
  final List<_Particle> particles;
}

/// Produces short-lived visual effects when a finger lifts.
///
/// All positions are expressed in artwork coordinates.
///
/// This engine is purely visual:
/// - Particles are never persisted.
/// - Particle effects are not part of undo history.
/// - Rendering is performed by the caller.
class BurstEngine {
  BurstEngine({math.Random? random}) : _random = random ?? math.Random();

  // ---------------------------------------------------------------------------
  // Animation configuration
  // ---------------------------------------------------------------------------

  static const double lifetime = 1.5;

  static const double _popInDuration = 0.15;
  static const double _fadeOutDuration = 0.6;
  static const double _drag = 1.8;

  static const int _minimumParticleCount = 10;
  static const int _particleCountVariation = 5;

  static const double _minimumSpeed = 60;
  static const double _speedVariation = 140;

  static const double _positionSpread = 30;
  static const double _gravity = 25;

  // ---------------------------------------------------------------------------
  // Burst appearance
  // ---------------------------------------------------------------------------

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

  /// Each burst favors one shape.
  ///
  /// The final entry allows all available shapes to be selected randomly.
  static const List<BurstShape?> _themes = [
    BurstShape.butterfly,
    BurstShape.star,
    BurstShape.heart,
    BurstShape.flower,
    BurstShape.dot,
    BurstShape.snowflake,
    null,
  ];

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  final math.Random _random;
  final List<_Burst> _bursts = [];

  int _burstCount = 0;
  Duration _now = Duration.zero;

  /// Whether any bursts are currently being tracked.
  bool get isActive => _bursts.isNotEmpty;

  /// Current engine time.
  ///
  /// [update] should be called with monotonically increasing timestamps.
  Duration get now => _now;

  // ---------------------------------------------------------------------------
  // Burst creation
  // ---------------------------------------------------------------------------

  /// Creates a burst around the supplied stroke points.
  ///
  /// Each particle receives a randomly selected anchor point from the stroke.
  void spawn(List<Offset> strokePoints, {required double particleSize}) {
    if (strokePoints.isEmpty) return;

    final theme = _nextTheme();
    final particleCount =
        _minimumParticleCount + _random.nextInt(_particleCountVariation);

    final particles = List<_Particle>.generate(
      particleCount,
      (_) => _createParticle(
        strokePoints: strokePoints,
        particleSize: particleSize,
        theme: theme,
      ),
      growable: false,
    );

    _bursts.add(_Burst(_now, particles));
  }

  /// Selects the theme for the next burst.
  BurstShape? _nextTheme() {
    final theme = _themes[_burstCount % _themes.length];
    _burstCount++;

    return theme;
  }

  /// Creates a particle using the current burst configuration.
  _Particle _createParticle({
    required List<Offset> strokePoints,
    required double particleSize,
    required BurstShape? theme,
  }) {
    final anchor = strokePoints[_random.nextInt(strokePoints.length)];

    final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * math.pi * 1.6;

    final speed = _minimumSpeed + _random.nextDouble() * _speedVariation;

    final velocity = Offset(math.cos(angle), math.sin(angle)) * speed;

    final position =
        anchor +
        Offset(_random.nextDouble() - 0.5, _random.nextDouble() - 0.5) *
            _positionSpread;

    return _Particle(
      shape: theme ?? _randomShape(),
      position: position,
      velocity: velocity,
      color: _randomColor(),
      size: particleSize * (0.7 + _random.nextDouble() * 0.6),
      rotation: _random.nextDouble() * math.pi * 2,
      spin: (_random.nextDouble() - 0.5) * 3,
      delay: _random.nextDouble() * 0.25,
    );
  }

  BurstShape _randomShape() {
    return BurstShape.values[_random.nextInt(BurstShape.values.length)];
  }

  Color _randomColor() {
    return _colors[_random.nextInt(_colors.length)];
  }

  // ---------------------------------------------------------------------------
  // Animation updates
  // ---------------------------------------------------------------------------

  /// Advances the simulation to [now].
  ///
  /// The supplied timestamp should come from a ticker's elapsed time.
  void update(Duration now) {
    final deltaSeconds = math.max(0.0, (now - _now).inMicroseconds / 1e6);

    _now = now;

    if (deltaSeconds == 0) return;

    final damping = math.exp(-_drag * deltaSeconds);

    for (final burst in _bursts) {
      final burstAge = _secondsBetween(burst.startedAt, now);

      for (final particle in burst.particles) {
        if (burstAge < particle.delay) continue;

        _updateParticle(particle, deltaSeconds, damping);
      }
    }

    _removeExpiredBursts(now);
  }

  /// Advances an individual particle using the existing motion model.
  void _updateParticle(
    _Particle particle,
    double deltaSeconds,
    double damping,
  ) {
    particle.position += particle.velocity * deltaSeconds;

    particle.velocity =
        particle.velocity * damping + const Offset(0, _gravity) * deltaSeconds;

    particle.rotation += particle.spin * deltaSeconds;
  }

  /// Removes bursts that have completed their animation lifetime.
  void _removeExpiredBursts(Duration now) {
    _bursts.removeWhere(
      (burst) => _secondsBetween(burst.startedAt, now) > lifetime + 0.25,
    );
  }

  /// Removes all active bursts.
  ///
  /// The engine clock and burst theme sequence are intentionally preserved.
  void clear() {
    _bursts.clear();
  }

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  /// Paints all active particles onto [canvas].
  ///
  /// Paint objects are reused throughout the rendering pass to avoid
  /// allocating additional Paint instances for individual particles.
  void paint(Canvas canvas) {
    if (_bursts.isEmpty) return;
    final shapePaint = Paint()..isAntiAlias = true;
    final detailPaint = Paint()..isAntiAlias = true;
    for (final burst in _bursts) {
      final burstAge = _secondsBetween(burst.startedAt, _now);
      for (final particle in burst.particles) {
        final particleAge = burstAge - particle.delay;
        if (particleAge < 0 || particleAge > lifetime) {
          continue;
        }
        _paintParticle(
          canvas: canvas,
          particle: particle,
          age: particleAge,
          shapePaint: shapePaint,
          detailPaint: detailPaint,
        );
      }
    }
  }

  /// Calculates the particle's visual state and renders it.
  void _paintParticle({
    required Canvas canvas,
    required double age,
    required Paint shapePaint,
    required Paint detailPaint,
    required _Particle particle,
  }) {
    final popProgress = math.min(1.0, age / _popInDuration);
    final opacity = age > lifetime - _fadeOutDuration
        ? (lifetime - age) / _fadeOutDuration
        : 1.0;
    final fade = opacity.clamp(0.0, 1.0).toDouble();
    final scale = 0.4 + 0.6 * Curves.easeOutBack.transform(popProgress);
    canvas
      ..save()
      ..translate(particle.position.dx, particle.position.dy)
      ..rotate(particle.rotation)
      ..scale(particle.size * scale);

    shapePaint.color = particle.color.withValues(alpha: fade);

    _paintShape(
      canvas: canvas,
      shape: particle.shape,
      shapePaint: shapePaint,
      detailPaint: detailPaint,
      fade: fade,
    );
    canvas.restore();
  }

  /// Draws a particle shape in a unit box centered on the origin.
  static void _paintShape({
    required Canvas canvas,
    required BurstShape shape,
    required Paint shapePaint,
    required Paint detailPaint,
    required double fade,
  }) {
    // Reset mutable Paint properties before drawing each shape.
    shapePaint.style = PaintingStyle.fill;

    switch (shape) {
      case BurstShape.dot:
        canvas.drawCircle(Offset.zero, 0.3, shapePaint);

      case BurstShape.star:
        canvas.drawPath(_star, shapePaint);

      case BurstShape.heart:
        canvas.drawPath(_heart, shapePaint);

      case BurstShape.flower:
        canvas.drawPath(_petals, shapePaint);

        detailPaint.color = Color.fromRGBO(255, 245, 160, fade);

        canvas.drawCircle(Offset.zero, 0.16, detailPaint);

      case BurstShape.butterfly:
        canvas.drawPath(_wings, shapePaint);

        detailPaint.color = Color.fromRGBO(60, 40, 70, fade);

        canvas.drawPath(_butterflyBody, detailPaint);

      case BurstShape.snowflake:
        shapePaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.08
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(_snowflake, shapePaint);
    }
  }

  // ---------------------------------------------------------------------------
  // Shared geometry
  // ---------------------------------------------------------------------------

  static double _secondsBetween(Duration from, Duration to) {
    return (to - from).inMicroseconds / 1e6;
  }

  static final Path _star = _createStarPath();

  static Path _createStarPath() {
    final path = Path();

    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? 0.5 : 0.22;
      final angle = -math.pi / 2 + i * math.pi / 5;

      final point = Offset(math.cos(angle) * radius, math.sin(angle) * radius);

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    return path..close();
  }

  static final Path _heart = Path()
    ..moveTo(0, 0.42)
    ..cubicTo(-0.6, 0.02, -0.42, -0.5, 0, -0.2)
    ..cubicTo(0.42, -0.5, 0.6, 0.02, 0, 0.42)
    ..close();

  static final Path _petals = _createPetalPath();

  static Path _createPetalPath() {
    final path = Path();

    for (var i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;

      path.addOval(
        Rect.fromCircle(
          center: Offset(math.cos(angle) * 0.26, math.sin(angle) * 0.26),
          radius: 0.2,
        ),
      );
    }

    return path;
  }

  static final Path _wings = Path()
    ..addOval(
      Rect.fromCenter(
        center: const Offset(-0.22, -0.14),
        width: 0.42,
        height: 0.5,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: const Offset(0.22, -0.14),
        width: 0.42,
        height: 0.5,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: const Offset(-0.18, 0.2),
        width: 0.3,
        height: 0.34,
      ),
    )
    ..addOval(
      Rect.fromCenter(
        center: const Offset(0.18, 0.2),
        width: 0.3,
        height: 0.34,
      ),
    );

  static final Path _butterflyBody = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 0.09, height: 0.62),
        const Radius.circular(0.05),
      ),
    );

  static final Path _snowflake = _createSnowflakePath();

  static Path _createSnowflakePath() {
    final path = Path();
    for (var i = 0; i < 3; i++) {
      final angle = i * math.pi / 3;
      final direction = Offset(math.cos(angle), math.sin(angle)) * 0.45;
      path
        ..moveTo(-direction.dx, -direction.dy)
        ..lineTo(direction.dx, direction.dy);
    }
    return path;
  }
}
