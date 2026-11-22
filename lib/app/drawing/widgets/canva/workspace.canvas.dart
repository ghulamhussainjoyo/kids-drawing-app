import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/engine/canvas.engine.dart';
import '../../../../state/drawing/drawing.view-model.dart';
import '../../../../types/brush.type.dart';
import '../../../../types/drawing.stroke.dart';
import 'burst.overlay.dart';
import 'canvas.pinch.dart';
import 'workspace.painter.dart';

/// The zoomable page. One finger paints; two fingers zoom and pan.
class WorkspaceCanvas extends StatefulWidget {
  const WorkspaceCanvas({
    super.key,
    required this.viewModel,
    required this.pageRect,
  });

  final DrawingViewModel viewModel;
  final Rect pageRect;

  @override
  State<WorkspaceCanvas> createState() => _WorkspaceCanvasState();
}

class _WorkspaceCanvasState extends State<WorkspaceCanvas>
    with TickerProviderStateMixin {
  static const Duration settleDuration = Duration(milliseconds: 320);
  static const double fingertipRadius = 22;

  /// Shimmer frames per second; glints don't need the full display rate.
  static const int shimmerFps = 20;

  final Map<int, Offset> pointers = {};
  final GlobalKey<BurstOverlayState> burstKey = GlobalKey();
  final ValueNotifier<int> repaintTicks = ValueNotifier<int>(0);

  /// Shimmer time in seconds, stepped at [shimmerFps].
  final ValueNotifier<double> shimmerClock = ValueNotifier<double>(0);
  late final Ticker shimmerTicker = createTicker(onShimmerTick);

  /// Whether any committed stroke is glitter. Refreshed only when the
  /// stroke list changes, not on every finger move.
  bool committedHasGlitter = false;

  late CanvasViewTransform view;
  late final AnimationController settle;

  CanvasViewTransform? settleFrom;
  CanvasViewTransform? settleTo;

  int? drawingPointer;
  CanvasPinch? pinch;
  bool waitForAllUp = false;

  @override
  void initState() {
    super.initState();
    view = CanvasViewTransform(
      pageRect: widget.pageRect,
      artworkSize: widget.viewModel.layerManager!.artwork.size,
    );
    settle = AnimationController(vsync: this, duration: settleDuration)
      ..addListener(onSettleTick);
    listenTo(widget.viewModel);
    onStrokesChanged();
  }

  @override
  void didUpdateWidget(WorkspaceCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      stopListening(oldWidget.viewModel);
      listenTo(widget.viewModel);
      onStrokesChanged();
    }
    if (oldWidget.pageRect != widget.pageRect) {
      settle.stop();
      view = view.withPageRect(widget.pageRect).settled();
    }
  }

  @override
  void dispose() {
    stopListening(widget.viewModel);
    shimmerTicker.dispose();
    shimmerClock.dispose();
    settle.dispose();
    repaintTicks.dispose();
    super.dispose();
  }

  void listenTo(DrawingViewModel viewModel) {
    viewModel.addListener(onStrokesChanged);
    viewModel.activeStrokeTicks.addListener(onActiveStrokeChanged);
  }

  void stopListening(DrawingViewModel viewModel) {
    viewModel.removeListener(onStrokesChanged);
    viewModel.activeStrokeTicks.removeListener(onActiveStrokeChanged);
  }

  void onStrokesChanged() {
    committedHasGlitter = widget.viewModel.strokes.any(isGlitter);
    updateShimmerTicker();
  }

  void onActiveStrokeChanged() => updateShimmerTicker();

  /// Runs the shimmer only while the page has glitter on it, including a
  /// glitter stroke still being drawn.
  void updateShimmerTicker() {
    if (pageHasGlitter()) {
      startShimmer();
    } else {
      stopShimmer();
    }
  }

  bool pageHasGlitter() {
    if (committedHasGlitter) return true;
    return isGlitter(widget.viewModel.activeStroke);
  }

  bool isGlitter(DrawingStroke? stroke) {
    if (stroke == null) return false;
    return stroke.brush.type == BrushType.glitter;
  }

  void startShimmer() {
    if (shimmerTicker.isActive) return;
    shimmerTicker.start();
  }

  void stopShimmer() {
    if (!shimmerTicker.isActive) return;
    shimmerTicker.stop();
  }

  void onShimmerTick(Duration elapsed) {
    final step = elapsed.inMicroseconds * shimmerFps ~/ 1000000;
    final seconds = step / shimmerFps;
    if (seconds != shimmerClock.value) shimmerClock.value = seconds;
  }

  void setView(CanvasViewTransform next) {
    view = next;
    repaintTicks.value++;
  }

  void onSettleTick() {
    final from = settleFrom;
    final to = settleTo;
    if (from == null || to == null) return;
    final t = Curves.easeOutCubic.transform(settle.value);
    setView(CanvasViewTransform.lerp(from, to, t));
  }

  void animateTo(CanvasViewTransform target) {
    settleFrom = view;
    settleTo = target;
    settle.forward(from: 0);
  }

  void onPointerDown(PointerDownEvent event) {
    pointers[event.pointer] = event.localPosition;
    if (pointers.length == 1 && !waitForAllUp) {
      settle.stop();
      final started = widget.viewModel.beginStroke(
        view.toArtwork(event.localPosition),
        pickRadius: fingertipRadius / view.scale,
      );
      if (started) {
        drawingPointer = event.pointer;
      }
    } else if (pointers.length == 2) {
      widget.viewModel.cancelStroke();
      drawingPointer = null;
      settle.stop();
      waitForAllUp = true;
      final positions = pointers.values.toList();
      final focal = Offset.lerp(positions[0], positions[1], 0.5)!;
      pinch = CanvasPinch(
        startView: view,
        anchorArtwork: view.toArtwork(focal),
        startDistance: (positions[0] - positions[1]).distance,
      );
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (!pointers.containsKey(event.pointer)) return;
    pointers[event.pointer] = event.localPosition;

    if (event.pointer == drawingPointer) {
      widget.viewModel.extendStroke(view.toArtwork(event.localPosition));
      return;
    }

    final activePinch = pinch;
    if (activePinch == null || pointers.length < 2) return;
    final positions = pointers.values.take(2).toList();
    final focal = Offset.lerp(positions[0], positions[1], 0.5)!;
    final distance = (positions[0] - positions[1]).distance;
    final ratio = activePinch.startDistance == 0
        ? 1.0
        : distance / activePinch.startDistance;
    setView(
      activePinch.startView.zoomedAround(
        newZoom: activePinch.startView.zoom * ratio,
        anchorArtwork: activePinch.anchorArtwork,
        focalScreen: focal,
      ),
    );
  }

  void onPointerUp(PointerUpEvent event) {
    pointers.remove(event.pointer);
    if (event.pointer == drawingPointer) {
      drawingPointer = null;
      final stroke = widget.viewModel.endStroke();
      if (stroke != null) burstKey.currentState?.spawn(event.localPosition);
    }
    endPinchIfNeeded();
  }

  void onPointerCancel(PointerCancelEvent event) {
    pointers.remove(event.pointer);
    if (event.pointer == drawingPointer) {
      drawingPointer = null;
      widget.viewModel.cancelStroke();
    }
    endPinchIfNeeded();
  }

  void endPinchIfNeeded() {
    if (pinch != null && pointers.length < 2) {
      pinch = null;
      animateTo(view.settled());
    }
    if (pointers.isEmpty) waitForAllUp = false;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: onPointerDown,
        onPointerMove: onPointerMove,
        onPointerUp: onPointerUp,
        onPointerCancel: onPointerCancel,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            ClipRect(
              child: CustomPaint(
                size: Size.infinite,
                painter: WorkspacePainter(
                  viewModel: widget.viewModel,
                  view: () => view,
                  shimmerSeconds: () => shimmerClock.value,
                  repaint: Listenable.merge([
                    widget.viewModel,
                    widget.viewModel.activeStrokeTicks,
                    repaintTicks,
                    shimmerClock,
                  ]),
                ),
              ),
            ),
            BurstOverlay(key: burstKey),
          ],
        ),
      ),
    );
  }
}
