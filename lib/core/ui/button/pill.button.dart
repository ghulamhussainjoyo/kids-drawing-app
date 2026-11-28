import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';

/// A rounded text button — "CONTINUE", "YES", "KEEP IT".
///
/// It exists so the app's text buttons press and sound like every other
/// button instead of each screen rolling its own `CupertinoButton`.
class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// Transparent gives a plain text button.
  final Color color;
  final Color textColor;
  final double fontSize;
  final double radius;
  final EdgeInsets padding;

  /// [PressSound.exit] for a button that leaves the screen.
  final PressSound sound;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color = const Color(0x00000000),
    this.textColor = const Color(0xFFFFFFFF),
    this.fontSize = 16,
    this.radius = 24,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
    this.sound = PressSound.enter,
  });

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onPressed: onPressed,
      sound: sound,
      builder: (context, pressed) => AnimatedOpacity(
        duration: PressButton.pressDuration,
        opacity: pressed ? 0.6 : 1,
        child: _pill(),
      ),
    );
  }

  Widget _pill() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: padding,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.boldStyle(fontSize: fontSize, color: textColor),
        ),
      ),
    );
  }
}
