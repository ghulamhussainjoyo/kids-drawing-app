import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/drawing/metrics/tools.panel.metrics.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/rounded.button.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';

/// Square stationary items (color balls, letters) in a 2-column grid.
/// Tiled categories put each item on a [RoundedButton].
class ToolGrid extends StatelessWidget {
  final CategoryModel category;
  final List<StationaryModel> tools;
  final String? selectedId;
  final ToolsPanelMetrics metrics;
  final ValueChanged<StationaryModel> onSelect;

  const ToolGrid({
    super.key,
    required this.category,
    required this.tools,
    required this.selectedId,
    required this.metrics,
    required this.onSelect,
  });

  static const double selectedScale = 1.08;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      primary: false,
      clipBehavior: Clip.none,
      itemCount: tools.length,
      padding: EdgeInsets.all(metrics.inset),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: metrics.stickGap,
        crossAxisSpacing: metrics.stickGap,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        final image = Image.asset(
          tool.image,
          filterQuality: FilterQuality.high,
        );
        Widget cell = PressButton(
          onPressed: () => onSelect(tool),
          child: image,
        );
        if (category.tiled) {
          cell = FittedBox(
            child: RoundedButton(
              image: image,
              backgroundColor: _tileColor(tool),
              onPressed: () => onSelect(tool),
            ),
          );
        }
        return Transform.scale(
          key: ValueKey(tool.id),
          scale: _scaleFor(tool),
          child: cell,
        );
      },
    );
  }

  bool _isSelected(StationaryModel tool) => tool.id == selectedId;

  double _scaleFor(StationaryModel tool) {
    if (_isSelected(tool)) return selectedScale;
    return 1;
  }

  Color _tileColor(StationaryModel tool) {
    if (_isSelected(tool)) return category.activeColor;
    return category.mutedColor;
  }
}
