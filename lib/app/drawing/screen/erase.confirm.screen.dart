import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../../core/engine/burst.engine.dart';
import '../../../core/engine/canvas.engine.dart';
import '../../../core/ui/theme/app.colors.dart';
import '../../../state/drawing/drawing.view-model.dart';
import '../widgets/canva/workspace.painter.dart';

class EraseConfirmScreen extends StatelessWidget {
  const EraseConfirmScreen({super.key, required this.viewModel});

  final DrawingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.pageBackground,
      child: SafeArea(
        child: Row(
          children: [
            const Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ColoredBox(color: AppColors.lavender),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final side = math.min(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                          final pageRect = Rect.fromLTWH(
                            (constraints.maxWidth - side) / 2,
                            (constraints.maxHeight - side) / 2,
                            side,
                            side,
                          );
                          return CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: WorkspacePainter(
                              viewModel: viewModel,
                              burstEngine: BurstEngine(),
                              view: () => CanvasViewTransform(
                                pageRect: pageRect,
                                artworkSize:
                                    viewModel.layerManager!.artwork.size,
                              ),
                              repaint: viewModel,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('NO'),
                          ),
                        ),
                        Expanded(
                          child: CupertinoButton(
                            color: AppColors.done,
                            onPressed: () {
                              viewModel.clearAll();
                              Navigator.of(context).pop();
                            },
                            child: const Text('YES'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
