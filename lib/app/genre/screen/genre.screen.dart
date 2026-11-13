import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/genre/widget/genre.carousel.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});
  double getHorizontalPadding(double width) {
    return width < 360 ? 16.0 : 24.0;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: getHorizontalPadding(constraints.maxWidth),
            ),
            child: Stack(
              children: [
                // Carousel area
                Positioned(
                  // Room for the arched title above the focused circle.
                  top: 50,
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: GenreCarousel(),
                ),

                // Top controls
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      CupertinoButton(
                        onPressed: null,
                        padding: EdgeInsets.zero,
                        child: Icon(CupertinoIcons.settings),
                      ),
                      Spacer(),
                      CupertinoButton(
                        onPressed: null,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Try free for 7 days'),
                      ),
                    ],
                  ),
                ),
                // Bottom controls
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: null,
                        child: Text('Bottom left'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
