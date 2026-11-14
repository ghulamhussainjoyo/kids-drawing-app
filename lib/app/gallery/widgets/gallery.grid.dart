import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:provider/provider.dart';

import 'gallery.box.item.dart';

class GalleryGrid extends StatelessWidget {
  final List<ArtworkEntity> artworks;

  const GalleryGrid({super.key, required this.artworks});

  @override
  Widget build(BuildContext context) {
    final galleryViewModel = Provider.of<GalleryViewModel>(
      context,
      listen: false,
    );
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 2,
      padding: const EdgeInsets.all(24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final artwork in artworks)
          GalleryBoxItem(
            artwork: artwork,
            onPressed: (selected) {
              galleryViewModel.openArtwork(context, selected);
            },
          ),
      ],
    );
  }
}
