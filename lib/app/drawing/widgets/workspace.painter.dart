import 'package:flutter/rendering.dart';

import '../../../core/engine/burst.engine.dart';
import '../../../core/engine/canvas.engine.dart';
import '../../../state/drawing/drawing.view-model.dart';

class WorkspacePainter extends CustomPainter {
  final BurstEngine burstEngine;
  final DrawingViewModel viewModel;
  final CanvasViewTransform Function() view;

  WorkspacePainter({
    required this.view,
    required this.viewModel,
    required this.burstEngine,
    required super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    view().apply(canvas);
    viewModel.layerManager.paint(
      canvas,
      tool: viewModel.tool,
      committed: viewModel.strokes,
      revision: viewModel.revision,
      active: viewModel.activeStroke,
      activeDabber: viewModel.activeDabber,
    );
    burstEngine.paint(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(WorkspacePainter oldDelegate) {
    if (oldDelegate.viewModel != viewModel) return true;
    return false;
  }
}
