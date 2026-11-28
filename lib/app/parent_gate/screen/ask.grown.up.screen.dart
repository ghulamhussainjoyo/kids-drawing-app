import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/parent_gate/utils/grown.up.math.challenge.dart';
import 'package:kids_drawing_flutter/app/parent_gate/widgets/grown.up.equation.card.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/core/ui/button/circle.button.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

/// Full-screen parental gate. Pops `true` on correct answer, `false` on X.
class AskGrownUpScreen extends StatefulWidget {
  const AskGrownUpScreen({super.key});

  @override
  State<AskGrownUpScreen> createState() => _AskGrownUpScreenState();
}

class _AskGrownUpScreenState extends State<AskGrownUpScreen> {
  late GrownUpMathChallenge challenge;

  @override
  void initState() {
    super.initState();
    challenge = GrownUpMathChallenge.generate();
  }

  void closeGate() {
    Navigator.of(context).pop(false);
  }

  void onAnswer(int choice) {
    if (challenge.isCorrect(choice)) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      challenge = GrownUpMathChallenge.generate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF3B1F5E),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 8,
              child: CircleButton(
                size: 24,
                color: AppColors.purple,
                onPressed: closeGate,
                sound: PressSound.exit,
                image: const Icon(
                  CupertinoIcons.xmark,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        final vm = context.read<SettingViewModel>();
                        return Text(
                          vm.t('parent_gate.title'),
                          textAlign: TextAlign.center,
                          style: AppTypography.boldStyle(
                            color: CupertinoColors.white,
                            fontSize: 32,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    GrownUpEquationCard(
                      challenge: challenge,
                      onAnswer: onAnswer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
