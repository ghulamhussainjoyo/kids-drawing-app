import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

import '../../../core/engine/canvas.engine.dart';
import '../../../core/ui/theme/app.colors.dart';
import '../../../state/drawing/drawing.view-model.dart';
import '../widgets/canva/workspace.painter.dart';

import 'package:kids_drawing_flutter/core/ui/button/pill.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

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
                          child: Builder(
                            builder: (context) {
                              final vm = context.read<SettingViewModel>();
                              return PillButton(
                                label: vm.t('drawing.erase_no'),
                                textColor: AppColors.purple,
                                sound: PressSound.exit,
                                onPressed: () => Navigator.of(context).pop(),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final vm = context.read<SettingViewModel>();
                              return PillButton(
                                label: vm.t('drawing.erase_yes'),
                                color: AppColors.done,
                                sound: PressSound.exit,
                                onPressed: () {
                                  viewModel.clearAll();
                                  Navigator.of(context).pop();
                                },
                              );
                            },
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
