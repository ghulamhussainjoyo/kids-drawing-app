import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../core/engine/burst.engine.dart';
import '../../../core/engine/canvas.engine.dart';
import '../../../core/engine/layer.manager.dart';
import '../../../state/drawing/drawing.view-model.dart';
import 'canvas.pinch.dart';
import 'drawing.page.painter.dart';

/// The zoomable page. One finger paints; two fingers zoom and pan.
///
/// The widget fills the whole drawing area so a zoomed page can grow past
/// its fitted [pageRect]; surrounding controls are stacked above it.
class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.viewModel,
    required this.layerManager,
    required this.pageRect,
  });

  final DrawingViewModel viewModel;
  final LayerManager layerManager;
  final Rect pageRect;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas>
    with TickerProviderStateMixin {
  static const double _burstParticleSize = 42;
  static const Duration _settleDuration = Duration(milliseconds: 320);

  /// How far from a part, in screen points, a first touch still picks it.
  static const double _fingertipRadius = 22;

  final Map<int, Offset> _pointers = {};
  final BurstEngine _burstEngine = BurstEngine();
  final ValueNotifier<int> _repaintTicks = ValueNotifier<int>(0);

  late CanvasViewTransform _view;
  late final AnimationController _settle;
  late final Ticker _burstTicker;
  Duration _burstTickerBase = Duration.zero;

  CanvasViewTransform? _settleFrom;
  CanvasViewTransform? _settleTo;

  int? _drawingPointer;
  CanvasPinch? _pinch;

  /// After a pinch, remaining fingers must lift before painting resumes.
  bool _waitForAllUp = false;

  @override
  void initState() {
    super.initState();
    _view = CanvasViewTransform(
      pageRect: widget.pageRect,
      artworkSize: widget.layerManager.artwork.size,
    );
    _settle = AnimationController(vsync: this, duration: _settleDuration)
      ..addListener(_onSettleTick);
    _burstTicker = createTicker(_onBurstTick);
  }

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageRect != widget.pageRect) {
      _settle.stop();
      _view = _view.withPageRect(widget.pageRect).settled();
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    _burstTicker.dispose();
    _repaintTicks.dispose();
    super.dispose();
  }

  void _setView(CanvasViewTransform view) {
    _view = view;
    _repaintTicks.value++;
  }

  void _onSettleTick() {
    final from = _settleFrom;
    final to = _settleTo;
    if (from == null || to == null) return;
    final t = Curves.easeOutCubic.transform(_settle.value);
    _setView(CanvasViewTransform.lerp(from, to, t));
  }

  void _animateTo(CanvasViewTransform target) {
    _settleFrom = _view;
    _settleTo = target;
    _settle.forward(from: 0);
  }

  void _onBurstTick(Duration elapsed) {
    _burstEngine.update(_burstTickerBase + elapsed);
    _repaintTicks.value++;
    if (!_burstEngine.isActive) _burstTicker.stop();
  }

  void _spawnBurst(List<Offset> points) {
    _burstEngine.spawn(points, particleSize: _burstParticleSize);
    if (!_burstTicker.isActive) {
      _burstTickerBase = _burstEngine.now;
      _burstTicker.start();
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.localPosition;
    if (_pointers.length == 1 && !_waitForAllUp) {
      _settle.stop();
      final started = widget.viewModel.beginStroke(
        _view.toArtwork(event.localPosition),
        pickRadius: _fingertipRadius / _view.scale,
      );
      if (started) {
        _drawingPointer = event.pointer;
      }
    } else if (_pointers.length == 2) {
      widget.viewModel.cancelStroke();
      _drawingPointer = null;
      _settle.stop();
      _waitForAllUp = true;
      final positions = _pointers.values.toList();
      final focal = Offset.lerp(positions[0], positions[1], 0.5)!;
      _pinch = CanvasPinch(
        startView: _view,
        anchorArtwork: _view.toArtwork(focal),
        startDistance: (positions[0] - positions[1]).distance,
      );
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.localPosition;

    if (event.pointer == _drawingPointer) {
      widget.viewModel.extendStroke(_view.toArtwork(event.localPosition));
      return;
    }

    final pinch = _pinch;
    if (pinch == null || _pointers.length < 2) return;
    final positions = _pointers.values.take(2).toList();
    final focal = Offset.lerp(positions[0], positions[1], 0.5)!;
    final distance = (positions[0] - positions[1]).distance;
    final ratio = pinch.startDistance == 0
        ? 1.0
        : distance / pinch.startDistance;
    _setView(
      pinch.startView.zoomedAround(
        newZoom: pinch.startView.zoom * ratio,
        anchorArtwork: pinch.anchorArtwork,
        focalScreen: focal,
      ),
    );
  }

  void _onPointerUp(PointerUpEvent event) {
    _pointers.remove(event.pointer);
    if (event.pointer == _drawingPointer) {
      _drawingPointer = null;
      final stroke = widget.viewModel.endStroke();
      if (stroke != null) _spawnBurst(stroke.points);
    }
    _endPinchIfNeeded();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _pointers.remove(event.pointer);
    if (event.pointer == _drawingPointer) {
      _drawingPointer = null;
      widget.viewModel.cancelStroke();
    }
    _endPinchIfNeeded();
  }

  void _endPinchIfNeeded() {
    if (_pinch != null && _pointers.length < 2) {
      _pinch = null;
      _animateTo(_view.settled());
    }
    if (_pointers.isEmpty) _waitForAllUp = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: ClipRect(
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPagePainter(
            viewModel: widget.viewModel,
            layerManager: widget.layerManager,
            burstEngine: _burstEngine,
            view: () => _view,
            repaint: Listenable.merge([
              widget.viewModel,
              widget.viewModel.activeStrokeTicks,
              _repaintTicks,
            ]),
          ),
        ),
      ),
    );
  }
}
