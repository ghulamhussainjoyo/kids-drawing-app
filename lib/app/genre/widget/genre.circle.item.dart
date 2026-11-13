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

  /// Circle fills most of the PageView slot (was screen width * 0.25).
  double circleSizeFrom(BoxConstraints constraints) {
    return constraints.maxWidth * (2 / 3);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final circleSize = circleSizeFrom(constraints);
        final title = GenreTitle(genre: genre, circleSize: circleSize);
        final titleScale = title.hideScale(closeness);
        return Center(
          child: GestureDetector(
            onTap: () => onPressed(genre),
            behavior: HitTestBehavior.opaque,
            child: Transform.scale(
              scale: scale,
              child: Padding(
                padding: EdgeInsets.only(top: title.topOverhang),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: titleScale,
                      alignment: Alignment.center,
                      child: title,
                    ),
                    ClipOval(
                      child: Image.asset(
                        genre.image,
                        width: circleSize,
                        height: circleSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
