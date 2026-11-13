import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/genre/widget/genre.title.dart';
import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

class GenreCircleItem extends StatelessWidget {
  final GenreModel genre;
  final double scale;
  final bool focused;
  final double closeness;
  final ValueChanged<GenreModel> onPressed;

  const GenreCircleItem({
    super.key,
    required this.genre,
    required this.scale,
    required this.focused,
    required this.closeness,
    required this.onPressed,
  });

  double getItemSize(BuildContext context, double size) {
    return MediaQuery.of(context).size.width * size;
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = getItemSize(context, 0.25);
    return Center(
      child: GestureDetector(
        onTap: () => onPressed(genre),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.scale(
              scale: scale,
              child: ClipOval(
                child: Image.asset(
                  genre.image,
                  width: circleSize,
                  height: circleSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Opacity(
              opacity: closeness,
              child: GenreTitle(genre: genre, circleSize: circleSize),
            ),
          ],
        ),
      ),
    );
  }
}
