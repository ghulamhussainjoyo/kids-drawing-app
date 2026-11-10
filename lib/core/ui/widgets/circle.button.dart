import 'package:flutter/cupertino.dart';

// @Doc: usage:
// CircleButton(
//   size: 56,
//   color: const Color(0xFFC5C5C5),
//   image: const Icon(
//     CupertinoIcons.arrowshape_turn_up_right_fill,
//     color: Color(0xFFFFFFFF),
//   ),
//   onPressed: () {},
// )

class CircleButton extends StatelessWidget {
  /// Icon, Image.asset, or SvgPicture.
  final double size;
  final Widget image;
  final Color color;
  final double? imageSize;
  final VoidCallback? onPressed;

  const CircleButton({
    super.key,
    required this.image,
    this.onPressed,
    this.size = 56,
    this.imageSize,
    this.color = const Color(0xFFC5C5C5),
  });

  @override
  Widget build(BuildContext context) {
    final graphicSize = imageSize ?? size * 0.5;
    final radius = BorderRadius.circular(size / 2);
    final lip = size * 0.1;
    final lipColor = Color.lerp(color, const Color(0xFF000000), 0.25)!;

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        width: size,
        height: size + lip,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: size,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: lipColor,
                  borderRadius: radius,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: size,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, borderRadius: radius),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Center(
                    child: SizedBox(
                      width: graphicSize,
                      height: graphicSize,
                      child: FittedBox(fit: BoxFit.contain, child: image),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
