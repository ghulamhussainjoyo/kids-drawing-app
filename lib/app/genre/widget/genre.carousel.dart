import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:provider/provider.dart';

import 'genre.circle.item.dart';

class GenreCarousel extends StatefulWidget {
  const GenreCarousel({super.key});
  @override
  State<GenreCarousel> createState() => _GenreCarouselState();
}

class _GenreCarouselState extends State<GenreCarousel> {
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
    final genres = context.watch<GenreViewModel>().genres;
    if (genres.isEmpty) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return PageView.builder(
      controller: controller,
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final howFarFromCenter = (page - index).abs();
        var closeness = 1.0 - howFarFromCenter;
        if (closeness < 0) {
          closeness = 0;
        }
        final scale = smallScale + (largeScale - smallScale) * closeness;
        final focused = howFarFromCenter < 0.5;
        final genre = genres[index];
        return GenreCircleItem(
          genre: genre,
          scale: scale,
          focused: focused,
          closeness: closeness,
          onPressed: (selected) {
            context.read<GenreViewModel>().openGenre(context, selected);
          },
        );
      },
    );
  }
}
