import 'package:flutter/material.dart';

import '../../../data/models/paint.color.dart';
import 'pencil.stick.painter.dart';

/// Scrolling rail of color sticks. The selected stick slides out to the left.
class ColorPalette extends StatelessWidget {
  const ColorPalette({
    super.key,
    required this.colors,
    required this.selectedId,
    required this.onSelected,
    required this.stickHeight,
    required this.spacing,
    required this.slideOut,
    this.endPadding = 0,
  });

  final List<PaintColor> colors;
  final String selectedId;
  final ValueChanged<PaintColor> onSelected;
  final double stickHeight;
  final double spacing;

  /// How far the selected stick moves left, in logical pixels.
  final double slideOut;

  /// Empty space before the first and after the last stick.
  final double endPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: spacing / 2 + endPadding),
          itemCount: colors.length,
          itemExtent: stickHeight + spacing,
          itemBuilder: (context, index) {
            final paintColor = colors[index];
            final selected = paintColor.id == selectedId;
            return Semantics(
              button: true,
              selected: selected,
              label: '${paintColor.id} pencil',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelected(paintColor),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      left: selected ? slideOut * 0.2 : slideOut,
                      width: width,
                      top: spacing / 2,
                      height: stickHeight,
                      child: CustomPaint(
                        painter: PencilStickPainter(paintColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
