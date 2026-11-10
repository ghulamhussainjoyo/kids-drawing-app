import 'package:flutter/rendering.dart';

import '../../../core/engine/burst.engine.dart';
import '../../../core/engine/canvas.engine.dart';
import '../../../core/engine/layer.manager.dart';
import '../../../state/drawing/drawing.view-model.dart';

class DrawingPagePainter extends CustomPainter {
  DrawingPagePainter({
    required this.viewModel,
    required this.layerManager,
    required this.burstEngine,
    required this.view,
    required super.repaint,
  });

  final DrawingViewModel viewModel;
  final LayerManager layerManager;
  final BurstEngine burstEngine;
  final CanvasViewTransform Function() view;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    view().apply(canvas);
    layerManager.paint(
      canvas,
      committed: viewModel.strokes,
      revision: viewModel.revision,
      tool: viewModel.tool,
      active: viewModel.activeStroke,
      activeDabber: viewModel.activeDabber,
    );
    burstEngine.paint(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(DrawingPagePainter oldDelegate) {
    if (oldDelegate.viewModel != viewModel) return true;
    if (oldDelegate.layerManager != layerManager) return true;
    return false;
  }
}
