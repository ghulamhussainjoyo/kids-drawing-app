import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/features/drawing/screen/drawing.screen.new.dart.dart';

import 'gallery.box.item.dart';

class GalleryGrid extends StatelessWidget {
  final List<String> titles;
  const GalleryGrid({super.key, required this.titles});

  void onItemPressed(BuildContext context, String title) {
    debugPrint('onItemPressed: $title');
    final route = CupertinoPageRoute(builder: (context) => DrawingScreenNew());
    Navigator.push(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 2,
      padding: const EdgeInsets.all(24),
      children: [
        for (final title in titles)
          GalleryBoxItem(title: title, onPressed: onItemPressed),
      ],
    );
  }
}
