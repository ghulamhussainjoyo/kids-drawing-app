import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/features/drawing/screen/erase.confirm.screen.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tools/controller.tools.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tools/drawing.tools.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/workspace.canvas.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreen();
}

class _DrawingScreen extends State<DrawingScreen> {
  void openEraseConfirm(DrawingViewModel viewModel) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EraseConfirmScreen(viewModel: viewModel),
      ),
    );
  }

  List<double> getInsets(BuildContext context) {
    final orientation = NativeDeviceOrientationReader.orientation(context);
    final landscapeRight = NativeDeviceOrientation.landscapeRight;
    final notchOnRight = orientation == landscapeRight;
    final toolsFlex = notchOnRight ? 3.0 : 2.0;
    final rightInsets = MediaQuery.viewPaddingOf(context).right * 0.7;
    final notchInset = notchOnRight ? rightInsets : 0.0;
    return [toolsFlex, notchInset];
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DrawingViewModel>(context);
    return NativeDeviceOrientationReader(
      builder: (context) {
        final [toolsFlex, notchInset] = getInsets(context);
        return CupertinoPageScaffold(
          backgroundColor: AppColors.pageBackground,
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) {
              return Row(
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: ControllerTools(
                      density: viewModel.density,
                      onDensityChanged: viewModel.setDensity,
                      selectedCategoryImage: viewModel.categoryImage,
                      onBack: () => Navigator.of(context).maybePop(),
                      onEraser: () => openEraseConfirm(viewModel),
                      onUndo: viewModel.canUndo ? viewModel.undo : null,
                      onRedo: viewModel.canRedo ? viewModel.redo : null,
                    ),
                  ),
                  Flexible(
                    flex: 5,
                    fit: FlexFit.tight,
                    child: ColoredBox(
                      color: AppColors.pageBackground,
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
                          return WorkspaceCanvas(
                            viewModel: viewModel,
                            pageRect: pageRect,
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: toolsFlex.toInt(),
                    child: DrawingTools(
                      notchInset: notchInset,
                      onToolSelect: viewModel.selectTool,
                      onCategoryTap: viewModel.selectCategory,
                      selectedCategory: viewModel.selectedCategory,
                      selectedToolId: viewModel.selectedTool?.id,
                      stationaryTools: viewModel.stationaryTools,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
