import 'package:flutter/material.dart';

import '../../../core/ui/theme/app.colors.dart';
import '../../../state/drawing/drawing.view-model.dart';
import 'drawing.workspace.layout.dart';
import 'round.button.dart';

class DrawingPageControls extends StatelessWidget {
  const DrawingPageControls({
    super.key,
    required this.layout,
    required this.viewModel,
  });

  final DrawingWorkspaceLayout layout;
  final DrawingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final size = layout.controlSize;
    final left = layout.pageControlsLeft;
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: layout.edgeMargin,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: child,
                ),
                child: viewModel.hasCompletedStroke
                    ? RoundButton(
                        key: const ValueKey('done'),
                        icon: Icons.check_rounded,
                        label: 'Done',
                        size: size,
                        color: AppColors.done,
                        onPressed: () {},
                      )
                    : SizedBox.square(
                        key: const ValueKey('no-done'),
                        dimension: size,
                      ),
              ),
            ),
          ),
          Positioned(
            left: left,
            bottom: layout.edgeMargin,
            child: RoundButton(
              icon: Icons.settings_rounded,
              label: 'Settings',
              size: size,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
