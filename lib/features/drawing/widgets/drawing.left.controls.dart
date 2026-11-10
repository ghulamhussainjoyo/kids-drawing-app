import 'package:flutter/material.dart';

import '../../../state/drawing/drawing.view-model.dart';
import 'active.tool.badge.dart';
import 'drawing.workspace.layout.dart';
import 'round.button.dart';
import 'size.slider.display.dart';

class DrawingLeftControls extends StatelessWidget {
  const DrawingLeftControls({
    super.key,
    required this.layout,
    required this.viewModel,
  });

  final DrawingWorkspaceLayout layout;
  final DrawingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final u = layout.unit;
    final size = layout.controlSize;
    return Positioned(
      left: layout.leftColumnLeft,
      top: layout.edgeMargin,
      bottom: layout.edgeMargin,
      width: layout.leftColumnWidth,
      child: Column(
        children: [
          Row(
            children: [
              RoundButton(
                icon: Icons.arrow_back_rounded,
                label: 'Back',
                size: size,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              SizedBox(width: layout.controlGap),
              RoundButton(
                icon: Icons.palette_rounded,
                label: 'Palette',
                size: size,
                onPressed: () {},
              ),
            ],
          ),
          const Spacer(flex: 85),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                left: layout.toolStackCenter - layout.badgeSize / 2,
              ),
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (context, _) => ActiveToolBadge(
                  type: viewModel.brush.type,
                  size: layout.badgeSize,
                ),
              ),
            ),
          ),
          SizedBox(height: 36 * u),
          Flexible(
            flex: 348,
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: layout.toolStackCenter - layout.sliderSize.width / 2,
                ),
                child: SizedBox(
                  width: layout.sliderSize.width,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizeSliderDisplay(
                      width: layout.sliderSize.width,
                      height: layout.sliderSize.height,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(flex: 48),
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => Row(
              children: [
                RoundButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  size: size,
                  onPressed: viewModel.canUndo ? viewModel.undo : null,
                ),
                SizedBox(width: layout.controlGap),
                RoundButton(
                  icon: Icons.redo_rounded,
                  label: 'Redo',
                  size: size,
                  onPressed: viewModel.canRedo ? viewModel.redo : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
