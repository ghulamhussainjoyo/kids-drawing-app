import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/engine/burst.engine.dart';

/// Screen-space layer that plays [BurstEngine] particles. It never takes
/// touches, and its ticker only runs while particles are alive.
class BurstOverlay extends StatefulWidget {
  const BurstOverlay({super.key});

  @override
  State<BurstOverlay> createState() => BurstOverlayState();
}

class BurstOverlayState extends State<BurstOverlay>
    with SingleTickerProviderStateMixin {
  final BurstEngine _engine = BurstEngine();
  final ValueNotifier<Duration> _clock = ValueNotifier(Duration.zero);
  late final Ticker _ticker = createTicker(_onTick);

  /// Pops a burst at [point], in this widget's local coordinates.
  void spawn(Offset point) {
    if (!_ticker.isActive) {
      _clock.value = Duration.zero;
      _ticker.start();
    }
    _engine.spawn(point, _clock.value);
  }

  void _onTick(Duration elapsed) {
    _clock.value = elapsed;
    if (!_engine.isActive) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _BurstPainter(_engine, _clock),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.engine, this.clock) : super(repaint: clock);

  final BurstEngine engine;
  final ValueNotifier<Duration> clock;

  @override
  void paint(Canvas canvas, Size size) => engine.paint(canvas, clock.value);

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.engine != engine;
}
