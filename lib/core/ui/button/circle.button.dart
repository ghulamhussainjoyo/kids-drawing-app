import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class CircleButton extends StatelessWidget {
  /// Design size (jaise 48). Andar se device ke hisab se scale hota hai.
  final double size;
  final Widget image;
  final Color color;
  final double? imageSize;
  final VoidCallback? onPressed;

  /// Parent pehle hi scaled size de raha ho to false kar do.
  final bool responsive;

  /// [PressSound.exit] for a back or close button.
  final PressSound sound;

  const CircleButton({
    super.key,
    required this.image,
    this.onPressed,
    this.size = 48,
    this.imageSize,
    this.responsive = true,
    this.color = const Color(0xFFC5C5C5),
    this.sound = PressSound.enter,
  });

  double getGraphicSize(BuildContext context, double diameter) {
    double graphicSize;
    if (imageSize == null) {
      graphicSize = diameter * 0.5;
    } else if (responsive) {
      graphicSize = context.rs(imageSize!);
    } else {
      graphicSize = imageSize!;
    }
    return graphicSize;
  }

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onPressed: onPressed,
      sound: sound,
      builder: (context, pressed) => _face(context, pressed),
    );
  }

  Widget _face(BuildContext context, bool pressed) {
    final diameter = responsive ? context.rs(size) : size;
    final lip = diameter * 0.06;
    final faceHeight = diameter - lip;
    final graphicSize = getGraphicSize(context, diameter);
    final lipColor = Color.lerp(color, const Color(0xFF000000), 0.25)!;

    return SizedBox(
      width: diameter,
      height: diameter, // ab square, pehle diameter + lip tha
      child: Stack(
        children: [
          // Neeche wala dark base: poora circle
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: lipColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Upar wali face: full width, height diameter - lip
          AnimatedPositioned(
            duration: PressButton.pressDuration,
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            top: pressed ? lip : 0,
            height: faceHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(
                  Radius.elliptical(diameter / 2, faceHeight / 2),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: graphicSize,
                  height: graphicSize,
                  child: FittedBox(fit: BoxFit.contain, child: image),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
