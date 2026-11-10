import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/tools/stationary.tools.dart';
import 'package:kids_drawing_flutter/core/type/category.model.dart';
import 'package:kids_drawing_flutter/data/models/tools/stationary.model.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tools/category.rail.dart';

class DrawingTools extends StatefulWidget {
  final double notchInset;
  final String selectedCategory;
  final StationaryTools stationaryTools;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<StationaryModel> onToolSelect;

  const DrawingTools({
    super.key,
    required this.notchInset,
    required this.onToolSelect,
    required this.onCategoryTap,
    required this.selectedCategory,
    required this.stationaryTools,
  });

  @override
  State<DrawingTools> createState() => _DrawingToolsState();
}

class _DrawingToolsState extends State<DrawingTools> {
  String? selectedId;
  late final List<CategoryModel> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.stationaryTools.getCategoryList();
  }

  List<StationaryModel> get pencils =>
      widget.stationaryTools.getToolsByCategory(widget.selectedCategory);

  void onPencilTap(StationaryModel pencil) {
    setState(() {
      selectedId = pencil.id;
    });
    widget.onToolSelect(pencil);
  }

  void onCategoryTap(String name) {
    if (name == widget.selectedCategory) {
      return;
    }
    final nextPencils = widget.stationaryTools.getToolsByCategory(name);
    final sameTools = _samePencilIds(pencils, nextPencils);
    setState(() {
      if (!sameTools) {
        selectedId = null;
      }
    });
    widget.onCategoryTap(name);
  }

  bool _samePencilIds(
    List<StationaryModel> previous,
    List<StationaryModel> next,
  ) {
    if (previous.length != next.length) {
      return false;
    }
    for (var index = 0; index < previous.length; index++) {
      if (previous[index].id != next[index].id) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final stickHeight = (screenHeight * 0.06).clamp(38.0, 48.0);
    final stickGap = (screenHeight * 0.003).clamp(1.0, 3.0);
    final slide = (screenWidth * 0.025).clamp(16.0, 32.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final notch = widget.notchInset;
        final innerWidth = constraints.maxWidth;
        final buttonRailWidth = innerWidth * 2 / 5;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: ColoredBox(color: Colors.green)),
            Positioned.fill(
              child: ListView.builder(
                primary: false,
                clipBehavior: Clip.none,
                itemCount: pencils.length,
                itemExtent: stickHeight + stickGap,
                itemBuilder: (context, index) {
                  final pencil = pencils[index];
                  final selected = pencil.id == selectedId;
                  return GestureDetector(
                    key: ValueKey(pencil.id),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onPencilTap(pencil),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 0,
                          width: innerWidth,
                          height: stickHeight,
                          left: selected ? -slide : -slide * 0.35,
                          child: Image.asset(
                            pencil.image,
                            fit: BoxFit.cover,
                            height: stickHeight,
                            gaplessPlayback: true,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: buttonRailWidth + notch,
              child: ColoredBox(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.only(right: notch),
                  child: CategoryRail(
                    categories: categories,
                    selectedCategory: widget.selectedCategory,
                    onCategoryTap: onCategoryTap,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
