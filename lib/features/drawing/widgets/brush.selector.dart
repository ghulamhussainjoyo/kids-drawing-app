import 'package:flutter/material.dart';

import '../../../data/models/brush.type.dart';
import 'tool.glyph.dart';
import 'tool.tile.dart';

/// Scrolling column of tool tiles. The selected tile sits on a white tab that
/// slides out to the left.
class BrushSelector extends StatefulWidget {
  const BrushSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.tileSize,
    required this.itemExtent,
    required this.tabOverhang,
    this.endPadding = 0,
  });

  static const List<BrushType> order = [
    BrushType.bucket,
    BrushType.crayon,
    BrushType.paintbrush,
    BrushType.wand,
    BrushType.pencil,
    BrushType.marker,
    BrushType.eraser,
  ];

  final BrushType selected;
  final ValueChanged<BrushType> onSelected;
  final double tileSize;
  final double itemExtent;

  /// How far the selected tab reaches past the column's left edge.
  final double tabOverhang;

  /// Empty space before the first and after the last tile.
  final double endPadding;

  @override
  State<BrushSelector> createState() => _BrushSelectorState();
}

class _BrushSelectorState extends State<BrushSelector> {
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    final leadingItems =
        (BrushSelector.order.indexOf(widget.selected) - 2).clamp(
      0,
      BrushSelector.order.length,
    );
    _scroll = ScrollController(
      initialScrollOffset: leadingItems * widget.itemExtent,
    );
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final tileSize = widget.tileSize;
    final itemExtent = widget.itemExtent;
    final tabOverhang = widget.tabOverhang;
    return ListView.builder(
      controller: _scroll,
      clipBehavior: Clip.none,
      padding: EdgeInsets.symmetric(vertical: widget.endPadding),
      itemCount: BrushSelector.order.length,
      itemExtent: itemExtent,
      itemBuilder: (context, index) {
        final type = BrushSelector.order[index];
        final isSelected = type == selected;
        return Semantics(
          button: true,
          selected: isSelected,
          label: ToolGlyph.label(type),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onSelected(type),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  left: isSelected ? -tabOverhang : tileSize,
                  right: 0,
                  top: (itemExtent - tileSize * 1.38) / 2,
                  height: tileSize * 1.38,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isSelected ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(tileSize * 0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                ToolTile(type: type, size: tileSize),
              ],
            ),
          ),
        );
      },
    );
  }
}
