import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/features/gallery/screen/gallery.screen.dart';

import 'category.circle.item.dart';

class CategoryCarousel extends StatefulWidget {
  const CategoryCarousel({super.key, required this.names});

  final List<String> names;

  @override
  State<CategoryCarousel> createState() => _CategoryCarouselState();
}

class _CategoryCarouselState extends State<CategoryCarousel> {
  double page = 0;
  static const double smallScale = 0.75;
  static const double largeScale = 1.0;
  late final PageController controller;
  static const double viewportFraction = 0.38;

  void onScroll() {
    if (!controller.hasClients || controller.page == null) {
      return;
    }
    setState(() {
      page = controller.page!;
    });
  }

  double getItemSize(double size) {
    return MediaQuery.of(context).size.width * size;
  }

  double getItemScale(double page, int index) {
    final howFarFromCenter = (page - index).abs();
    var closeness = 1.0 - howFarFromCenter;
    if (closeness < 0) {
      closeness = 0;
    }
    return smallScale + (largeScale - smallScale) * closeness;
  }

  void onItemPressed(String name) {
    debugPrint('onItemPressed: $name');
    final route = CupertinoPageRoute(
      builder: (context) => GalleryScreen(category: name),
    );
    Navigator.push(context, route);
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: viewportFraction);
    controller.addListener(onScroll);
  }

  @override
  void dispose() {
    controller.removeListener(onScroll);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: widget.names.length,
      itemBuilder: (context, index) {
        final howFarFromCenter = (page - index).abs();
        var closeness = 1.0 - howFarFromCenter;
        if (closeness < 0) {
          closeness = 0;
        }
        final scale = smallScale + (largeScale - smallScale) * closeness;
        final focused = howFarFromCenter < 0.5;
        return CategoryCircleItem(
          scale: scale,
          focused: focused,
          closeness: closeness,
          name: widget.names[index],
          onPressed: onItemPressed,
        );
      },
    );
  }
}
