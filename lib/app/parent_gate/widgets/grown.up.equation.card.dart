import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/parent_gate/utils/grown.up.math.challenge.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/circle.button.dart';

/// White card with the math equation and three answer circles.
class GrownUpEquationCard extends StatelessWidget {
  final GrownUpMathChallenge challenge;
  final ValueChanged<int> onAnswer;

  static const List<Color> answerColors = [
    Color(0xFF2E71CC),
    Color(0xFFC61A74),
    Color(0xFFD78B0E),
  ];

  const GrownUpEquationCard({
    super.key,
    required this.challenge,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            challenge.equation,
            textAlign: TextAlign.center,
            style: AppTypography.numericStyle(
              color: const Color(0xFF3A3A3A),
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < challenge.options.length; i++)
                CircleButton(
                  size: 52,
                  color: answerColors[i % answerColors.length],
                  onPressed: () => onAnswer(challenge.options[i]),
                  image: Text(
                    '${challenge.options[i]}',
                    style: AppTypography.numericStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 24,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
