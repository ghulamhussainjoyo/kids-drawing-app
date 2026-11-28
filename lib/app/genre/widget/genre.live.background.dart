import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Full-bleed genre home backdrop. When [animated] is false, only the static PNG is shown.
class GenreLiveBackground extends StatefulWidget {
  const GenreLiveBackground({super.key, required this.animated});

  final bool animated;

  @override
  State<GenreLiveBackground> createState() => _GenreLiveBackgroundState();
}

class _GenreLiveBackgroundState extends State<GenreLiveBackground>
    with SingleTickerProviderStateMixin {
  static const _assetPrefix = 'assets/genre/live_background';
  static const double _designW = 1672;
  static const double _designH = 941;

  Ticker? _ticker;
  final ValueNotifier<double> _t = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _startTicker();
    }
  }

  @override
  void didUpdateWidget(covariant GenreLiveBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated && _ticker == null) {
      _startTicker();
    } else if (!widget.animated && _ticker != null) {
      _stopTicker();
    }
  }

  void _startTicker() {
    _ticker = createTicker((d) => _t.value = d.inMicroseconds / 1e6)..start();
  }

  void _stopTicker() {
    _ticker?.dispose();
    _ticker = null;
    _t.value = 0;
  }

  @override
  void dispose() {
    _stopTicker();
    _t.dispose();
    super.dispose();
  }

  String _asset(String name) => '$_assetPrefix/$name.png';

  Widget _img(String name, double w) {
    return Image.asset(
      _asset(name),
      width: w,
      filterQuality: FilterQuality.medium,
    );
  }

  Widget _cloud(
    double t,
    String n,
    double w,
    double x0,
    double y,
    double speed,
  ) {
    final x = ((x0 + speed * t + w) % (_designW + 2 * w)) - w;
    return Positioned(left: x, top: y, child: _img(n, w));
  }

  Widget _balloon(double t, String n, double x, double y, double ph, double w) {
    final dy = 16 * math.sin(t * 1.1 + ph);
    final dx = 8 * math.sin(t * 0.7 + ph * 2);
    return Positioned(
      left: x + dx,
      top: y + dy,
      child: Transform.rotate(
        angle: 0.06 * math.sin(t * 0.9 + ph),
        alignment: Alignment.bottomCenter,
        child: _img(n, w),
      ),
    );
  }

  Widget _butterfly(
    double t,
    String n,
    double hx,
    double hy,
    double ax,
    double ay,
    double speed,
    double ph,
    double w,
  ) {
    final x = hx + ax * math.sin(t * speed + ph);
    final y = hy + ay * math.sin(t * speed * 2 + ph);
    final flap = 0.55 + 0.45 * math.sin(t * 14 + ph).abs();
    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: 0.3 * math.cos(t * speed + ph),
        child: Transform.scale(scaleX: flap, child: _img(n, w)),
      ),
    );
  }

  Widget _animatedLayers(double t) {
    final rainbowOpacity = 0.8 + 0.2 * math.sin(t * 0.8);
    final bx = 1360 + 30 * math.sin(t * 0.5);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: 1300,
          top: 360 + 6 * math.sin(t * 0.6),
          child: Opacity(
            opacity: rainbowOpacity.clamp(0.0, 1.0),
            child: _img('rainbow', 334),
          ),
        ),
        _cloud(t, 'cloud4', 170, 150, 90, 14),
        _cloud(t, 'cloud1', 150, 300, 230, 9),
        _cloud(t, 'cloud2', 180, 700, 320, 12),
        _cloud(t, 'cloud3', 160, 1100, 260, 7),
        _cloud(t, 'cloud5', 130, 900, 540, 10),
        Positioned.fill(child: CustomPaint(painter: _SmokePainter(t))),
        _balloon(t, 'balloon_pink', 700, 40, 0.0, 85),
        _balloon(t, 'balloon_purple', 1000, 60, 1.7, 85),
        _balloon(t, 'balloon_yellow', 1260, 40, 3.1, 85),
        _balloon(t, 'balloon_pink2', 420, 150, 4.4, 80),
        Positioned(
          left: ((70 * t) % (_designW + 300)) - 150,
          top: 120 + 25 * math.sin(t * 1.6),
          child: Transform.rotate(
            angle: -0.08 * math.cos(t * 1.6),
            child: _img('bird', 95),
          ),
        ),
        _butterfly(t, 'butterfly_orange1', 300, 330, 110, 40, 0.7, 0.0, 60),
        _butterfly(t, 'butterfly_orange2', bx, 380, 90, 35, 0.8, 1.2, 60),
        _butterfly(t, 'butterfly_pink1', 1500, 350, 80, 40, 0.6, 2.4, 60),
        _butterfly(t, 'butterfly_pink2', 1450, 600, 90, 30, 0.9, 0.7, 75),
        _butterfly(t, 'butterfly_orange3', 250, 700, 120, 35, 0.75, 3.3, 60),
        _butterfly(t, 'butterfly_purple', 520, 780, 100, 30, 0.85, 4.1, 70),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _designW,
          height: _designH,
          child: RepaintBoundary(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Image.asset(
                  _asset('background'),
                  width: _designW,
                  height: _designH,
                  fit: BoxFit.fill,
                ),
                if (widget.animated)
                  ValueListenableBuilder<double>(
                    valueListenable: _t,
                    builder: (context, t, _) => _animatedLayers(t),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmokePainter extends CustomPainter {
  _SmokePainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const puffs = 5;
    for (var i = 0; i < puffs; i++) {
      final p = (t * 0.22 + i / puffs) % 1.0;
      final x = 182 + 40 * p + 8 * math.sin(p * 9 + i);
      final y = 425 - 130 * p;
      final r = 8 + 20 * p;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.55 * (1 - p))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SmokePainter old) => old.t != t;
}
