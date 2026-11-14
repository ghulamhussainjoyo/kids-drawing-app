import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/drawing/metrics/tools.panel.metrics.dart';
import 'package:provider/provider.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/app/drawing/screen/erase.confirm.screen.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/controller/controller.tools.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/tools/drawing.tools.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/canva/workspace.canvas.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreen();
}

class _DrawingScreen extends State<DrawingScreen> with WidgetsBindingObserver {
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
    final toolsFlex = 2.0;
    final rightInsets = MediaQuery.viewPaddingOf(context).right * 0.7;
    final notchInset = notchOnRight ? rightInsets : 0.0;
    return [toolsFlex, notchInset];
  }

  Rect getPageRect(BoxConstraints constraints) {
    final side = math.min(constraints.maxWidth, constraints.maxHeight);
    final x = (constraints.maxWidth - side) / 2;
    final y = (constraints.maxHeight - side) / 2;
    final pageRect = Rect.fromLTWH(x, y, side, side);
    return pageRect;
  }

  Future<void> flushAndPop(DrawingViewModel viewModel) async {
    await viewModel.flushSave();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  double getNotchInset(BuildContext context) {
    final orientation = NativeDeviceOrientationReader.orientation(context);
    final notchOnRight = orientation == NativeDeviceOrientation.landscapeRight;
    return notchOnRight ? MediaQuery.viewPaddingOf(context).right * 0.7 : 0.0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final viewModel = Provider.of<DrawingViewModel>(context, listen: false);
      viewModel.flushSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DrawingViewModel>(context, listen: false);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await flushAndPop(viewModel);
      },
      child: NativeDeviceOrientationReader(
        builder: (context) {
          final metrics = ToolsPanelMetrics.of(
            context,
            notchInset: getNotchInset(context),
          );
          return CupertinoPageScaffold(
            backgroundColor: AppColors.pageBackground,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                if (!viewModel.hasOpenedArtwork ||
                    viewModel.layerManager == null) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                return Row(
                  children: [
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: ControllerTools(
                        density: viewModel.density,
                        onDensityChanged: viewModel.setDensity,
                        selectedCategoryImage: viewModel.categoryImage,
                        onBack: () => flushAndPop(viewModel),
                        onEraser: () => openEraseConfirm(viewModel),
                        onUndo: viewModel.canUndo ? viewModel.undo : null,
                        onRedo: viewModel.canRedo ? viewModel.redo : null,
                      ),
                    ),

                    Flexible(
                      flex: 5, // wapas original, Expanded nahi
                      fit: FlexFit.tight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: ColoredBox(
                                color: AppColors.pageBackground,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return WorkspaceCanvas(
                                      viewModel: viewModel,
                                      pageRect: getPageRect(constraints),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [Text('Hello'), Text('World')],
                            ),
                          ),
                        ],
                      ),
                    ),
                    DrawingTools(
                      // Flexible nahi, fixed width
                      metrics: metrics,
                      onToolSelect: viewModel.selectTool,
                      onCategoryTap: viewModel.selectCategory,
                      selectedCategory: viewModel.selectedCategory,
                      selectedToolId: viewModel.selectedTool?.id,
                      stationaryTools: viewModel.stationaryTools,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
