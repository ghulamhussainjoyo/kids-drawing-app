import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
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
    const borderWidth = 3.0;
    const outerRadius = 16.0;
    const innerRadius = outerRadius - borderWidth;

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
      child = const SizedBox.shrink();
    }

    return PressButton(
      onPressed: () => onPressed(artwork),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(color: CupertinoColors.black, width: borderWidth),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(innerRadius),
          child: child,
        ),
      ),
    );
  }
}
