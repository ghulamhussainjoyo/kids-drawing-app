import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/app/drawing/metrics/tools.panel.metrics.dart';
import 'package:kids_drawing_flutter/core/tools/stationary.tools.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';
import 'package:kids_drawing_flutter/types/tools/stationary.model.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/tools/category.rail.dart';

class DrawingTools extends StatefulWidget {
  final ToolsPanelMetrics metrics;
  final String selectedCategory;
  final String? selectedToolId;
  final StationaryTools stationaryTools;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<StationaryModel> onToolSelect;

  const DrawingTools({
    super.key,
    required this.metrics,
    required this.onToolSelect,
    required this.onCategoryTap,
    required this.selectedCategory,
    required this.selectedToolId,
    required this.stationaryTools,
  });

  @override
  State<DrawingTools> createState() => _DrawingToolsState();
}

class _DrawingToolsState extends State<DrawingTools> {
  late final List<CategoryModel> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.stationaryTools.getCategoryList();
  }

  List<StationaryModel> get pencils =>
      widget.stationaryTools.getToolsByCategory(widget.selectedCategory);

  void onCategoryTap(String name) {
    if (name == widget.selectedCategory) return;
    widget.onCategoryTap(name);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;

    return SizedBox(
      width: m.totalWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: m.greenWidth,
            child: const ColoredBox(color: Colors.green),
          ),
          Positioned.fill(
            child: ListView.separated(
              primary: false,
              clipBehavior: Clip.none,
              itemCount: pencils.length,
              separatorBuilder: (_, __) => SizedBox(height: m.stickGap),
              itemBuilder: (context, index) {
                final pencil = pencils[index];
                final selected = pencil.id == widget.selectedToolId;
                final offsetX = selected ? m.inset - m.slide : m.inset;
                return GestureDetector(
                  key: ValueKey(pencil.id),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onToolSelect(pencil),
                  child: SizedBox(
                    height: m.stickHeight,
                    width: m.totalWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: Offset(offsetX, 0),
                        child: Image.asset(
                          pencil.image,
                          fit: BoxFit.fitHeight,
                          width: m.stickWidth,
                          height: m.stickHeight,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.high,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: m.greenWidth,
            top: 0,
            bottom: 0,
            width: m.railWidth,
            child: ColoredBox(
              color: Colors.red,
              // Rail hamesha fixed width, notch sirf extra red jagah banata hai
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: m.contentWidth,
                  child: CategoryRail(
                    gap: m.gap,
                    imageSize: m.imageSize,
                    buttonSize: m.buttonSize,
                    categories: categories,
                    onCategoryTap: onCategoryTap,
                    verticalPadding: m.verticalPadding,
                    horizontalPadding: m.horizontalPadding,
                    selectedCategory: widget.selectedCategory,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class DrawingTools extends StatefulWidget {
//   final double notchInset;
//   final String selectedCategory;
//   final String? selectedToolId;
//   final StationaryTools stationaryTools;
//   final ValueChanged<String> onCategoryTap;
//   final ValueChanged<StationaryModel> onToolSelect;

//   const DrawingTools({
//     super.key,
//     required this.notchInset,
//     required this.onToolSelect,
//     required this.onCategoryTap,
//     required this.selectedCategory,
//     required this.selectedToolId,
//     required this.stationaryTools,
//   });

//   @override
//   State<DrawingTools> createState() => _DrawingToolsState();
// }

// class _DrawingToolsState extends State<DrawingTools> {
//   late final List<CategoryModel> categories;

//   @override
//   void initState() {
//     super.initState();
//     categories = widget.stationaryTools.getCategoryList();
//   }

//   List<StationaryModel> get pencils =>
//       widget.stationaryTools.getToolsByCategory(widget.selectedCategory);

//   void onPencilTap(StationaryModel pencil) {
//     widget.onToolSelect(pencil);
//   }

//   void onCategoryTap(String name) {
//     if (name == widget.selectedCategory) {
//       return;
//     }
//     widget.onCategoryTap(name);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final notch = widget.notchInset;
//         final panelHeight = constraints.maxHeight;
//         final panelWidth = constraints.maxWidth;
//         const buttonFactor = 0.12;
//         const verticalFactor = 0.5;
//         const gapFactor = 0.25;
//         const horizontalFactor = 0.25;
//         const imageFactor = 56 / 48;
//         const stickAspect = 1080 / 200;
//         const stickGapFactor = 0.08;
//         const insetFactor = 0.08;
//         const slideFactor = 0.14;
//         const tuckExtraFactor = 0.15;
//         const greenFactor = 0.28;
//         final buttonSize = panelHeight * buttonFactor;
//         final horizontalPadding = buttonSize * horizontalFactor;
//         final verticalPadding = buttonSize * verticalFactor;
//         final gap = buttonSize * gapFactor;
//         final imageSize = buttonSize * imageFactor;
//         final screen = MediaQuery.sizeOf(context);
//         final greenWidth = screen.shortestSide * greenFactor;
//         final inset = greenWidth * insetFactor;
//         final slide = greenWidth * slideFactor;
//         final tuck = slide + greenWidth * tuckExtraFactor;
//         final stickWidth = greenWidth - inset + tuck;
//         final stickHeight = stickWidth / stickAspect;
//         final stickGap = stickHeight * stickGapFactor;
//         return Stack(
//           clipBehavior: Clip.none,
//           children: [
//             Positioned(
//               left: 0,
//               top: 0,
//               bottom: 0,
//               width: greenWidth,
//               child: const ColoredBox(color: Colors.green),
//             ),
//             Positioned.fill(
//               child: ListView.separated(
//                 primary: false,
//                 clipBehavior: Clip.none,
//                 itemCount: pencils.length,
//                 separatorBuilder: (context, index) {
//                   return SizedBox(height: stickGap);
//                 },
//                 itemBuilder: (context, index) {
//                   final pencil = pencils[index];
//                   final selected = pencil.id == widget.selectedToolId;
//                   final offsetX = selected ? inset - slide : inset;
//                   return GestureDetector(
//                     key: ValueKey(pencil.id),
//                     behavior: HitTestBehavior.opaque,
//                     onTap: () => onPencilTap(pencil),
//                     child: SizedBox(
//                       height: stickHeight,
//                       width: panelWidth,
//                       child: Align(
//                         alignment: Alignment.centerLeft,
//                         child: Transform.translate(
//                           offset: Offset(offsetX, 0),
//                           child: Image.asset(
//                             pencil.image,
//                             fit: BoxFit.fitHeight,
//                             width: stickWidth,
//                             height: stickHeight,
//                             gaplessPlayback: true,
//                             filterQuality: FilterQuality.high,
//                             alignment: Alignment.centerLeft,
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               left: greenWidth,
//               top: 0,
//               right: 0,
//               bottom: 0,
//               child: ColoredBox(
//                 color: Colors.red,
//                 child: Padding(
//                   padding: EdgeInsets.only(right: notch),
//                   child: CategoryRail(
//                     gap: gap,
//                     imageSize: imageSize,
//                     buttonSize: buttonSize,
//                     categories: categories,
//                     onCategoryTap: onCategoryTap,
//                     verticalPadding: verticalPadding,
//                     horizontalPadding: horizontalPadding,
//                     selectedCategory: widget.selectedCategory,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
