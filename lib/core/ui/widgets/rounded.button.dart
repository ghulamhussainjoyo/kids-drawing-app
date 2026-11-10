import 'package:flutter/cupertino.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.image,
    this.onPressed,
    this.size = 72,
    this.imageSize,
    this.backgroundColor = const Color(0xFF5EC8C8),
  });

  /// Icon, Image.asset, or SvgPicture.
  final Widget image;
  final VoidCallback? onPressed;

  /// Outer tile width and height (the lip sits below this).
  final double size;

  /// Width and height of the graphic inside the tile.
  /// Defaults to 85% of [size] so the art fills the button like the reference.
  final double? imageSize;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final graphicSize = imageSize ?? size * 0.85;
    final radius = BorderRadius.circular(size * 0.28);
    final lip = size * 0.1;
    final lipColor = Color.lerp(
      backgroundColor,
      const Color(0xFF000000),
      0.25,
    )!;

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
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: radius,
                ),
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
