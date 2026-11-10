import 'package:flutter/cupertino.dart';

import '../../../core/engine/layer.manager.dart';
import '../../../core/ui/theme/app.colors.dart';
import '../../../state/drawing/drawing.view-model.dart';
import '../widgets/brush.selector.dart';
import '../widgets/color.palette.dart';
import '../widgets/drawing.canvas.dart';
import '../widgets/drawing.left.controls.dart';
import '../widgets/drawing.page.controls.dart';
import '../widgets/drawing.workspace.layout.dart';
import '../widgets/notch.side.dart';
import '../widgets/notch.side.builder.dart';
import '../widgets/pencil.colors.dart';

/// Landscape coloring workspace. Proportions follow Figma frame `11:154`,
/// which is 924 units tall; every size is expressed in those units.
class DrawingScreen extends StatelessWidget {
  const DrawingScreen({
    super.key,
    required this.viewModel,
    required this.layerManager,
    this.notchSide,
  });

  final DrawingViewModel viewModel;
  final LayerManager layerManager;

  /// Fixed notch side; when null the side is detected from the device.
  final NotchSide? notchSide;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.pageBackground,
      child: NotchSideBuilder(
        side: notchSide,
        builder: (context, side, notchInset) => LayoutBuilder(
          builder: (context, constraints) {
            final layout = DrawingWorkspaceLayout(
              constraints.biggest,
              notchSide: side,
              notchInset: notchInset,
            );
            return _DrawingWorkspace(
              layout: layout,
              viewModel: viewModel,
              layerManager: layerManager,
            );
          },
        ),
      ),
    );
  }
}

class _DrawingWorkspace extends StatelessWidget {
  const _DrawingWorkspace({
    required this.layout,
    required this.viewModel,
    required this.layerManager,
  });

  final DrawingWorkspaceLayout layout;
  final DrawingViewModel viewModel;
  final LayerManager layerManager;

  @override
  Widget build(BuildContext context) {
    final u = layout.unit;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: layout.drawingAreaWidth,
          child: DrawingCanvas(
            viewModel: viewModel,
            layerManager: layerManager,
            pageRect: layout.pageRect,
          ),
        ),
        Positioned(
          right: layout.toolColumnWidth,
          top: 0,
          bottom: 0,
          width: layout.railWidth,
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => ColorPalette(
              colors: PencilColors.all,
              selectedId: viewModel.brush.paintColor.id,
              onSelected: viewModel.selectColor,
              stickHeight: 70 * u,
              spacing: 22 * u,
              slideOut: 40 * u,
              endPadding: DrawingWorkspaceLayout.listEndPadding,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: layout.toolColumnWidth,
          child: ColoredBox(
            color: AppColors.toolColumn,
            child: Padding(
              padding: EdgeInsets.only(right: layout.rightInset),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) => BrushSelector(
                  selected: viewModel.brush.type,
                  onSelected: viewModel.selectTool,
                  tileSize: layout.tileSize,
                  itemExtent: layout.tileItemExtent,
                  tabOverhang: 25 * u,
                  endPadding: DrawingWorkspaceLayout.listEndPadding,
                ),
              ),
            ),
          ),
        ),
        DrawingLeftControls(layout: layout, viewModel: viewModel),
        DrawingPageControls(layout: layout, viewModel: viewModel),
      ],
    );
  }
}
