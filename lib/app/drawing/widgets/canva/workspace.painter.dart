import 'package:flutter/rendering.dart';

import '../../../../core/engine/canvas.engine.dart';
import '../../../../state/drawing/drawing.view-model.dart';

class WorkspacePainter extends CustomPainter {
  final DrawingViewModel viewModel;
  final CanvasViewTransform Function() view;

  /// Current shimmer time; null paints glitter still.
  final double Function()? shimmerSeconds;

  WorkspacePainter({
    required this.view,
    this.shimmerSeconds,
    required this.viewModel,
    required super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    view().apply(canvas);
    viewModel.layerManager!.paint(
      canvas,
      toolFor: viewModel.toolFor,
      committed: viewModel.strokes,
      revision: viewModel.revision,
      active: viewModel.activeStroke,
      activeDabber: viewModel.activeDabber,
      shimmerSeconds: shimmerSeconds?.call(),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(WorkspacePainter oldDelegate) {
    if (oldDelegate.viewModel != viewModel) return true;
    return false;
  }
}
