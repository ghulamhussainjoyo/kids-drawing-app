import 'package:flutter/rendering.dart';

import '../../../../core/engine/burst.engine.dart';
import '../../../../core/engine/canvas.engine.dart';
import '../../../../state/drawing/drawing.view-model.dart';

double _noGlitterTime() => 0;

class WorkspacePainter extends CustomPainter {
  final BurstEngine burstEngine;
  final DrawingViewModel viewModel;
  final CanvasViewTransform Function() view;
  final double Function() glitterTime;
  WorkspacePainter({
    required this.view,
    required this.viewModel,
    required super.repaint,
    required this.burstEngine,
    this.glitterTime = _noGlitterTime,
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
      time: glitterTime(),
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
