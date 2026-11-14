import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/gallery/widgets/gallery.grid.dart';
import 'package:kids_drawing_flutter/app/gallery/widgets/gallery.section.background.dart';
import 'package:kids_drawing_flutter/data/local/floor/artwork.entity.dart';
import 'package:kids_drawing_flutter/state/gallery/gallery.view-model.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:provider/provider.dart';

class GalleryScreen extends StatefulWidget {
  /// Landing id: a catalog genre, or `coloring-arts` for scroller start.
  final String category;

  const GalleryScreen({super.key, required this.category});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const String coloringArtsId = 'coloring-arts';

  static const Map<String, Color> sectionColors = {
    'school': Color(0xFF7EC8E3),
    'animals': Color(0xFF7CB88B),
    'music': Color(0xFF8B7CB8),
    'transport': Color(0xFFE8C87C),
    'seasons': Color(0xFF81D4FA),
    'princes': Color(0xFFFF4D94),
    'fruit-garden': Color(0xFFFF8A3D),
  };

  late final ScrollController controller;
  List<String> sectionIds = const [];
  bool ready = false;

  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sectionIds = _catalogSectionIds();
      _loadAndLand();
    });
  }

  @override
  void dispose() {
    controller.removeListener(_onScroll);
    controller.dispose();
    super.dispose();
  }

  List<String> _catalogSectionIds() {
    final genres = Provider.of<GenreViewModel>(
      context,
      listen: false,
    ).getGenres();
    final ids = <String>[];
    for (final genre in genres) {
      if (genre.id == coloringArtsId) {
        continue;
      }
      ids.add(genre.id);
    }
    return ids;
  }

  void _onScroll() {
    setState(() {});
  }

  Future<void> _loadAndLand() async {
    final galleryViewModel = Provider.of<GalleryViewModel>(
      context,
      listen: false,
    );
    await galleryViewModel.loadAll(sectionIds);
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _jumpToLanding();
      setState(() {
        ready = true;
      });
    });
  }

  void _jumpToLanding() {
    if (!controller.hasClients) {
      return;
    }
    final offset = offsetForLanding(widget.category);
    final maxOffset = controller.position.maxScrollExtent;
    controller.jumpTo(offset.clamp(0.0, maxOffset));
  }

  double sectionWidth(String sectionId) {
    final galleryViewModel = Provider.of<GalleryViewModel>(
      context,
      listen: false,
    );
    final artworks = galleryViewModel.artworksForGenre(sectionId);
    return widthForArtworks(artworks);
  }

  double widthForArtworks(List<ArtworkEntity> artworks) {
    final height = MediaQuery.sizeOf(context).height;
    const padding = 48.0;
    final cellSize = (height - padding) / 2;
    final columns = (artworks.length / 2).ceil();
    final safeColumns = columns < 1 ? 1 : columns;
    return padding + safeColumns * cellSize;
  }

  double offsetForLanding(String landingId) {
    if (landingId == coloringArtsId) {
      return 0;
    }
    var offset = 0.0;
    for (final sectionId in sectionIds) {
      if (sectionId == landingId) {
        return offset;
      }
      offset = offset + sectionWidth(sectionId);
    }
    return 0;
  }

  Color backgroundColor() {
    final scrollOffset = controller.hasClients ? controller.offset : 0.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final background = GallerySectionBackground(
      sectionIds: sectionIds,
      colors: sectionColors,
      sectionWidth: sectionWidth,
    );
    return background.colorAt(
      scrollOffset: scrollOffset,
      screenWidth: screenWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryViewModel = Provider.of<GalleryViewModel>(context);
    return CupertinoPageScaffold(
      backgroundColor: backgroundColor(),
      child: galleryViewModel.loading && !ready
          ? const Center(child: CupertinoActivityIndicator())
          : Opacity(
              opacity: ready ? 1 : 0,
              child: ListView(
                controller: controller,
                scrollDirection: Axis.horizontal,
                children: [
                  for (final sectionId in sectionIds)
                    SizedBox(
                      width: sectionWidth(sectionId),
                      child: GalleryGrid(
                        artworks: galleryViewModel.artworksForGenre(sectionId),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
