import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/features/drawing/screen/drawing.screen.dart.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';
import 'package:provider/provider.dart';

import 'gallery.box.item.dart';

class GalleryGrid extends StatelessWidget {
  final List<String> titles;
  const GalleryGrid({super.key, required this.titles});

  void onItemPressed(BuildContext context, String title) {
    Provider.of<DrawingViewModel>(context, listen: false).selectArtwork(title);
    final route = CupertinoPageRoute(
      builder: (context) => const DrawingScreen(),
    );
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
