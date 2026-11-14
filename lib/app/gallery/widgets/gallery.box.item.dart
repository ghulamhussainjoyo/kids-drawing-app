import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';

class GalleryBoxItem extends StatelessWidget {
  final ArtworkEntity artwork;
  final ValueChanged<ArtworkEntity> onPressed;

  const GalleryBoxItem({
    super.key,
    required this.artwork,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final thumbPath = artwork.thumbnailPath;
    final hasThumb = thumbPath != null && File(thumbPath).existsSync();
    Widget child;
    if (hasThumb) {
      final file = File(thumbPath);
      final imageProvider = FileImage(file);
      imageProvider.evict();
      child = Image(
        key: ValueKey('${artwork.artworkKey}-${artwork.updatedAt}'),
        image: imageProvider,
        fit: BoxFit.cover,
      );
    } else {
      child = Center(child: Text(artwork.title));
    }

    return GestureDetector(
      onTap: () => onPressed(artwork),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.black, width: 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
